// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import BelleChat 1.0

ListItem {
    id: channelItem
    property alias channelText: channelListChannel.text
    property alias topicText: channelListTopic.text


    Column {
        id: channelListColumn
        anchors.fill: channelItem.paddingItem

        ListItemText {
            id: channelListChannel
            role: "Title"
        }
        ListItemText {
            id: channelListTopic
            role: "SubTitle"
            elide: Text.ElideRight
        }
    }
}





