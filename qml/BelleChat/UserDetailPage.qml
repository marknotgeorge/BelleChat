// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import BelleChat 1.0

Page {
    id: window

    property WhoIsItem userItem


    tools: ToolBarLayout {
        id: settingsToolBarLayout

        ToolButton {
            flat: true
            iconSource: "toolbar-back"
            onClicked: {
                pageStack.pop(initialPage)
            }
        }
        // TODO: Implement mode handling
        /*
       ToolButton {
            id: opButton
            flat: false
            visible: true
            checkable: true
            checked: true
            text: "Op"
            onCheckedChanged: {
                kickUser.visible = checked
            }

        }

        ToolButton {
            id: voiceButton
            flat: false
            checkable: true
            checked: false
            visible: true
            text: "Voice"

        }
*/
        ToolButton {
            id: slapButton
            flat: true
            visible: (Session.removeMode(userItem.name) !== Session.nickName)
            iconSource: "icon-fish.svg"
            onClicked: {
                var slapString = "/me slapped " + userItem.name + " with a wet kipper!"
                Session.onInputReceived(Session.currentChannel, slapString)
                pageStack.pop(initialPage)
            }
        }
        ToolButton {
            id: queryButton
            flat: true
            visible: (Session.removeMode(userItem.name) !== Session.nickName)
            iconSource: "icon-query.svg"
            onClicked: {
                var user = Session.removeMode(userItem.name)
                var button = initialPage.findButton(userItem.name)
                if (button)
                    initialPage.selectTab(userItem.name)
                else
                    initialPage.createTab(userItem.name)
                pageStack.pop(initialPage)
            }
        }
        ToolButton {
            flat: true
            iconSource: "toolbar-menu"
            visible: true
            onClicked: ctcpMenu.open()
        }
    }

    Menu {
        id: ctcpMenu
        MenuLayout {
            MenuItem {
                id: pingUser
                text: "Ping " + userItem.name
                onClicked: {
                    var requestString = "PING " + Session.getTimeString()
                    ctcpRequest(requestString)
                    pageStack.pop(initialPage)
                }
            }
            MenuItem {
                id: timeUser
                text: "Get " + userItem.name + "'s local time"
                onClicked: {
                    ctcpRequest("TIME")
                    pageStack.pop(initialPage)
                }
            }
            MenuItem {
                id: versionUser
                text: "Get " + userItem.name + "'s client version"
                onClicked: {
                    ctcpRequest("VERSION")
                    pageStack.pop(initialPage)
                }
            }
            MenuItem {
                id: infoUser
                text: "Get " + userItem.name + "'s info"
                onClicked: {
                    ctcpRequest("USERINFO")
                    pageStack.pop(initialPage)
                }
            }
        }
    }


    function ctcpRequest(request)
    {
        Session.sendCtcpRequest(userItem.name, request)
    }


    ScrollDecorator {
        id:userDetailScroll
        flickableItem: userDetailFlickable
    }

    ListHeading {
        id: userDetailHeading
        anchors { left: parent.left; right: parent.right; top: parent.top; }
        ListItemText {
            anchors.fill: userDetailHeading.paddingItem
            id: userDetailHeadingText
            role: "Heading"
            text: userItem.name + "(" + userItem.realname + ")"
        }
    }

    Flickable {
        id: userDetailFlickable
        anchors {
            top: userDetailHeading.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        contentHeight: userDetailColumn.height
        clip: true

        Column {
            id: userDetailColumn
            anchors.fill: parent
            spacing: platformStyle.paddingMedium

            ListItemText {
                id:noInfoAvailable
                role: "Title"
                text: "No information available"
                visible: !(userLabel.visible || serverLabel.visible ||
                           channelsLabel.visible || onlineSinceLabel.visible ||
                           clientVersionLabel.visible || userInfoLabel.visible)
            }

            ListItemText {
                id: userLabel
                role: "Title"
                text: "User is"
                visible: userData.text.length
            }
            ListItemText {
                id: userData
                role: "Subtitle"
                text: userItem.user
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                visible: text.length
            }
            ListItemText {
                id: serverLabel
                role: "Title"
                text: "Online via"
                visible: serverData.text.length
            }
            ListItemText {
                id: serverData
                role: "Subtitle"
                text: userItem.server
                visible: text.length
            }
            ListItemText {
                id: channelsLabel
                role: "Title"
                text: "On channels"
                visible: channelsData.text.length                
            }
            Label {
                id: channelsData
                width: parent.width
                wrapMode: Text.Wrap
                text: userItem.channels
                visible: text.length
            }
            ListItemText {
                id: onlineSinceLabel
                role: "Title"
                text: "Online since"
                visible: onlineSinceData.text.length
            }
            ListItemText {
                id: onlineSinceData
                role: "Subtitle"
                text: Qt.formatDateTime(userItem.onlineSince)
                visible: text.length
            }
            ListItemText {
                id: clientVersionLabel
                role: "Title"
                text: "Client information"
                visible: clientVersionData.text.length
            }
            ListItemText {
                id: clientVersionData
                role: "Subtitle"
                text: userItem.clientVersion
                visible: text.length
            }
            ListItemText {
                id: userInfoLabel
                role: "Title"
                text: "User information"
                visible: userInfoData.text.length
            }
            Text {
                id: userInfoData
                width: parent.width
                color: platformStyle.colorNormalLight
                font.pixelSize: platformStyle.fontSizeSmall
                wrapMode: Text.Wrap
                text: userItem.userInfo
                visible: text.length
            }
        }
    }
}




