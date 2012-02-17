// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: window
    tools: ToolBarLayout {
        id: settingsToolBarLayout

        ToolButton {
            flat: true
            iconSource: "toolbar-back"
            onClicked: {
                pageStack.pop()
            }
        }
    }

    ListHeading {
        id: userDetailHeading
        anchors { left: parent.left; right: parent.right; top: parent.top; }
        ListItemText {
            id: userDetailHeadingText
            role: "Heading"
            text: userView.currentItem.username + " (" + userView.currentItem.propername + ")"
        }
    }
    Column {
        id: userDetailColumn
        anchors {left: parent.left; right: parent.right; top: userDetailHeading.bottom; bottom: parent.bottom;}

        ListItemText {
            id: userLabel
            role: "Title"
            text: "User is"
        }
        ListItemText {
            id: userData
            role: "Subtitle"
            text: UserModel[userView.currentIndex].user
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
            text: UserModel[userView.currentIndex].server
        }
        ListItemText {
            id: channelsLabel
            role: "Title"
            text: "On channels"
        }
        ListItemText {
            id: channelsData
            role: "Subtitle"
            text: UserModel[userView.currentIndex].channels
        }
        ListItemText {
            id: onlineSinceLabel
            role: "Title"
            text: "Online since"
        }
        ListItemText {
            id: onlineSinceData
            role: "Subtitle"
            text: Qt.formatDateTime(UserModel[userView.currentIndex].onlineSince, Qt.TextDate)
        }
    }
}




