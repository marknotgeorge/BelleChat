// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

CommonDialog {
    id: dialogcpd
    property int picked: 0
    property alias model: boxGrid.model
    property alias acceptButtonText: acceptButton.text
    property alias rejectButtonText: rejectButton.text

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
                onClicked: dialogcpd.accept()
                visible: text != ""
            }

            ToolButton {
                id: rejectButton
                text: rejectButtonText
                width: (buttons.width - 3 * platformStyle.paddingMedium) / 2
                onClicked: dialogcpd.reject()
                visible: text !=""
            }
        }
    }

    content:

        Rectangle {
        id: box

        width: parent.width - (platformStyle.paddingSmall *2)
        height: (screen.currentOrientation === Screen.Portrait)? width : (parent.height - (platformStyle.paddingSmall *2))
        anchors.centerIn: parent
        Grid {
            id: pickerGrid
            anchors.fill: parent
            columns: (screen.currentOrientation === Screen.Portrait)? 4 : 8

            Repeater {
                id: boxGrid
                model: ListModel {
                    ListElement { name: "white"; code: 0 }
                    ListElement { name: "black"; code: 1 }
                    ListElement { name: "blue"; code: 2 }
                    ListElement { name: "green"; code: 3 }
                    ListElement { name: "red"; code: 4 }
                    ListElement { name: "brown"; code: 5}
                    ListElement { name: "purple"; code: 6 }
                    ListElement { name: "orange"; code: 7 }
                    ListElement { name: "yellow"; code: 8 }
                    ListElement { name: "light green"; code: 9 }
                    ListElement { name: "teal"; code: 10 }
                    ListElement { name: "light cyan"; code: 11 }
                    ListElement { name: "light blue"; code: 12 }
                    ListElement { name: "pink"; code: 13 }
                    ListElement { name: "grey"; code: 14 }
                    ListElement { name: "light grey"; code: 15 }
                }
                Rectangle {
                    id: item
                    width: box.width / pickerGrid.columns
                    height: (screen.currentOrientation === Screen.Portrait)? item.width : box.height / (16 / pickerGrid.columns)
                    color: model.name
                    border.width: (index !== picked)? 1 : 3
                    border.color: (index !== picked)? platformStyle.colorNormalDark : platformStyle.colorHighlighted

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            picked = index
                            console.log("Picked:" + picked)
                            dialogcpd.accept()
                        }
                    }
                }
            }
        }
    }

}



