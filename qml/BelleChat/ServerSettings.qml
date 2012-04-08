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
            text: qsTr("Server Settings")
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


        Column {
            id: layoutColumns
            anchors.fill: parent

            Label {
                id: serverLabel
                text: qsTr("Server")
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                //visible: serverField.visible
            }

            TextField {
                id: serverField
                text: appConnectionSettings.host
                anchors.right: parent.right
                anchors.rightMargin: platformStyle.paddingLarge
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                //visible: (activeFocus||!inputContext.visible)
            }

            Label {
                id: portLabel
                text: qsTr("Port")
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                //visible: portField.visible
            }

            TextField {
                id: portField
                text: appConnectionSettings.port
                anchors.right: parent.right
                anchors.rightMargin: platformStyle.paddingLarge
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                validator: IntValidator {bottom: 0; top: 65535;}
                //visible: (activeFocus||!inputContext.visible)
            }

            Label {
                id: nicknameLabel
                text: qsTr("Nickname")
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                //visible: nicknameField.visible
            }

            TextField {
                id: nicknameField
                text: appConnectionSettings.nickname
                anchors.right: parent.right
                anchors.rightMargin: platformStyle.paddingLarge
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                //visible: (activeFocus||!inputContext.visible)
            }

            Label {
                id: passwordLabel
                text: qsTr("Password")
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                //visible: passwordField.visible
            }

            TextField {
                id: passwordField
                text: appConnectionSettings.password
                anchors.right: parent.right
                anchors.rightMargin: platformStyle.paddingLarge
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                echoMode: TextInput.PasswordEchoOnEdit
                //visible: (activeFocus||!inputContext.visible)
            }

            Label {
                id: usernameLabel
                text: qsTr("Username")
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                //visible: usernameField.visible
            }

            TextField {
                id: usernameField
                text: appConnectionSettings.username
                anchors.right: parent.right
                anchors.rightMargin: platformStyle.paddingLarge
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                //visible: (activeFocus||!inputContext.visible)
            }

            Label {
                id: realnameLabel
                text: qsTr("Real name")
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                //visible: realnameField.visible
            }

            TextField {
                id: realnameField
                text: appConnectionSettings.realname
                anchors.right: parent.right
                anchors.rightMargin: platformStyle.paddingLarge
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                //visible: (activeFocus||!inputContext.visible)
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
        }

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

    QueryDialog {
        id: connectedQuery
        titleText: qsTr("Connected to server")
        message: qsTr("Settings changes will not apply until the next time you connect.\n")
        acceptButtonText: qsTr("Ok")
    }

    function saveSettings()
    {
        var dirty = false

        // Save the settings if they've changed
        if (serverField.text !== appConnectionSettings.host)
        {
            console.log("Server changed!")
            appConnectionSettings.setHost(serverField.text)
            dirty = true
        }
        if (portField.text !== appConnectionSettings.port.toString())
        {
            console.log("Port changed!")
            appConnectionSettings.setPort(portField.text)
            dirty = true
        }
        if (nicknameField.text !== appConnectionSettings.nickname)
        {
            console.log("Nickname changed!")
            appConnectionSettings.setNickname(nicknameField.text)
            dirty = true
        }
        if (usernameField.text !== appConnectionSettings.username)
        {
            console.log("Username changed!")
            appConnectionSettings.setUsername(usernameField.text)
            dirty = true
        }
        if (passwordField.text !== appConnectionSettings.password)
        {
            console.log("Password changed!")
            appConnectionSettings.setPassword(passwordField.text)
            dirty = true
        }
        if (realnameField.text !== appConnectionSettings.realname)
        {
            console.log("Realname changed!")
            appConnectionSettings.setRealname(realnameField.text)
            dirty = true
        }
        if (quitMessageField.text !== appConnectionSettings.quitMessage)
        {
            console.log("Quit message changed")
            appConnectionSettings.setQuitMessage(quitMessageField.text)
            dirty = true
        }

        // If settings have changed and we're connected, show a warning
        // dialog
        console.log("Dirty:" + dirty)
        if (dirty && Session.connected)
            connectedQuery.open()
    }
}
