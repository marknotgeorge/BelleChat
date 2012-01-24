// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: window
    property int userCount: 0

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
        model: UserModel
        delegate: UserListItem {
            username: name
        }
    }

    ScrollDecorator {
        id: userDecorator
        flickableItem: userView
    }
}


