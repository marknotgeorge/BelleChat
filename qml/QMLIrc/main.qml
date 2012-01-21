import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import QMLIrc 1.0

PageStackWindow {
    id: window
    property string lastChannel: "Server"
    property string currentChannel: "Server"
    property bool userDisconnected: false
    property bool tryingToQuit: false

    initialPage: MainPage { tools: serverToolbar }
    platformSoftwareInputPanelEnabled: true

    Component {
        id: serverSettingsFactory
        ServerSettings {}
    }

    Component {
        id: settingsPageFactory
        SettingsPage {}
    }

    InfoBanner {
        id: connectFailedBanner
    }

    Timer {
        id: connectionTimer
        interval: 15000
        onTriggered: {
            notifyConnectionFailure()
        }
    }


    Connections {
        target: Session
        onOutputString: {
            initialPage.outputToTab(channel, output)
        }
        onConnected: {
            connectServer.visible = false
            connectionTimer.stop()
            initialPage.outputToTab("Server", "Connected to " + appConnectionSettings.host + "!")
            disconnectServer.text = "Disconnect from " + appConnectionSettings.host
            disconnectServer.visible = true
            buttonJoin.enabled = true

        }
        onDisconnected: {
            if (!userDisconnected)
            {
                // Unexpected disconnection.
                //TODO: Insert some code to notify user.
            }
            userDisconnected = false;
            initialPage.closeAllTabs()
            if (!tryingToQuit)
            {
                initialPage.clearTab("Server")
                initialPage.outputToTab("Server", "Disconnected from " + appConnectionSettings.host + ".")
                disconnectServer.visible = false
                connectServer.text = "Connect to " + appConnectionSettings.host
                connectServer.enabled = true
                connectServer.visible = true
                buttonJoin.enabled = false
                buttonUsers.enabled = false
            }
            else
                exit()
        }
        onChannelJoined: {
            if (initialPage.findButton(channel) === undefined)
            {
                initialPage.createTab(channel)
                // Set lastChannel to channel...
                lastChannel = currentChannel
                currentChannel = channel
            }
        }
        onNewChannelList: {
            selectChannelDialog.open()
        }
        onSocketError: {
            connectionTimer.stop()
            notifyConnectionFailure()
        }
    }

    Version {
        id: appVersion
    }

    ConnectionSettings {
        id: appConnectionSettings
    }

    CommonDialog {
        id: aboutDialog
        titleText: "About QMLIrc"
        content: Label {
            text: "QMLIrc " + appVersion.version + "\n© 2011-12 MarkNotGeorge"
        }
        buttonTexts: ["OK"]
    }

    Menu {
        id: menuMain
        content: MenuLayout {
            MenuItem {
                id: menuItemSettings
                text: "Settings"
                onClicked: {
                    var settingsPage = settingsPageFactory.createObject(initialPage);
                    pageStack.push(settingsPage)
                }
            }

            MenuItem {
                id: menuItemAbout
                text: "About QMLIrc"
                onClicked: {
                    aboutDialog.open()
                }
            }
        }
    }


    SelectionDialog {
        id: selectChannelDialog
        titleText: "Select Channel:"
        model: ChannelModel
        delegate: ListItem {
            Column {
                ListItemText {
                    role: "Title"
                    text: channel + " (" + users + ")"
                }
                ListItemText {
                    role: "Subtitle"
                    text: topic
                }
            }
            onClicked: {
                selectChannelDialog.selectedIndex = index
                selectChannelDialog.accept()
            }
        }
        onAccepted: {
            var channel = model[selectedIndex].channel
            console.log("Channel:", channel)
            joinChannel(channel)
        }
    }

    TextPickerDialog {
        id: enterChannelDialog
        titleText: "Join channel:"
        placeholderText: "Enter channel name..."
        text: "#"
        acceptButtonText: "OK"
        rejectButtonText: "Cancel"
        validator: RegExpValidator { regExp: /([#&][^\x07\x2C\s]{0,200})/ }
        onAccepted: {
            joinChannel(text)
        }
    }

    Menu {
        id: menuJoin
        content: MenuLayout {
            MenuItem {
                id: enterChannel
                text: "Join Channel..."
                onClicked: {
                    showChannelDialog(lastChannel)
                }
            }

            MenuItem {
                id: partChannel
                text: "Leave " + currentChannel
                visible: false
                onClicked: {
                    leaveChannel(currentChannel)
                }
            }

            MenuItem {
                id: selectChannelFromList
                text: "Select from list"
                visible: true
                onClicked: {
                    Session.getChannelList("")
                }
            }
        }
    }

    CommonDialog {
        id: queryDisconnect
        titleText: "Disconnect from " + appConnectionSettings.host +"?"
        content: Text {
            text: "Are you sure you wish to disconnect from the server?"
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10
            wrapMode: Text.WordWrap
            color: platformStyle.colorNormalLight
        }

        buttonTexts: ["Ok", "Cancel"]
        onButtonClicked: {
            if (!index) { // If 'Ok' pressed.
                console.log("Disconnecting from server...")
                userDisconnected = true // Supress notification of disconnection
                initialPage.closeAllTabs()
                Session.close()
            }
        }
    }

    CommonDialog {
        id: queryQuit
        titleText: "Quit QMLIrc?"
        content: Text {
            text: "You are still connected to the server!\n Are you sure you wish to quit?"
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10
            wrapMode: Text.WordWrap
            color: platformStyle.colorNormalLight
        }
        buttonTexts: ["Ok", "Cancel"]
        onButtonClicked: {
            if (!index) {
                // Close the session
                tryingToQuit = true
                Session.close()
            }
        }
    }

    Menu {
        id: menuConnect
        content: MenuLayout {
            MenuItem {
                id: connectServer
                text: "Connect to " + appConnectionSettings.host
                visible: true
                onClicked: {
                    Session.updateConnection()
                    var connectingString = "Connecting to " + appConnectionSettings.host +"..."
                    text = connectingString
                    initialPage.outputToTab("Server", connectingString)
                    connectionTimer.start()
                    Session.open()
                }
            }

            MenuItem {
                id: disconnectServer
                text: "Disconnect"
                visible: false
                onClicked: {
                    queryDisconnect.open();
                }
            }
        }
    }


    ToolBarLayout {
        id: serverToolbar
        ToolButton {
            flat: true
            iconSource: "close_stop.svg"
            onClicked: {
                // If we're connected, we need to close the connection before
                // we quit. Open a dialog to ask if the user is sure.
                if (Session.connected)
                {
                    queryQuit.open()
                }
                else
                {
                    tryingToQuit = true
                    exit()
                }
            }
        }

        ToolButton {
            id: buttonConnect
            flat: true
            iconSource: "icon-connect.svg"
            onClicked: {
                menuConnect.open()
            }
        }

        ToolButton {
            x:2
            id: buttonJoin
            iconSource: "icon-join.svg"
            flat:true
            visible: true
            enabled: false
            onClicked: {
                menuJoin.open()
            }
        }

        ToolButton {
            id: buttonUsers
            iconSource: "icon-users.svg"
            flat:true
            enabled: false
            onClicked: {
                var userPageFactory = Qt.createComponent("UserPage.qml")
                var page = userPageFactory.createObject(window)

                pageStack.push(page)
            }
        }

        ToolButton {
            id: buttonMenu
            iconSource: "toolbar-menu"
            flat: true
            onClicked: {
                menuMain.open()
            }
        }
    }

    Component.onCompleted: {
        var outputString = "Welcome to QMLIrc " + appVersion.version +"!\n"
        initialPage.outputToTab("Server", outputString)
    }

    function joinChannel(channel)
    {
        initialPage.outputToTab("Server", "Joining channel " + channel + " ...")
        // This is where the actual channel joining code goes...
        Session.joinChannel(channel)

    }

    function leaveChannel(channel)
    {
        currentChannel = lastChannel
        initialPage.selectTab(lastChannel)
        initialPage.closeTab(channel)
    }

    function showChannelDialog()
    {
        enterChannelDialog.open()
    }

    function exit()
    {
        if (tryingToQuit)
        {
            console.log("Quitting...")
            Qt.quit()
        }
    }

    function notifyConnectionFailure()
    {
        var failureString = "Could not connect to " + appConnectionSettings.host + ".\n Please check your settings."
        Session.close()
        connectFailedBanner.text = failureString
        initialPage.outputToTab("Server", failureString)
        connectFailedBanner.open()
    }

}


