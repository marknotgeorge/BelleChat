// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import "HelpText.js" as HelpText

Page {
    id: window

    tools:
        ToolBarLayout {
        ToolButton {
            id: backButton
            flat: true
            iconSource: "toolbar-back"            
            onClicked: window.pageStack.depth <= 1 ? Qt.quit() : window.pageStack.pop()
        }

        ToolButton {
            id: okButton
            flat: true
            iconSource: "icon-ok.svg"
            onClicked: {
                var page = serverSettingsFactory.createObject(initialPage)
                window.pageStack.replace(page)
            }
        }
    }

    ScrollDecorator {
        flickableItem: flicker
    }

    Flickable{
        id: flicker
        anchors.top: parent.top
        anchors.bottom: dontShowAgain.top
        anchors.horizontalCenter: parent.horizontalCenter

        width: parent.width - 2 * platformStyle.paddingLarge
        clip: true

        contentHeight: label.height

        Label{
            id: label
            anchors.top: parent.top
            width: parent.width            
            text: HelpText.startPageText
            wrapMode: Text.WordWrap
            onLinkActivated: {
                console.log(link + " link activated")
                Qt.openUrlExternally(link);
            }
        }
    }

    CheckBox {
        id: dontShowAgain
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        checked: false
        text: "Don't show this again."
        onCheckedChanged: appConnectionSettings.supressStartPage = checked
    }
}
