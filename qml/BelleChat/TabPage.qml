// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1



Page {
    id: window
    property string channel: ""

    ListModel {
        id: outputModel
    }


    ListView {
        id: outputView
        model: outputModel
        focus: true
        delegate: OutputItem {
            id: outputDelegate
            text: model.text
            onLinkActivated: {
                Qt.openUrlExternally(link)
            }

        }
        anchors.fill: parent
        clip: true

    }

    ScrollDecorator {
        id: outputScroll
        flickableItem: outputView
    }

    function addOutput(output)
    {
        console.log(output)
        outputModel.append({"text": output})
        outputView.currentIndex++
        outputView.positionViewAtEnd()
    }

    function clear()
    {
        outputModel.clear()
    }

}
