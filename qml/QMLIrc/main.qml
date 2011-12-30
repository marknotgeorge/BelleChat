import QtQuick 1.1
import com.nokia.symbian 1.1

PageStackWindow {
    id: window
    property string lastChannel: "Server"
    property string currentChannel: "Server"
    property bool userDisconnected: false
    initialPage: mainPage
    platformSoftwareInputPanelEnabled: true

    Component {
        id: settingsPageFactory
        SettingsPage {}
    }

    CommonDialog {
        id: connectingProgressDlg
        buttonTexts: ["Cancel"]
        titleText: "Connecting to "
        content: ProgressBar {
            id: pb1
            indeterminate: true
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10

        }
        onButtonClicked: {
            var outputString = "Connection to " + Connection.host + " cancelled!"
            Session.close()
        }
    }


    Connections {
        target: Session
        onOutputString: {
            mainPage.outputToTab(channel, output);
        }
        onConnected: {
            connectServer.visible = false;
            connectingProgressDlg.close()
            mainPage.outputToTab("Server", "Connected to " + Connection.host + "!")
            disconnectServer.text = "Disconnect from " + Connection.host;
            disconnectServer.visible = true;
            buttonJoin.enabled = true;
        }
        onDisconnected: {
            if (!userDisconnected)
            {
                // Unexpected disconnection.
                //TODO: Insert some code to notify user.
            }
            userDisconnected = false;
            mainPage.closeChannelTabs()
            mainPage.clearTab("Server")
            mainPage.outputToTab("Server", "Disconnected from " + Connection.host + ".")
            disconnectServer.visible = false
            connectServer.text = "Connect to " + Connection.host
            connectServer.enabled = true
            connectServer.visible = true
            buttonJoin.enabled = false
        }
    }


    MainPage {
        id: mainPage
        tools: serverToolbar

    }

    CommonDialog {
        id: aboutDialog
        titleText: "About QMLIrc"
        content: Label {
            text: "QMLIrc " + Version.version() + "\n© 2011-12 MarkNotGeorge"
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
                    var settingsPage = settingsPageFactory.createObject(mainPage);
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
        // BOILERPLATE CODE
        model: ["#FirstChannel", "#SecondChannel", "#ThirdChannel"]
        onSelectedIndexChanged: {
            joinChannel(model[selectedIndex])
        }
    }

    TextPickerDialog {
        id: enterChannelDialog
        titleText: "Join channel:"
        placeholderText: "Enter channel name..."
        text: ""
        acceptButtonText: "OK"
        rejectButtonText: "Cancel"
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
                visible: currentChannel !== "Server"
                onClicked: {
                    leaveChannel(currentChannel)
                }
            }

            MenuItem {
                id: selectChannelFromList
                text: "Select from list"
                visible: false
                onClicked: {
                    selectChannelDialog.open()
                }
            }
        }
    }

    CommonDialog {
        id: queryDisconnect
        titleText: "Disconnect from " + Connection.host +"?"
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
                userDisconnected = true // Supress notification of discinnection
                Session.close()
                mainPage.closeChannelTabs()
                mainPage.clearTab("Server")
                mainPage.outputToTab("Server", "Disconnected from " + Connection.host + ".")
                disconnectServer.visible = false
                connectServer.text = "Connect to " + Connection.host
                connectServer.enabled = true
                connectServer.visible = true
                buttonJoin.enabled = false
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
                Session.close()
                exit()
            }
        }
    }

    Menu {
        id: menuConnect
        content: MenuLayout {
            MenuItem {
                id: connectServer
                text: "Connect to " + Connection.host
                visible: true
                onClicked: {
                    Session.updateConnection();
                    var connectingString = "Connecting to " + Connection.host +"..."
                    text = connectingString
                    mainPage.outputToTab("Server", connectingString)
                    connectingProgressDlg.titleText += Connection.host
                    connectingProgressDlg.open()
                    //connectServer.enabled = false;
                    Session.open();
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
                if (Session.sessionConnected())
                {
                    queryQuit.open()
                }
                else
                {
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
            enabled:false
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
        var outputString = "Welcome to QMLIrc " + Version.version() +"!\n"
        mainPage.outputToTab("Server", outputString)
    }

    function joinChannel(channel)
    {
        //mainPage.outputToTab("Server", "Joining channel " + channel + " ...")
        // This is where the actual channel joining code goes...
        Session.joinChannel(channel)
        mainPage.createTab(channel)
        // Set lastChannel to channel...
        lastChannel = channel
        currentChannel = channel
    }

    function leaveChannel(channel)
    {
        currentChannel = lastChannel
        Session.partChannel(channel)
        mainPage.selectTab(lastChannel)
        mainPage.closeTab(channel)
    }

    function showChannelDialog()
    {
        enterChannelDialog.open()
    }

    function exit()
    {
        if (window.pageStack.depth <= 1)
            Qt.quit()
        else
            window.pageStack.pop()
    }
}


