// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1




Page {
    id: window
    property string channel: ""


    ListModel {
        id: outputModel
    }

    Component {
        id: infoBannerFactory
        InfoBanner {}
    }

    QueryDialog {
        id: linkFailureDialog
        titleText: "Link failed"
        message: "Unable to open link."
        acceptButtonText: "Ok"
    }


    ListView {
        id: outputView
        property bool enableAutoScroll: true
        model: outputModel
        focus: true
        delegate: OutputItem {
            id: outputDelegate
            text: model.text

        }
        anchors.fill: parent
        footer: Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 5
            color: platformStyle.colorBackground
        }
        clip: true
        onMovementEnded: {
            enableAutoScroll = outputView.atYEnd
        }
    }

    ScrollDecorator {
        id: outputScroll
        flickableItem: outputView
    }

    function addOutput(output)
    {
        // console.log(output)
        outputModel.append({"text": output})
        outputView.currentIndex++
        if (outputView.enableAutoScroll)
        {
            outputView.positionViewAtEnd()
        }
    }

    function clear()
    {
        outputModel.clear()
    }

    function dropToBottom()
    {
        outputView.positionViewAtEnd()
    }

}
