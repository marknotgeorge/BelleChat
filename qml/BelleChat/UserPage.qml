// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: window

    Component {
        id: userDetailPageFactory
        UserDetailPage {}
    }

    Connections {
        target: Session
        onWhoIsReceived: {
            // Check to see if the WhoIs received is still the selected
            // user...
            //console.log("Username: " + user.name)
            if (user.name === userView.currentItem.username)
            {
                var page = userDetailPageFactory.createObject(window)
                page.detailHeading = user.name + " (" + user.realname + ")"
                page.user = user.user
                page.server = user.server
                page.channels = user.channels
                page.onlineSince = Qt.formatDateTime(user.onlineSince, Qt.TextDate)
                pageStack.push(page)
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
            text: Session.currentChannel + ": " + Session.userCount + " users"
        }
    }

    ListView {
        id: userView
        anchors { left: parent.left; right: parent.right; top: userHeading.bottom; bottom: parent.bottom; }
        clip: true
        model: UserModel
        delegate: UserListItem {
            username: modelData
            propername: Session.getRealname(modelData)
            onPressAndHold: userContextMenu.open()
            onClicked: {
                Session.whoIs(userView.currentItem.username)
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

