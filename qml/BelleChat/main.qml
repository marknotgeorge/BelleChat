import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import BelleChat 1.0
import "HelpText.js" as HelpText

PageStackWindow {
    id: window
    property bool userDisconnected: false
    property bool tryingToQuit: false
    property bool namesListRequested: false
    property bool channelListCancelled: false
    property bool openServerSettings: false

    initialPage: MainPage { tools: serverToolbar }
    platformSoftwareInputPanelEnabled: true

    onOrientationChangeFinished: {
        // This should fix a bug where the output ListView is not at the bottom
        // after an orientation change.
        initialPage.dropToBottom()

    }

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

    Component {
        id: infoPageFactory
        InfoPage {}
    }

    Component {
        id: startPageFactory
        StartPage {}
    }

    Component {
        id: errorBannerFactory
        InfoBanner {
            iconSource: "icon-error.svg"
        }
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

    QueryDialog {
        id: connectionTimeoutDialog
        acceptButtonText: "Ok"
        titleText: "Unable to connect."
        message: "Cannot connect to " + Session.host + ". Please check server settings and your Internet connection.\n"
    }


    WaitDialog {
        id: fetchingChannelsDialog
        titleText: "Fetching list of channels..."
        onButtonClicked: {
            channelListCancelled = true
            close()
        }
    }

    WaitDialog {
        id: connectingDialog
        titleText: "Connecting to " + Session.host + "..."
        onButtonClicked: {
            var outputString = "Connection to " + appConnectionSettings.host + " cancelled!"
            initialPage.outputToTab("Server", outputString)
            Session.close()
            buttonConnect.state = "Disconnected"
        }
    }

    Timer {
        id: connectionTimer
        interval: appConnectionSettings.timeoutInterval * 1000
        onTriggered: {
            Session.close()
            connectingDialog.close()
            connectionTimeoutDialog.open()
        }
    }

    TextPickerDialog {
        id: channelKeyDialog
        property string channel: ""
        placeholderText: "Enter the key..."
        acceptButtonText: "Ok"
        rejectButtonText: "Cancel"
        onAccepted: {
            // Try to join the protected channel...
            Session.joinProtectedChannel(channel, text)
        }
    }


    Connections {
        target: Session
        onOutputString: {
            initialPage.outputToTab(channel, output)
        }
        onConnected: {
            buttonConnect.state = "Connected"
            connectingDialog.close()
            connectionTimer.stop()
            initialPage.outputToTab("Server", "Connected to " + appConnectionSettings.host + "!")
            if (appConnectionSettings.showChannelList)
            {
                fetchingChannelsDialog.open()
                Session.getChannelList("")
            }
            if (appConnectionSettings.autoJoinChannels)
            {
                Session.autoJoinChannels()
            }

        }
        onDisconnected: {
            if (!userDisconnected)
            {
                var failureString = "Connection to " + appConnectionSettings.host + " failed."
                Session.close()
                initialPage.outputToTab("Server", failureString)
            }
            connectionTimer.stop()
            connectingDialog.close()

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
            connectionTimer.stop()
            connectingDialog.close()
            initialPage.outputToTab("Server", failureString)
            buttonConnect.state = "Disconnected"
            connectionTimeoutDialog.open()
        }
        onQueryReceived: {
            var button = initialPage.findButton(sender)
            if(button)
                initialPage.outputToTab(sender, message)
            else
            {
                initialPage.createTab(sender)
                initialPage.outputToTab(sender, message)
            }
        }
        onIsAwayChanged: {
            awayMenu.text = (newIsAway)? "Clear Away":"Set Away"
        }
        onChannelRequiresKey: {
            // A key is needed to join a protected channel.
            // Open a TextPickerDialog to collect the key.
            channelKeyDialog.channel = channel
            channelKeyDialog.titleText = channel + " is a protected channel."
            channelKeyDialog.open()
        }
        onDisplayError: {
            // Display an InfoBanner with an error icon
            var banner = errorBannerFactory.createObject(window)

            banner.text = errorString
            banner.open()
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

    TextPickerDialog {
        id: awayMessageDialog
        titleText: "Away message"
        placeholderText: "Set away message..."
        text: appConnectionSettings.awayMessage
        acceptButtonText: "Ok"
        rejectButtonText: "Cancel"
        onAccepted: {
            Session.markAway(true)
        }
    }

    Menu {
        id: menuMain
        content: MenuLayout {
            MenuItem {
                id: menuItemSettings
                text: "Settings"
                onClicked: {
                    var settingsPage = settingsPageFactory.createObject(initialPage)
                    pageStack.push(settingsPage)
                }
            }

            MenuItem {
                id: menuItemHelp
                text: "Help"
                onClicked: {
                    var helpPage = infoPageFactory.createObject(initialPage)
                    helpPage.text = HelpText.mainHelp
                    pageStack.push(helpPage)
                }
            }

            MenuItem {
                id: menuItemAbout
                text: "About BelleChat"
                onClicked: {
                    aboutDialog.open()
                }
            }

            MenuItem {
                id: menuItemExit
                text: "Exit"
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
            }
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
                id: awayMenu
                text: (Session.isAway)?"Clear Away":"Set Away"
                onClicked:
                {

                    if (Session.isAway)
                        Session.markAway(false)
                    else
                    {
                        awayMessageDialog.open()
                    }
                }
            }

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
                id: closeQuery
                text: "Close tab " + Session.currentChannel
                visible: false
                onClicked: {
                    leaveChannel(Session.currentChannel)
                }
            }

            MenuItem {
                id: selectChannelFromList
                text: "List Channels"
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
            connectionTimer.stop()
        }
    }

    QueryDialog {
        id: noServerErrorDialog
        titleText: "No server entered!"
        message: "Enter a valid server in Server Settings before you try to connect.\n"
        acceptButtonText: "Ok"
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
                    Session.updateConnection()
                    if (Session.host === "")
                    {
                        noServerErrorDialog.open()
                    }
                    else
                    {
                        state = "Connecting"
                        var connectingString = "Connecting to " + appConnectionSettings.host +"..."
                        initialPage.outputToTab("Server", connectingString)
                        Session.open()
                        connectingDialog.open()
                        connectionTimer.start()
                    }
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

        // Open the StartPage
        if (!appConnectionSettings.supressStartPage)
        {
            var page = startPageFactory.createObject(initialPage)
            pageStack.push(page)
        }
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
