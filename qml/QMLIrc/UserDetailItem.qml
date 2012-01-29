// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

ListItem {
    id: userListItem
    property alias title: userDetailTitle.text
    property alias data: userDetailData.text
    Column {
        ListItemText {
            id: userDetailTitle
            role: "Title"
        }
        ListItemText {
            id: userDetailData
            role: "Subtitle"
            wrapMode: Text.Wrap
        }
    }
}


