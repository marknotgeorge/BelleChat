import QtQuick 1.1
import com.nokia.symbian 1.1

Window {
    id: window
    property string lastChannel: "#LastChannel"
    property string currentChannel: ""


    StatusBar {
        id: statusBar
        anchors.top: window.top

    }

    MainPage {
        id: mainPage
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; top: parent.top }
        tools: serverToolbar

    }

    SettingsPage {
        id: settingsPage
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; top: parent.top }
        tools: settingsToolBarLayout

    }

    PageStack {
        id: pageStack
        anchors { left: parent.left; right: parent.right; top: statusBar.bottom; bottom: toolBar.top }
        toolBar: toolBar
    }

    CommonDialog {
        id: aboutDialog
        titleText: "About QTIrc"
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
                onClicked: pageStack.push(settingsPage)
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
                id: joinLastChannel

                // The text in this menuItem will be the last channel joined
                text: "Join " + lastChannel
                onClicked: {
                    joinChannel(lastChannel)
                }
            }

            MenuItem {
                id: selectChannelFromList
                text: "Select from list"
                onClicked: {
                    selectChannelDialog.open()
                }
            }

            MenuItem {
                id: enterChannel
                text: "Enter channel name"
                onClicked: {
                    showChannelDialog(lastChannel)
                }

            }

        }
    }

    Menu {
        id: menuPart
        content: MenuLayout {
            MenuItem {
                id: partChannel
                text: "Leave " + currentChannel
                onClicked: {
                    leaveChannel()
                }

            }

            MenuItem {
                id: showUsers
                text: "Show users"
            }
        }
    }

    ToolBar {
        id: toolBar
        anchors.bottom: window.bottom

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
                if (currentChannel == "")
                    menuJoin.open()
                else
                    menuPart.open()

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



    ToolBarLayout {
        id: settingsToolBarLayout

        ToolButton {
            flat: true
            iconSource: "toolbar-back"
            onClicked: pageStack.pop()
        }
    }

    Component.onCompleted: {
        pageStack.push(mainPage)

    }

    function outputToServer(output)
    {
        mainPage.serverOutput += output
    }

    function outputToChannel(output)
    {
        mainPage.channelOutput += output
    }

    function joinChannel(channel)
    {
        outputToServer("Joining channel " + channel + " ...\n")
        // This is where the actual channel joining code goes...

        mainPage.showChannelOutput(channel)

        // Set lastChannel to channel...
        lastChannel = channel
        currentChannel = channel
    }

    function leaveChannel()
    {
        mainPage.hideChannelOutput()

        // This is where the channel leaving code goes...

        currentChannel = ""

    }

    function showChannelDialog()
    {
        enterChannelDialog.open()
    }

}

