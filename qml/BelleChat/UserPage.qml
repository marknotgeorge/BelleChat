// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: window
    property int userCount: 0
    property bool whoisRequested: false

    Component {
        id: userDetailPageFactory
        UserDetailPage {}
    }

    Connections {
        target: Session
        onWhoIsReceived: {
            if (whoisRequested)
            {
                if (user === userView.currentItem.username)
                {
                    var page = userDetailPageFactory.createObject(window)
                    pageStack.push(page)
                    whoisRequested = false
                }
            }
        }
    }

    tools: ToolBarLayout {
        id: userToolBarLayout
        ToolButton {
            flat: true
            iconSource: "toolbar-back"
            onClicked: {
                pageStack.pop()
            }
        }
    }

    ListHeading {
        id: userHeading
        anchors { left: parent.left; right: parent.right; top: parent.top; }
        ListItemText {
            id: userHeadingText
            role: "Heading"
            text: currentChannel + ": " + userCount + " users"
        }
    }

    ListView {
        id: userView
        anchors { left: parent.left; right: parent.right; top: userHeading.bottom; bottom: parent.bottom; }
        clip: true
        model: UserModel
        delegate: UserListItem {
            username: name
            propername: realname
            complete: dataComplete
            onPressAndHold: userContextMenu.open()
            onClicked: {
                if (complete)
                {
                    var page = userDetailPageFactory.createObject(window)
                    pageStack.push(page)
                }
                else
                {
                    whoisRequested = true
                    Session.whoIs(userView.currentItem.username)
                }
            }
        }

        ScrollDecorator {
            id: userDecorator
            flickableItem: userView
        }

        TextPickerDialog {
            id: enterReason
            titleText: "Enter Kick reason"
            placeholderText: "Enter reason for kick..."
            acceptButtonText: "Ok"
            rejectButtonText: "Cancel"
            onAccepted: {
                Session.kick(currentChannel, userView.currentItem.username, text)
                pageStack.pop()
            }
        }

        ContextMenu {
            id: userContextMenu
            MenuLayout {
                MenuItem {
                    id: menuIgnore
                    text: "Whois"
                    onClicked: {
                        Session.whoIs(userView.currentItem.username)
                        whoisRequested = true
                    }

                }
                MenuItem{
                    id: kickUser
                    text: "Kick"
                    onClicked: {
                        enterReason.open()
                    }
                }
                MenuItem {
                    id: slapUser
                    text: "Slap"
                    onClicked: {
                        var slapString = "/me slapped " + userView.currentItem.username + " with a wet kipper!"
                        Session.onInputReceived(currentChannel, slapString)
                        pageStack.pop()
                    }
                }
            }
        }
    }
}

