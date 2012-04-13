// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1


Row {
    id: window
    spacing: platformStyle.paddingLarge
    height: switchComponent.height
    anchors {
        left: parent.left
        leftMargin: platformStyle.paddingMedium
        right: parent.right
        rightMargin: platformStyle.paddingMedium
    }
    property alias checked: switchComponent.checked
    property alias text: labelComponent.text

    signal clicked()

    ListItemText {
        id: labelComponent
        role: "subtitle"
        anchors {verticalCenter: window.verticalCenter }
        width: window.width - window.spacing - switchComponent.width - (platformStyle.paddingMedium * 2)
    }

    Switch {
        id: switchComponent
        anchors {verticalCenter: window.verticalCenter }
    }


    Component.onCompleted: {
        switchComponent.clicked.connect(clicked)
    }
}

