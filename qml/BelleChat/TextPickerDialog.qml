import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    id: dialog

    property alias acceptButtonText: acceptButton.text
    property alias rejectButtonText: rejectButton.text
    property alias text: textField.text
    property alias placeholderText: textField.placeholderText
    property alias validator: textField.validator
    property alias inputMask: textField.inputMask
    property alias inputMethodHints: textField.inputMethodHints


    content: TextField {
        id: textField
        anchors.left: parent.left
        anchors.leftMargin: platformStyle.paddingSmall
        anchors.right: parent.right
        anchors.rightMargin: platformStyle.paddingSmall


    }

    buttons: ToolBar {
        id: buttons
        width: parent.width
        height: privateStyle.toolBarHeightLandscape + 2 * platformStyle.paddingSmall

        tools: Row {
            anchors.centerIn: parent
            spacing: platformStyle.paddingMedium

            ToolButton {
                id: acceptButton
                text: acceptButtonText
                width: (buttons.width - 3 * platformStyle.paddingMedium) / 2
                onClicked: dialog.accept()
                visible: text != ""
            }

            ToolButton {
                id: rejectButton
                text: rejectButtonText
                width: (buttons.width - 3 * platformStyle.paddingMedium) / 2
                onClicked: dialog.reject()
                visible: text !=""
            }
        }
    }

    Component.onCompleted: {
        textField.selectAll()

    }


}


