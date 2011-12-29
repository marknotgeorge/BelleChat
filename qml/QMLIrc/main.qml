import QtQuick 1.1
import com.nokia.symbian 1.1

PageStackWindow {
    id: window
    property string lastChannel: "#LastChannel"
    property string currentChannel: ""
    initialPage: mainPage
    platformSoftwareInputPanelEnabled: true

    Component {
        id: settingsPageFactory
        SettingsPage {}
    }


    Connections {
        target: Session
        onOutputString: {
            mainPage.outputToTab(channel, output);
        }
        onConnected: {
            //console.log("Connected to server!");
            connectServer.visible = false;
            mainPage.outputToTab("Server", "Connected to " + Connection.host + "!")
            disconnectServer.text = "Disconnect from " + Connection.host;
            disconnectServer.visible = true;
            buttonJoin.enabled = true;
        }
        onDisconnected: {
            buttonJoin.enabled = false;
            disconnectServer.visible = false;
            connectServer.text = "Connect to " + Connection.host;
            connectServer.enabled = true;
            connectServer.visible = true;
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
        text: lastChannel
        acceptButtonText: "OK"
        rejectButtonText: "Cancel"
        onAccepted: {
            joinChannel(text)
        }
        onRejected: {

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
                visible: false
                onClicked: {
                    selectChannelDialog.open()
                }
            }
        }
    }

    QueryDialog {
        id: queryDisconnect
        titleText: "Disconnect from " + Connection.host +"?"
        message: "Are you sure you wish to disconnect?"
        acceptButtonText: "Ok"
        rejectButtonText: "Cancel"
        onAccepted: {
            Session.close();
        }
    }


    Menu {
        id: menuConnect
        content: MenuLayout {
            MenuItem {
                id: connectServer
                text: "Connect to " + Connection.host
                onClicked: {
                    Session.updateConnection();
                    var connectingString = "Connecting to " + Connection.host +"..."
                    text = connectingString
                    //mainPage.outputToTab("Server", connectingString)
                    connectServer.enabled = false;
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

            MenuItem {
                id: menuItemSettings
                text: "Settings"
                onClicked: {
                    var settingsPage = settingsPageFactory.createObject(mainPage);
                    pageStack.push(settingsPage)
                }
            }
        }
    }


    ToolBarLayout {
        id: serverToolbar

        ToolButton {
            flat: true
            iconSource: "close_stop.svg"
            onClicked: pageStack.depth <= 1 ? Qt.quit() : pageStack.pop()
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
                var curtab = mainPage.currentTabText
                if(curtab === "Server" || curtab === "")
                    partChannel.visible = false;
                else
                    partChannel.visible = true;
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
                aboutDialog.open()
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
        Session.partChannel(channel)
        mainPage.closeTab(channel)

    }

    function showChannelDialog()
    {
        enterChannelDialog.open()
    }

}


