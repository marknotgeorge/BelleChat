import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import BelleChat 1.0

PageStackWindow {
    id: window
    property string lastChannel: "Server"
    property string currentChannel: "Server"
    property bool userDisconnected: false
    property bool tryingToQuit: false
    property bool namesListRequested: false

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

    InfoBanner {
        id: connectFailedBanner
    }

    BusyIndicator {
        id: appBusy
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        running: false
        visible: false
    }

    Timer {
        id: connectionTimer
        interval: 15000
        onTriggered: {
            var failureString = "Could not connect to " + appConnectionSettings.host + ".\n Please check your settings."
            Session.close()
            connectFailedBanner.text = failureString
            initialPage.outputToTab("Server", failureString)
            connectFailedBanner.open()
            menuToDisconnected()
        }
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


    Connections {
        target: Session
        onOutputString: {
            initialPage.outputToTab(channel, output)
        }
        onConnected: {
            //connectServer.visible = false
            buttonConnect.iconSource = "icon-disconnect.svg"
            buttonConnect.enabled = true
            connectionTimer.stop()
            initialPage.outputToTab("Server", "Connected to " + appConnectionSettings.host + "!")
            //disconnectServer.text = "Disconnect from " + appConnectionSettings.host
            //disconnectServer.visible = true
            buttonJoin.enabled = true
            channelsTooltip.text = "Disconnect from server"
            if (appConnectionSettings.showChannelList)
            {
                appBusy.visible = true
                appBusy.running = true
                Session.getChannelList("")
            }

        }
        onDisconnected: {
            if (!userDisconnected)
            {
                var failureString = "Connection to " + appConnectionSettings.host + " failed."
                Session.close()
                connectFailedBanner.text = failureString
                initialPage.outputToTab("Server", failureString)
                connectFailedBanner.open()
            }

            userDisconnected = false;
            initialPage.closeAllTabs()
            if (!tryingToQuit)
            {
                initialPage.clearTab("Server")
                initialPage.outputToTab("Server", "Disconnected from " + appConnectionSettings.host + ".")
                menuToDisconnected()
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
            appBusy.visible = false
            appBusy.running = false
            if (numberOfChannels > 0)
            {
                selectChannelDialog.count = numberOfChannels
                selectChannelDialog.open()
            }
            else
                noChannelsDialog.open()
        }
        onSocketError: {
            connectionTimer.stop()
            var failureString = "Connection to " + appConnectionSettings.host + " failed."
            Session.close()
            connectFailedBanner.text = failureString
            initialPage.outputToTab("Server", failureString)
            connectFailedBanner.open()
            menuToDisconnected()
        }
        onNewNamesList: {
            // A list of names are sent when a user joins a channel. By setting namesListRequested
            // to true only when the user pressed the Users ToolButton, showing the Users page when
            // this list arrives is supressed.
            if (namesListRequested)
            {
                // Kill the BusyIndicator...
                appBusy.visible = false
                appBusy.running = false
                //console.log("Names list arrived for:" + channel)
                if (channel === currentChannel)
                {
                    // Only show the page if the current tab is still selected...
                    var page = userPageFactory.createObject(window)
                    page.userCount = count;
                    pageStack.push(page)
                }
                // Clear the namesListRequested flag...
                namesListRequested = false;
            }
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
        message: "BelleChat " + Version + "\nBuild " + Build + "\n© 2011-12 Mark Johnson\nUses Communi written by J-P Nurmi et al.\n"
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
                    appBusy.visible = true
                    appBusy.running = true
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
            anchors.leftMargin: platformStyle.paddingLarge
            anchors.right: parent.right
            anchors.rightMargin: platformStyle.paddingLarge
            wrapMode: Text.WordWrap
            color: platformStyle.colorNormalLight
        }

        buttonTexts: ["Ok", "Cancel"]
        onButtonClicked: {
            if (!index) { // If 'Ok' pressed.
                //console.log("Disconnecting from server...")
                userDisconnected = true // Supress notification of disconnection
                initialPage.closeAllTabs()
                Session.close()
            }
        }
    }

    CommonDialog {
        id: queryQuit
        titleText: "Quit BelleChat?"
        content: Text {
            text: "You are still connected to the server!\n Are you sure you wish to quit?"
            anchors.left: parent.left
            anchors.leftMargin: platformStyle.paddingLarge
            anchors.right: parent.right
            anchors.rightMargin: platformStyle.paddingLarge
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

    ToolBarLayout {
        id: serverToolbar
        ToolButton {
            id: buttonQuit
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

            ToolTip {
                id: exitTooltip
                target: buttonQuit
                text: "Exit"
                visible: buttonQuit.pressed
            }
        }

        ToolButton {
            id: buttonConnect
            flat: true
            iconSource: (Session.connected)?"icon-disconnect.svg":"icon-connect.svg"
            onClicked: {
                if (Session.connected)
                    queryDisconnect.open()
                else
                {
                    //enabled = false
                    Session.updateConnection()
                    var connectingString = "Connecting to " + appConnectionSettings.host +"..."
                    initialPage.outputToTab("Server", connectingString)
                    connectionTimer.start()
                    Session.open()
                }
                onPlatformReleased: connectTooltip.visible = false
            }
            ToolTip {
                id: connectTooltip
                target: buttonConnect
                text: "Connect to server"
                visible: buttonConnect.pressed
            }
        }

        ToolButton {
            id: buttonJoin
            iconSource: (enabled)?"icon-channels.svg":"icon-channels-disabled.svg"
            flat:true
            visible: true
            enabled: false
            onClicked: {
                menuJoin.open()
            }
            onPlatformReleased: channelsTooltip.visible = false
            ToolTip {
                id: channelsTooltip
                target: buttonJoin
                text: "Channels"
                visible: buttonJoin.pressed
            }

        }

        ToolButton {
            id: buttonUsers
            iconSource: (enabled)?"icon-users.svg":"icon-users-disabled.svg"
            flat:true
            enabled: false
            onClicked: {
                appBusy.visible = true
                appBusy.running = true
                namesListRequested = true
                Session.onRefreshNames(currentChannel)
            }
            onPlatformReleased: usersTooltip.visible = false
            ToolTip {
                id: usersTooltip
                target: buttonUsers
                text: "Users"
                visible: buttonUsers.pressed
            }
        }

        ToolButton {
            id: buttonMenu
            iconSource: "toolbar-menu"
            flat: true
            onClicked: {
                menuMain.open()
            }
            onPlatformReleased: moreTooltip.visible = false
            ToolTip {
                id: moreTooltip
                target: buttonMenu
                text: "More"
                visible: buttonMenu.pressed
            }
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
            //console.log("Quitting...")
            Qt.quit()
        }
    }



    function menuToDisconnected()
    {
        connectionTimer.stop()
        buttonConnect.enabled = true
        buttonConnect.iconSource = "icon-connect.svg"
        buttonJoin.enabled = false
        buttonUsers.enabled = false
        connectTooltip.text = "Connect to server"
    }

}


