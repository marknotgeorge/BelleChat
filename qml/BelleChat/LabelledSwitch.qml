// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1


Row {
    id: window
    spacing: platformStyle.paddingLarge
    height: switchComponent.height
    anchors {
        left: parent.left
        leftMargin: platformStyle.paddingLarge
        right: parent.right
        rightMargin: platformStyle.paddingLarge
    }
    property alias checked: switchComponent.checked
    property alias text: labelComponent.text

    signal clicked()

    Label {
        id: labelComponent        
        anchors {verticalCenter: window.verticalCenter }
        width: window.width - window.spacing - switchComponent.width - (platformStyle.paddingLarge * 2)
    }

    Switch {
        id: switchComponent
        anchors {verticalCenter: window.verticalCenter }
    }


    Component.onCompleted: {
        switchComponent.clicked.connect(clicked)
    }
}

