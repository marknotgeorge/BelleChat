// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

Row {
    id: window
    spacing: 10
    height: switchComponent.height
    anchors {left: parent.left; right: parent.right }
    property alias checked: switchComponent.checked
    property string checkedLabel: ""
    property string uncheckedLabel: ""
    signal clicked()

    Label {
        id: labelComponent
        anchors {verticalCenter: window.verticalCenter }
        width: window.width - window.spacing - switchComponent.width
        text: switchComponent.checked ? checkedLabel:uncheckedLabel
    }

    Switch {
        id: switchComponent
        anchors {verticalCenter: window.verticalCenter }
    }

    Component.onCompleted: {
        switchComponent.clicked.connect(clicked)
    }
}

