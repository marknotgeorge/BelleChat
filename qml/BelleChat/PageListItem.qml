// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

ListItem {
    id: pageListItem
    property alias title: boxItem.text
    property alias icon: icon.source
    subItemIndicator: true

    Row {
        id: itemRow
        anchors.fill: pageListItem.paddingItem


        Image {
            id: icon
            // Make the icon square...
            height: parent.height
            width: parent.height
        }

        ListItemText {
            id: boxItem
            mode: pageListItem.mode
            anchors.verticalCenter: parent.verticalCenter

        }
    }
}

