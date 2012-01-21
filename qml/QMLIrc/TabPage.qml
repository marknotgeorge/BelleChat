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
        delegate: OutputItem {
            id: outputDelegate
            text: model.text
        }
        anchors.fill: parent
        clip: true
    }

    function addOutput(output)
    {
        outputModel.append({"text": output})
        outputView.positionViewAtEnd()
    }

    function clear()
    {
        outputModel.clear()
    }

}
