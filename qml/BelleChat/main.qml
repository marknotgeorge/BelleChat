import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import BelleChat 1.0

PageStackWindow {
    id: window
    property bool userDisconnected: false
    property bool tryingToQuit: false
    property bool namesListRequested: false
    property bool channelListCancelled: false

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

    Component {
        id: userPageFactory
        UserPage {}
    }

    Component {
        id: channelPageFactory
        ChannelListPage {}
    }

    BusyIndicator {
        id: appBusy
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        running: false
        visible: false
    }

    QueryDialog {
        id: noChannelsDialog
        acceptButtonText: "Yes"
        rejectButtonText: "No"
        titleText: "No channels"
        message: "There are no existing channels. Create a new one?\n"
        onAccepted: {
            enterChannelDialog.open()
        }
    }

    CommonDialog {
        id: fetchingChannelsDialog
        titleText: "Fetching list of channels..."
        buttonTexts: ["Cancel"]
        content:
            ProgressBar {
            id: fcProgress
            indeterminate: true
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: platformStyle.paddingMedium
            anchors.right: parent.right
            anchors.rightMargin: platformStyle.paddingMedium
        }
        onButtonClicked: {
            channelListCancelled = true
            close()
        }
    }


    Connections {
        target: Session
        onOutputString: {
            initialPage.outputToTab(channel, output)
        }
        onConnected: {
            buttonConnect.state = "Connected"
            initialPage.outputToTab("Server", "Connected to " + appConnectionSettings.host + "!")
            if (appConnectionSettings.showChannelList)
            {
                fetchingChannelsDialog.open()
                Session.getChannelList("")
            }

        }
        onDisconnected: {
            if (!userDisconnected)
            {
                var failureString = "Connection to " + appConnectionSettings.host + " failed."
                Session.close()
                initialPage.outputToTab("Server", failureString)
            }

            userDisconnected = false;
            initialPage.closeAllTabs()
            if (!tryingToQuit)
            {
                initialPage.clearTab("Server")
                initialPage.outputToTab("Server", "Disconnected from " + appConnectionSettings.host + ".")
                buttonConnect.state = "Disconnected"
            }
            else
                exit()
        }
        onChannelJoined: {
            console.log("Channel" + channel + "joined.")
            if (initialPage.findButton(channel) === undefined)
            {
                console.log("Opening new channel page")
                initialPage.createTab(channel)
                // Set lastChannel to channel...
                Session.lastChannel = Session.currentChannel
                Session.currentChannel = channel
            }
        }
        onNewChannelList: {
            fetchingChannelsDialog.close()
            if (!channelListCancelled)
            {
                if (numberOfChannels > 0)
                {
                    var page = channelPageFactory.createObject(window)
                    page.count = numberOfChannels
                    pageStack.push(page)
                }
                else
                    noChannelsDialog.open()
            }
            channelListCancelled = false
        }
        onSocketError: {
            var failureString = "Connection to " + appConnectionSettings.host + " failed."
            Session.close()
            initialPage.outputToTab("Server", failureString)
            buttonConnect.state = "Disconnected"
        }

    }

    ConnectionSettings {
        id: appConnectionSettings
        onHostChanged: {
        }
    }

    QueryDialog {
        id: aboutDialog
        titleText: "About BelleChat"
        message: "BelleChat " + Version + "\nBuild " + Build + "\n© 2011-12 Mark Johnson\nUses Communi written by J-P Nurmi et al.\nIcons designed by Daniel Ferguson\n"
        acceptButtonText: "OK"
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
                text: "About BelleChat"
                onClicked: {
                    aboutDialog.open()
                }
            }
        }
    }


    SelectionDialog {
        property int count: 0
        id: selectChannelDialog
        model: ChannelModel
        titleText: "Select Channel (" + count + " channels):"
        delegate: ListItem {
            Column {
                ListItemText {
                    role: "Title"
                    text: channel + " (" + users + ")"
                }
                Text {
                    text: topic
                    color: platformStyle.colorNormalLight
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
            }
            onClicked: {
                selectChannelDialog.selectedIndex = index
                selectChannelDialog.accept()
            }
        }
        onAccepted: {
            var channel = model[selectedIndex].channel
            //console.log("Channel:", channel)
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
                    showChannelDialog(Session.lastChannel)
                }
            }

            MenuItem {
                id: partChannel
                text: "Leave " + Session.currentChannel
                visible: false
                onClicked: {
                    leaveChannel(Session.currentChannel)
                }
            }

            MenuItem {
                id: selectChannelFromList
                text: "Select from list"
                visible: true
                onClicked: {
                    fetchingChannelsDialog.open()
                    Session.getChannelList("")
                }
            }           
        }
    }

    QueryDialog {
        id: queryDisconnect
        titleText: "Disconnect from " + appConnectionSettings.host +"?"
        message: "Are you sure you wish to disconnect from the server?\n"
        acceptButtonText: "Ok"
        rejectButtonText: "Cancel"

        onAccepted:  { // If 'Ok' pressed.
            //console.log("Disconnecting from server...")
            userDisconnected = true // Supress notification of disconnection
            Session.quit(appConnectionSettings.quitMessage)
            initialPage.closeAllTabs()
            Session.close()
        }
    }

    QueryDialog {
        id: queryQuit
        titleText: "Quit BelleChat?"
        message: "You are still connected to the server!\n Are you sure you wish to quit?\n"
        acceptButtonText: "Ok"
        rejectButtonText: "Cancel"
        onAccepted: {
            Session.quit(appConnectionSettings.quitMessage)
            tryingToQuit = true
            exit()
        }
    }

    QueryDialog {
        id: queryCancelConnect
        titleText: "Cancel connection?"
        message: "Are you sure you wish to cancel the connection?\n"
        acceptButtonText: "Ok"
        rejectButtonText: "Cancel"
        onAccepted: {
            var outputString = "Connection to " + appConnectionSettings.host + " cancelled!"
            initialPage.outputToTab("Server", outputString)
            Session.close()
        }
    }

    ToolBarLayout {
        id: serverToolbar
        ToolButton {
            id: buttonQuit
            flat: true
            iconSource: "toolbar-back"
            onClicked: {
                // If we're connected, we need to close the connection before
                // we quit. Open a dialog to ask if the user is sure.
                if (Session.connected)
                {
                    queryQuit.open()

                }
                else
                {
                    Session.quit(ConnectionSettings.quitMessage)
                    tryingToQuit = true
                    exit()
                }
            }
            //            onPressedChanged: exitTooltip.visible = pressed

            //            ToolTip {
            //                id: exitTooltip
            //                target: buttonQuit
            //                text: "Exit"
            //                visible: buttonQuit.pressed
            //            }
        }

        ToolButton {
            id: buttonConnect
            flat: true
            state: "Disconnected"
            states: [
                State {
                    name: "Connected"
                    PropertyChanges { target: buttonConnect; iconSource: "icon-disconnect.svg"}
                    PropertyChanges { target: initialPage; connected: true }
                    PropertyChanges { target: buttonJoin; enabled: true }
                },
                State {
                    name: "Connecting"
                    PropertyChanges { target: buttonConnect; iconSource: "icon-connect.svg"}

                },
                State {
                    name: "Disconnected"
                    PropertyChanges { target: buttonConnect; iconSource: "icon-connect.svg" }
                    PropertyChanges { target: buttonJoin; enabled: false }
                    PropertyChanges { target: buttonUsers; enabled: false }
                    PropertyChanges { target: initialPage; connected: false }
                }

            ]

            onClicked: {
                if (state === "Connected")
                    queryDisconnect.open()
                else if (state === "Disconnected")
                {
                    state = "Connecting"
                    Session.updateConnection()
                    var connectingString = "Connecting to " + appConnectionSettings.host +"..."
                    initialPage.outputToTab("Server", connectingString)
                    Session.open()
                }
                else //state === "Connecting"
                {
                    queryCancelConnect.open()
                }
            }
            //            onPressedChanged: connectTooltip.visible = pressed
            //            ToolTip {
            //                id: connectTooltip
            //                target: buttonConnect
            //                text: (Session.connected)? "Disconnect from server" : "Connect to server"
            //                visible: buttonConnect.pressed
            //            }
        }



        ToolButton {
            id: buttonJoin
            iconSource: (enabled)?"icon-channels.svg":"icon-channels-disabled.svg"
            flat:true
            visible: true
            enabled: false
            onClicked: {
                //                channelsTooltip.visible = false
                menuJoin.open()
            }
            //            onPressedChanged: channelsTooltip.visible = pressed
            //            ToolTip {
            //                id: channelsTooltip
            //                target: buttonJoin
            //                text: "Channels"
            //                visible: buttonJoin.pressed
            //            }
        }



        ToolButton {
            id: buttonUsers
            iconSource: (enabled)?"icon-users.svg":"icon-users-disabled.svg"
            flat:true
            enabled: false
            onClicked: {
                Session.getNicknames(Session.currentChannel)
                var page = userPageFactory.createObject(window)
                //page.userCount = count;
                pageStack.push(page)
            }
            //            onPressedChanged: usersTooltip.visible = pressed
            //            ToolTip {
            //                id: usersTooltip
            //                target: buttonUsers
            //                text: "Users"
            //                visible: buttonUsers.pressed
            //            }
        }



        ToolButton {
            id: buttonMenu
            iconSource: "toolbar-menu"
            flat: true
            onClicked: {
                //                moreTooltip.visible = false
                menuMain.open()
            }
            //            onPressedChanged: moreTooltip.visible = pressed
            //            ToolTip {
            //                id: moreTooltip
            //                target: buttonMenu
            //                text: "More"
            //                visible: buttonMenu.pressed
            //            }
        }


    }

    Component.onCompleted: {
        var outputString = "Welcome to BelleChat " + Version +"!\n"
        initialPage.outputToTab("Server", outputString)
        initialPage.outputToTab("Server", "Click the Connect button to connect to the IRC server.")
    }

    function joinChannel(channel)
    {
        initialPage.outputToTab("Server", "Joining channel " + channel + " ...")
        // This is where the actual channel joining code goes...
        Session.joinChannel(channel)

    }

    function leaveChannel(channel)
    {
        Session.currentChannel = Session.lastChannel
        initialPage.selectTab(Session.lastChannel)
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
            //console.log("Quitting...")
            Qt.quit()
        }
    }
}
