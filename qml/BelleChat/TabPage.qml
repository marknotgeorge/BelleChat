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
        model: outputModel
        focus: true
        delegate: OutputItem {
            id: outputDelegate
            text: model.text
            onLinkActivated: {
                var banner = infoBannerFactory.createObject(window)
                banner.text = "Opening " + link + "..."
                banner.iconSource = "icon-globe.svg"
                banner.open()
                if (!Qt.openUrlExternally(link)) {
                    linkFailureDialog.message = "Unable to open link " + link + "\n"
                }
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

    function dropToBottom()
    {
        outputView.positionViewAtEnd()
    }

}
