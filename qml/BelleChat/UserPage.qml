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
                var page = userDetailPageFactory.createObject(window, {userItem: user})
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
            onPressAndHold: {
                // Only show the context menu if the user's not us...
                if (Session.removeMode(userView.currentItem.username) !== Session.nickName)
                    userContextMenu.open()
            }
            onClicked: {
                Session.whoIs(Session.removeMode(userView.currentItem.username))
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
                    visible: false
                    text: "Kick"
                    onClicked: {
                        enterReason.open()
                    }
                }
                MenuItem {
                    id: slapUser
                    text: "Slap " + Session.removeMode(userView.currentItem.username)
                    onClicked: {
                        var slapString = "/me slapped "
                                + Session.removeMode(userView.currentItem.username)
                                + " with a wet kipper!"
                        Session.onInputReceived(Session.currentChannel, slapString)
                        pageStack.pop()
                    }
                }
                MenuItem {
                    id: queryUser
                    text: "Query " + Session.removeMode(userView.currentItem.username)
                    onClicked: {
                        var user = Session.removeMode(userView.currentItem.username)
                        var button = initialPage.findButton(user)
                        if (button)
                            initialPage.selectTab(user)
                        else
                            initialPage.createTab(user)
                        pageStack.pop()
                    }
                }
                MenuItem {
                    id: ctcpUser
                    text: "User Information"
                    platformSubItemIndicator: true
                    onClicked: ctcpMenu.open()
                }
            }
        }
        ContextMenu {
            id: ctcpMenu
            MenuLayout {
                MenuItem {
                    id: pingUser
                    text: "Ping " + Session.removeMode(userView.currentItem.username)
                    onClicked: {
                        var timeStamp = new Time()
                        var requestString = "PING " + Qt.formatTime(timeStamp)
                        ctcpRequest(requestString)
                    }
                }
                MenuItem {
                    id: timeUser
                    text: "Get " + Session.removeMode(userView.currentItem.username) + "'s local time"
                    onClicked: ctcpRequest("TIME")
                }
                MenuItem {
                    id: versionUser
                    text: "Get " + Session.removeMode(userView.currentItem.username) + "'s client version"
                    onClicked:
                    {
                        ctcpRequest("VERSION")
                    }
                }
                MenuItem {
                    id: infoUser
                    text: "Get " + Session.removeMode(userView.currentItem.username) + "'s info"
                    onClicked: ctcpRequest("USERINFO")
                }
            }
        }
    }

    function ctcpRequest(request)
    {
        var user = Session.removeMode(userView.currentItem.username)
        Session.sendCtcpRequest(user, request)
        pageStack.pop()
    }
}


