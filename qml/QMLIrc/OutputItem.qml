// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1


TextEdit {
    id:outputItem
    anchors.left: parent.left
    anchors.right: parent.right
    wrapMode: TextEdit.WordWrap
    font: font.pointSize = 6
    textFormat: TextEdit.RichText
    text: ""
    color: "#ffffff"
    readOnly: true
}

