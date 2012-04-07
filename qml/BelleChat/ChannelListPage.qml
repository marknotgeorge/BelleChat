// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import BelleChat 1.0

Page {
    id: window
    property int count: 0

    tools: ToolBarLayout {
        id: channelListToolBarLayout

        ToolButton {
            flat: true
            iconSource: "toolbar-back"
            onClicked: {
                pageStack.pop()
            }
        }
    }

    ListHeading {
        id: channelListHeading
        anchors { left: parent.left; right: parent.right; top: parent.top; }
        ListItemText {
            id: channelListHeadingText
            role: "Heading"
            text: Session.host + " (" + count + ") channels"
        }
    }
    ListView {
        id: channelListView
        anchors {
            left: parent.left
            right: parent.right
            top: channelListHeading.bottom
            bottom: parent.bottom
        }
        model: ChannelModel
        clip: true
        delegate: ChannelItem {
            channelText: channel + " (" + users + ")"
            topicText: topic

            onClicked: {
                joinChannel(channel)
                pageStack.pop()
            }
        }
    }

    function joinChannel(channel)
    {
        initialPage.outputToTab("Server", "Joining channel " + channel + " ...")
        // This is where the actual channel joining code goes...
        Session.joinChannel(channel)

    }



}
