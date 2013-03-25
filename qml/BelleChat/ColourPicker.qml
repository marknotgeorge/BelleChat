// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

Row {
    id:window
    height: buttonComponent.height + (platformStyle.paddingSmall*2)
    spacing: platformStyle.paddingLarge
    anchors {
        left: parent.left
        leftMargin: platformStyle.paddingLarge
        right: parent.right
        rightMargin: platformStyle.paddingLarge
    }

    property string text
    property alias picked: cpd.picked
    property alias model: cpd.model
    signal accepted()

    Label {
        id: labelComponent
        text: window.text
        width: window.width - (window.spacing * 2) - buttonComponent.width        
        anchors.verticalCenter: window.verticalCenter
    }

    Rectangle {
        id: buttonComponent
        color: cpd.model.get(cpd.picked).name
        border.color: platformStyle.colorNormalLight
        height: platformStyle.graphicSizeSmall
        width: platformStyle.graphicSizeMedium
        radius: 10
        anchors.verticalCenter: window.verticalCenter



        MouseArea {
            id: buttonMouseArea
            anchors.fill: parent
            onClicked: cpd.open()
        }

    }

    ColourPickerDialog {
        id: cpd
        titleText: window.text
        rejectButtonText: "Cancel"
        onAccepted: buttonComponent.color = cpd.model.get(cpd.picked).name
    }

    Component.onCompleted: {
        cpd.accepted.connect(accepted)
    }

}

