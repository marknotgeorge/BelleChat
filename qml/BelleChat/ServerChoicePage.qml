import QtQuick 1.1
import com.nokia.symbian 1.1
import BelleChat 1.0
import "HelpText.js" as HelpText

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
        id: heading
        anchors {left: parent.left; right: parent.right}
        ListItemText {
            id: headingText
            anchors.fill: heading.paddingItem
            role: "Heading"
            text: qsTr("Servers")
        }
    }

    ListView {
        id: serversView
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.top: heading.bottom
        anchors.topMargin: 0
        model: serversModel
        delegate: ServerListItem {}
    }
}
