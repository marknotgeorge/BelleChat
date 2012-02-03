// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import QMLIrc 1.0


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

            LabelledSwitch {
                id: showTimestamp
                checked: appConnectionSettings.showTimestamp
                checkedLabel: "Show Timestamp"
                uncheckedLabel: "Hide Timestamp"
                onClicked: { dirty = true }
            }

            LabelledSwitch {
                id: autoFetchWhois
                checked: appConnectionSettings.autoFetchWhois
                checkedLabel: "Fetch Whois info"
                uncheckedLabel: "Don't fetch Whois info"
                onClicked: { dirty = true }
            }
        }
    }

    function saveSettings()
    {
        if (dirty)
        {
            appConnectionSettings.setShowTimestamp(showTimestamp.checked)
            appConnectionSettings.setAutoFetchWhois(autoFetchWhois.checked)
        }

    }
}

