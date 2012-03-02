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

            Label {
                id: showTimestampLabel
                text: "Incoming messages"
            }

            LabelledSwitch {
                id: showTimestamp
                checked: appConnectionSettings.showTimestamp
                checkedLabel: "Show Timestamp"
                uncheckedLabel: "Hide Timestamp"
                onClicked: { dirty = true }
            }

            Label {
                id: autoFetchWhoisLabel
                text: "When opening User Page"
            }

            LabelledSwitch {
                id: autoFetchWhois
                checked: appConnectionSettings.autoFetchWhois
                checkedLabel: "Fetch Whois info"
                uncheckedLabel: "Don't fetch Whois info"
                onClicked: { dirty = true }
            }

            Label {
                id: appearanceLabel
                text: "Text Appearance"
            }

            ColourPicker {
                id: textColourPicker
                text: "Text Colour"
                picked: appConnectionSettings.textColour
                onAccepted: { dirty = true }
            }

            ColourPicker {
                id: backgroundColourPicker
                text: "Background Colour"
                picked: appConnectionSettings.backgroundColour
                onAccepted: { dirty = true }
            }
        }
    }

    function saveSettings()
    {
        if (dirty)
        {
            appConnectionSettings.setShowTimestamp(showTimestamp.checked)
            appConnectionSettings.setAutoFetchWhois(autoFetchWhois.checked)
            appConnectionSettings.setTextColour(textColourPicker.picked)
            appConnectionSettings.setBackgroundColour(backgroundColourPicker.picked)
        }

    }


}


