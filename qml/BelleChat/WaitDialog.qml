// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    id: waitDialog

    buttonTexts: ["Cancel"]
    content:
        ProgressBar {
        id: fcProgress
        indeterminate: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: platformStyle.paddingMedium
        anchors.right: parent.right
        anchors.rightMargin: platformStyle.paddingMedium
    }

}


