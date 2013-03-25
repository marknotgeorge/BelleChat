// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

ListItem {
    id: serverListItem



    Column {
        id: itemRow
        anchors.fill: serverListItem.paddingItem

        ListItemText {
            id: topLine
            mode: serverListItem.mode
            role: "Title"
            text: name
        }

        ListItemText {
            id: bottomLine
            mode: serverListItem.mode
            role: "Subtitle"
            text: url + " : " + port
        }
    }
}

