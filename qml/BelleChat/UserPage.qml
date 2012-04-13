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
            if (user.name === Session.removeMode(userView.currentItem.username))
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
        onUserCountChanged: {
            userHeadingText.text = Session.currentChannel + ": " + newUserCount + " user(s)"
        }
    }

    tools: ToolBarLayout {
        id: userToolBarLayout
        ToolButton {
            id: userBackButton
            flat: true
            iconSource: "toolbar-back"
            onClicked: {
                pageStack.pop()
            }
//            onPressedChanged: userBackToolTip.visible = pressed
//            ToolTip {
//                id: userBackToolTip
//                text: "Back"
//                target: userBackButton
//                visible: userBackButton.pressed
//            }
        }

        ToolButton {
            id: refreshToolButton
            flat: true
            iconSource: "toolbar-refresh"
            onClicked: {
                Session.sendNames(Session.currentChannel)
            }
//            onPressedChanged: refreshToolTip.visible = pressed
//                ToolTip {
//                    id: refreshToolTip
//                    text: "Refresh names"
//                    target: refreshToolButton
//                    visible: userBackButton.pressed
//                }
        }

        ToolButton {
            id: moreToolButton
            flat: true
            iconSource: "toolbar-menu"
            visible: false

        }

    }

    ListHeading {
        id: userHeading
        anchors { left: parent.left; right: parent.right; top: parent.top; }
        ListItemText {
            id: userHeadingText
            anchors.fill: userHeading.paddingItem
            role: "Heading"
            text: Session.currentChannel + ": " + Session.userCount + " user(s)"
        }
    }

    ListView {
        id: userView
        anchors { left: parent.left;
            right: parent.right;
            top: userHeading.bottom;
            bottom: parent.bottom;
            leftMargin: platformStyle.paddingMedium;
            rightMargin: platformStyle.paddingMedium;
        }
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
                Session.kick(Session.currentChannel, userView.currentItem.username, text)
                pageStack.pop()
            }
        }

        ContextMenu {
            id: userContextMenu
            MenuLayout {
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
                        Session.onInputReceived(Session.currentChannel, slapString)
                        pageStack.pop()
                    }
                }
            }
        }
    }
}

