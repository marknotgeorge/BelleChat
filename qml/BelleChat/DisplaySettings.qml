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

    Item {
        id: splitViewInput
        anchors {bottom: parent.bottom; left: parent.left; right: parent.right}
        Behavior on height { PropertyAnimation {duration: 200} }
        states: [
            State {
                name: "Visible"; when: inputContext.visible
                PropertyChanges { target: splitViewInput; height: inputContext.height }
                PropertyChanges {
                    target: flicker
                    interactive:false
                }
            },

            State {
                name: "Hidden"; when: !inputContext.visible
                PropertyChanges { target: splitViewInput; height: 0 }
                PropertyChanges {
                    target: flicker
                    interactive:true
                }
            }
        ]
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

    Flickable {
        id: flicker
        anchors {top: heading.bottom; left: parent.left; right: parent.right; bottom: splitViewInput.top}
        contentHeight: layoutColumns.height


        Column {
            id: layoutColumns
            spacing: 5
            anchors {left: parent.left; right: parent.right}

            ListItemText {
                id: showTimestampLabel
                role: "Title"
                text: "Incoming messages"
            }

            LabelledSwitch {
                id: showTimestamp
                checked: appConnectionSettings.showTimestamp
                checkedLabel: "Show Timestamp"
                uncheckedLabel: "Hide Timestamp"
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
                checkedLabel: "Show list of available channels"
                uncheckedLabel: "Don't show list of channels"
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
                checkedLabel: "Formatted Text"
                uncheckedLabel: "Plain Text"
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
                visible: formatTextSwitch.checked
                CheckBox {
                    id: textBoldCheck
                    text: "Bold"
                    checked: appConnectionSettings.textBold
                    onCheckedChanged: {
                        dirty = true;
                        sampleText.font.bold = checked
                    }
                }

                CheckBox {
                    id: textItalicCheck
                    text: "Italic"
                    checked: appConnectionSettings.textItalic
                    onCheckedChanged: {
                        dirty = true
                        sampleText.font.italic = checked
                    }
                }

                CheckBox {
                    id: textUnderlineCheck
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


