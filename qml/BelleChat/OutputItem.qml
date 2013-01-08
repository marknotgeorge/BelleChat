// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1


Rectangle {
    id: outputItem
    property alias text: outputItemText.text
    height: outputItemText.height
    width: parent.width
    color: platformStyle.colorBackground

    Text {
        id:outputItemText
        wrapMode: Text.Wrap
        width: parent.width

        font.pixelSize: platformStyle.fontSizeSmall
        textFormat: Text.RichText
        text: ""
        color: platformStyle.colorNormalLight

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
}

