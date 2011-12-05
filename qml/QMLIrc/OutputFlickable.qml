import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: item
    width: 200
    height: 300
    //color: "#00000000"




    property alias text: outputBox.text


    Flickable {
        id: flickable
        anchors.fill: parent

        Text {
            id: outputBox
            color: "#ffffff"
            verticalAlignment: Text.AlignBottom
            wrapMode: Text.WordWrap
            anchors.fill: parent
            font.pixelSize: 16
        }
    }


}
