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


    ListView {
        id: userView
        anchors.fill: parent
        model: UserModel
        header: ListHeading {
            id: userHeading
            ListItemText {
                id: userHeadingText
                role: "Heading"
                text: currentChannel + ": " + userCount + " users"
            }
        }
        delegate: UserListItem {
            username: model.modelData
        }
    }

    ScrollDecorator {
        id: userDecorator
        flickableItem: userView
    }

}


