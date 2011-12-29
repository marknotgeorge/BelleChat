// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
Page {
    id: outputFlickable
    property alias outputText: outputBox
    property string channel: ""
    anchors.fill: parent

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: outputBox.paintedWidth
        contentHeight: outputBox.paintedHeight
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        // Taken from the TextEdit example code...
        function ensureVisible(r)
             {
                 if (contentX >= r.x)
                     contentX = r.x;
                 else if (contentX+width <= r.x+r.width)
                     contentX = r.x+r.width-width;
                 if (contentY >= r.y)
                     contentY = r.y;
                 else if (contentY+height <= r.y+r.height)
                     contentY = r.y+r.height-height;
             }

        TextEdit {
            id: outputBox
            width: flick.width
            height: flick.height
            focus: true
            wrapMode: TextEdit.WordWrap
            font: font.pointSize = 6
            textFormat: TextEdit.RichText
            text: ""
            cursorPosition: 0
            color: "#ffffff"
            readOnly: true
            onTextChanged: {
                // Find the last available cursorPosition
                selectAll()
                var endOfSelection = selectionEnd
                deselect()
                cursorPosition = endOfSelection
                flick.ensureVisible(cursorRectangle)
            }
        }
    }
}
