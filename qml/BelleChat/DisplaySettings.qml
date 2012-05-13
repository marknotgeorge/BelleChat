// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import BelleChat 1.0


Page {
    id: window

    property bool dirty: false

    tools: ToolBarLayout {
        id: displayToolBarLayout

        ToolButton {
            flat: true
            iconSource: "toolbar-back"
            onClicked: {
                if (dirty)
                {
                    saveSettings()
                }
                pageStack.pop()
            }
        }
    }



    ListHeading {
        id: heading
        anchors {left: parent.left; right: parent.right}
        ListItemText {
            id: headingText
            anchors.fill: heading.paddingItem
            role: "Heading"
            text: qsTr("Display Settings")
        }
    }

    ScrollDecorator {
        id: flickerScroll
        flickableItem: flicker
    }

    Flickable {
        id: flicker
        anchors {top: heading.bottom; left: parent.left; right: parent.right; bottom: parent.bottom}
        clip:true
        contentHeight: layoutColumns.height

        Column {
            id: layoutColumns
            spacing: platformStyle.paddingSmall
            anchors { left: parent.left; right: parent.right }

            ListItemText {
                id: showTimestampLabel
                role: "Title"
                text: "Incoming messages"
            }

            LabelledSwitch {
                id: showTimestamp
                checked: appConnectionSettings.showTimestamp
                text: "Show Timestamp"
                onClicked: { dirty = true }
            }

            ListItemText {
                id: showChannelListLabel
                text: "On connection to IRC server"
                role: "Title"
            }

            LabelledSwitch {
                id: showChannelList
                checked: appConnectionSettings.showChannelList
                text: "Show list of available channels"
                onClicked: { dirty = true }
            }

            ListItemText {
                id: appearanceLabel
                text: "My Message Appearance"
                role: "Title"
            }

            LabelledSwitch {
                id: formatTextSwitch
                checked: appConnectionSettings.formatText
                text: "Formatted Text"
                onClicked: {
                    dirty = true
                    textColourPicker.visible = checked
                    backgroundColourPicker.visible = checked
                    formatRow.visible = checked
                    sampleBackground.visible = checked
                }
            }

            ColourPicker {
                id: textColourPicker
                text: "Text Colour"
                picked: appConnectionSettings.textColour
                visible: formatTextSwitch.checked
                onAccepted: {
                    dirty = true
                    sampleText.color = model.get(picked).name
                }
            }

            ColourPicker {
                id: backgroundColourPicker
                text: "Background Colour"
                picked: appConnectionSettings.backgroundColour
                visible: formatTextSwitch.checked
                onAccepted: {
                    dirty = true
                    sampleBackground.color = model.get(picked).name
                }
            }

            Row {
                id: formatRow
                spacing: platformStyle.paddingSmall
                anchors {
                    left: parent.left
                    leftMargin: platformStyle.paddingMedium
                    right: parent.right
                    rightMargin: platformStyle.paddingMedium
                }

                visible: formatTextSwitch.checked
                CheckBox {
                    id: textBoldCheck
                    width: (parent.width - (parent.spacing * 2) - (platformStyle.paddingMedium *2)) / 3
                    text: "Bold"
                    checked: appConnectionSettings.textBold
                    onCheckedChanged: {
                        dirty = true;
                        sampleText.font.bold = checked
                    }
                }

                CheckBox {
                    id: textItalicCheck
                    width: (parent.width - (parent.spacing * 2) - (platformStyle.paddingMedium *2)) / 3
                    text: "Italic"
                    checked: appConnectionSettings.textItalic
                    onCheckedChanged: {
                        dirty = true
                        sampleText.font.italic = checked
                    }
                }

                CheckBox {
                    id: textUnderlineCheck
                    width: (parent.width - (parent.spacing * 2) - (platformStyle.paddingMedium *2)) / 3
                    text: "Underline"
                    checked: appConnectionSettings.textUnderline
                    onCheckedChanged: {
                        dirty = true
                        sampleText.font.underline = checked
                    }
                }
            }

            Rectangle {
                id: sampleBackground
                anchors {left: parent.left; right: parent.right }
                height: sampleText.height
                color: backgroundColourPicker.model.get(backgroundColourPicker.picked).name
                visible: formatTextSwitch.checked

                Text {
                    id: sampleText
                    text: "Sample Text"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pointSize: 16
                    font.bold: textBoldCheck.checked
                    font.italic: textItalicCheck.checked
                    font.underline: textUnderlineCheck.checked
                    color: textColourPicker.model.get(textColourPicker.picked).name
                }
            }
        }
        // Virtual keyboard handling, written by Akos Polster

        Timer {
            id: adjuster
            interval: 200
            onTriggered: flicker.adjust()
        }

        Component.onCompleted:
        {
            inputContext.visibleChanged.connect(adjuster.restart)
        }

        function adjust() {
            if (!inputContext.visible) {
                return
            }

            var focusChild = null
            function findFocusChild(p) {
                if (p["activeFocus"] === true) {
                    focusChild = p
                } else {
                    for (var i = 0; i < p["children"].length; i++) {
                        findFocusChild(p["children"][i])
                        if (focusChild !== null) {
                            break
                        }
                    }
                }
            }
            findFocusChild(flicker)

            if (focusChild === null) {
                return
            }
            var focusChildY = focusChild["y"]
            var focusChildHeight = focusChild["height"]
            if ((flicker.contentY + flicker.height) < (focusChildY + focusChildHeight)) {
                flicker.contentY = focusChildY + focusChildHeight - flicker.height
            }
        }
    }

    function saveSettings()
    {
        if (dirty)
        {
            appConnectionSettings.setShowTimestamp(showTimestamp.checked)
            appConnectionSettings.setTextColour(textColourPicker.picked)
            appConnectionSettings.setBackgroundColour(backgroundColourPicker.picked)
            appConnectionSettings.setTextBold(textBoldCheck.checked)
            appConnectionSettings.setTextItalic(textItalicCheck.checked)
            appConnectionSettings.setTextUnderline(textUnderlineCheck.checked)
            appConnectionSettings.setFormatText(formatTextSwitch.checked)
            appConnectionSettings.setShowChannelList(showChannelList.checked)            
        }
    }


}


