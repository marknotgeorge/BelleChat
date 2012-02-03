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

    ListModel {
        id: listPages
        ListElement {
            title: "Server"
            page: "ServerSettings.qml"
            icon: "icon-server.svg"
        }
        ListElement {
            title: "Display"
            page: "DisplaySettings.qml"
            icon: "icon-device.svg"
        }
    }



    Component {
        id: listHeader

        ListHeading {
            id: listHeading
            ListItemText {
                id: headingText
                anchors.fill: listHeading.paddingItem
                role: "Heading"
                text: "Settings"
            }
        }
    }

    ListView {
        id: pageView
        anchors.fill: parent
        header: listHeader
        model: listPages
        delegate: PageListItem {
            id: itemDelegate
            title: model.title
            icon: model.icon
            onClicked: {
                var pageFactory = Qt.createComponent(model.page)
                var page = pageFactory.createObject(window)

                pageStack.push(page)
            }
        }
    }



}

