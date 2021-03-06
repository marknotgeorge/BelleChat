// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import BelleChat 1.0

Page {
    id: window


    tools: ToolBarLayout {
        id: settingsToolBarLayout

        ToolButton {
            flat: true
            iconSource: "toolbar-back"
            onClicked: {
                saveSettings()
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
            text: qsTr("Connection Settings")
        }
    }

    ScrollDecorator {
        id: flickerScroll
        flickableItem: flicker
    }

    Flickable {
        id: flicker
        anchors {top: heading.bottom; left: parent.left; right: parent.right; bottom: parent.bottom}
        clip: true
        contentHeight: layoutColumns.height


        Column {
            id: layoutColumns
            anchors { left: parent.left; right: parent.right }
            spacing: platformStyle.paddingMedium

            ListItemText {
                id: onDisconnectionLabel
                role: "Title"
                text: qsTr("On connecting")
            }

            Label {
                id: timeoutIntervalLabel
                text: qsTr("Connection timeout (seconds)")
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
            }

            TextField {
                id: timeoutIntervalField
                text: appConnectionSettings.timeoutInterval
                inputMethodHints: Qt.ImhDigitsOnly
                anchors.right: parent.right
                anchors.rightMargin: platformStyle.paddingLarge
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                validator: IntValidator {bottom: 0; top: 65535;}
                //visible: (activeFocus||!inputContext.visible)
            }

            LabelledSwitch {
                id: autoReconnectSwitch
                text: qsTr("Retry if connection lost")
                checked: appConnectionSettings.autoReconnect
            }

            Label {
                id: reconnectRetryLabel
                text: qsTr("Number of times to retry")
                visible: autoReconnectSwitch.checked
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
            }

            TextField {
                id: reconnectRetryField
                text: appConnectionSettings.reconnectRetries
                visible: autoReconnectSwitch.checked
                inputMethodHints: Qt.ImhDigitsOnly
                anchors.right: parent.right
                anchors.rightMargin: platformStyle.paddingLarge
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                validator: IntValidator {bottom: 0; top: 65535;}
                //visible: (activeFocus||!inputContext.visible)
            }

            Label {
                id: reconnectIntervalLabel
                text: qsTr("Interval between attempts (seconds)")
                visible: autoReconnectSwitch.checked
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
            }

            TextField {
                id: reconnectIntervalField
                text: appConnectionSettings.reconnectInterval
                visible: autoReconnectSwitch.checked
                inputMethodHints: Qt.ImhDigitsOnly
                anchors.right: parent.right
                anchors.rightMargin: platformStyle.paddingLarge
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                validator: IntValidator {bottom: 0; top: 65535;}
                //visible: (activeFocus||!inputContext.visible)
            }

            ListItemText {
                id: personalInfoLabel
                role: "Title"
                text: qsTr("Personal information")
            }

            Label {
                id: quitMessageLabel
                text: qsTr("Default quit message")
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                //visible: quitMessageField.visible
            }

            TextField {
                id: quitMessageField
                text: appConnectionSettings.quitMessage
                anchors.right: parent.right
                anchors.rightMargin: platformStyle.paddingLarge
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                //visible: (activeFocus||!inputContext.visible)
            }

            LabelledSwitch {
                id: respondToIdentSwitch
                text: qsTr("Respond to IDENT request")
                checked: appConnectionSettings.respondToIdent
            }

            LabelledSwitch {
                id: allowUserInfoSwitch
                text: qsTr("Send USERINFO")
                checked: appConnectionSettings.allowUserInfo
            }

            Label {
                id: userInfoLabel
                text: qsTr("User Info")
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                visible: allowUserInfoSwitch.checked
            }

            TextArea {
                id: userInfoField
                text: appConnectionSettings.userInfo
                visible: allowUserInfoSwitch.checked
                height: 200
                anchors.right: parent.right
                anchors.rightMargin: platformStyle.paddingLarge
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                //visible: (activeFocus||!inputContext.visible)
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
        if (quitMessageField.text !== appConnectionSettings.quitMessage)
            appConnectionSettings.setQuitMessage(quitMessageField.text)

        if(reconnectRetryField.text !== appConnectionSettings.reconnectRetries.toString())
            appConnectionSettings.setReconnectRetries(reconnectRetryField.text)

        if (reconnectIntervalField.text !== appConnectionSettings.reconnectInterval.toString())
            appConnectionSettings.setReconnectInterval(reconnectIntervalField.text)

        if (timeoutIntervalField.text !== appConnectionSettings.timeoutInterval.toString())
            appConnectionSettings.setTimeoutInterval(timeoutIntervalField.text)

        if (respondToIdentSwitch.checked !== appConnectionSettings.respondToIdent)
            appConnectionSettings.setRespondToIdent(respondToIdentSwitch.checked)

        if (autoReconnectSwitch.checked !== appConnectionSettings.autoReconnect)
            appConnectionSettings.setAutoReconnect(autoReconnectSwitch.checked)

        if (allowUserInfoSwitch.checked !== appConnectionSettings.allowUserInfo)
            appConnectionSettings.setAllowUserInfo(allowUserInfoSwitch.checked)

        if(userInfoField.text !== appConnectionSettings.userInfo)
            appConnectionSettings.setUserInfo(userInfoField.text)
    }
}
