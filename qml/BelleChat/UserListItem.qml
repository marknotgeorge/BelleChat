// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

ListItem {
    id: userListItem
    property alias username: userListText.text
    property alias propername: realnameText.text
    property bool complete: false

    subItemIndicator: true


    Column {
        id: userListColumn

        ListItemText {
            id: userListText
            role: "Title"
        }

        ListItemText {
            id: realnameText
            role: "Subtitle"
        }
    }
}
