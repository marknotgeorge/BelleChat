// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: window

    property alias detailHeading: userDetailHeadingText.text
    property alias user: userData.text
    property alias server: serverData.text
    property alias channels: channelsData.text
    property alias onlineSince: onlineSinceData.text
    tools: ToolBarLayout {
        id: settingsToolBarLayout

        ToolButton {
            flat: true
            iconSource: "toolbar-back"
            onClicked: {
                pageStack.pop()
            }            
        }

        ToolButton {
            id: kickButton
            flat: true
            iconSource: "icon-kick.svg"
            onClicked: {
                enterReason.open()
            }
        }

        ToolButton {
            id: slapButton
            flat: true
            iconSource: "icon-fish.svg"
            onClicked: {
                var slapString = "/me slapped " + userView.currentItem.username + " with a wet kipper!"
                Session.onInputReceived(Session.currentChannel, slapString)
                pageStack.pop(initialPage)
            }
        }

        ToolButton {
            flat: true
            iconSource: "toolbar-menu"
            visible: false
        }
    }

    TextPickerDialog {
        id: enterReason
        titleText: "Enter Kick reason"
        placeholderText: "Enter reason for kick..."
        acceptButtonText: "Ok"
        rejectButtonText: "Cancel"
        onAccepted: {
            Session.kick(Session.currentChannel, userView.currentItem.username, text)
            pageStack.pop(initialPage)

        }
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
                id: userLabel
                role: "Title"
                text: "User is"
            }
            ListItemText {
                id: userData
                role: "Subtitle"
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
            ListItemText {
                id: serverLabel
                role: "Title"
                text: "Online via"
            }
            ListItemText {
                id: serverData
                role: "Subtitle"
            }
            ListItemText {
                id: channelsLabel
                role: "Title"
                text: "On channels"
            }
            ListItemText {
                id: channelsData
                role: "Subtitle"
            }
            ListItemText {
                id: onlineSinceLabel
                role: "Title"
                text: "Online since"
            }
            ListItemText {
                id: onlineSinceData
                role: "Subtitle"
            }
        }
    }
}



