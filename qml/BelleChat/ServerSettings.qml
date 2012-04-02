// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import BelleChat 1.0

Page {
    id: window

    property bool dirty: false
    tools: ToolBarLayout {
        id: settingsToolBarLayout

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
            text: qsTr("Server Settings")
        }
    }

    Flickable {
        id: flicker
        anchors {top: heading.bottom; left: parent.left; right: parent.right; bottom: splitViewInput.top}
        contentHeight: layoutColumns.height


        Column {
            id: layoutColumns
            anchors {left: parent.left; right: parent.right}

            Label {
                id: serverLabel
                text: qsTr("Server")
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                visible: serverField.visible
            }

            TextField {
                id: serverField
                text: appConnectionSettings.host
                anchors.right: parent.right
                anchors.rightMargin: platformStyle.paddingLarge
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                visible: (activeFocus||!inputContext.visible)
                onTextChanged: {
                    dirty = true;
                }
            }

            Label {
                id: portLabel
                text: qsTr("Port")
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                visible: portField.visible
            }

            TextField {
                id: portField
                text: appConnectionSettings.port
                anchors.right: parent.right
                anchors.rightMargin: platformStyle.paddingLarge
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                validator: IntValidator {bottom: 0; top: 65535;}
                visible: (activeFocus||!inputContext.visible)
                onTextChanged: {
                    dirty = true;
                }

            }

            Label {
                id: nicknameLabel
                text: qsTr("Nickname")
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                visible: nicknameField.visible
            }

            TextField {
                id: nicknameField
                text: appConnectionSettings.nickname
                anchors.right: parent.right
                anchors.rightMargin: platformStyle.paddingLarge
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                visible: (activeFocus||!inputContext.visible)
                onTextChanged: {
                    dirty = true;
                }
            }

            Label {
                id: passwordLabel
                text: qsTr("Password")
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                visible: passwordField.visible
            }

            TextField {
                id: passwordField
                text: appConnectionSettings.password
                anchors.right: parent.right
                anchors.rightMargin: platformStyle.paddingLarge
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                echoMode: TextInput.PasswordEchoOnEdit
                visible: (activeFocus||!inputContext.visible)
                onTextChanged: {
                    dirty = true;
                }
            }

            Label {
                id: usernameLabel
                text: qsTr("Username")
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                visible: usernameField.visible
            }

            TextField {
                id: usernameField
                text: appConnectionSettings.username
                anchors.right: parent.right
                anchors.rightMargin: platformStyle.paddingLarge
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                visible: (activeFocus||!inputContext.visible)
                onTextChanged: {
                    dirty = true;
                }
            }

            Label {
                id: realnameLabel
                text: qsTr("Real name")
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                visible: realnameField.visible
            }

            TextField {
                id: realnameField
                text: appConnectionSettings.realname
                anchors.right: parent.right
                anchors.rightMargin: platformStyle.paddingLarge
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                visible: (activeFocus||!inputContext.visible)
                onTextChanged: {
                    dirty = true;
                }
            }

            Label {
                id: quitMessageLabel
                text: qsTr("Default quit message")
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                visible: quitMessageField.visible
            }

            TextField {
                id: quitMessageField
                text: appConnectionSettings.quitMessage
                anchors.right: parent.right
                anchors.rightMargin: platformStyle.paddingLarge
                anchors.left: parent.left
                anchors.leftMargin: platformStyle.paddingLarge
                visible: (activeFocus||!inputContext.visible)
                onTextChanged: {
                    dirty = true;
                }
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
        // Show a message if connected to a server.
        if (Session.connected)
        {
            connectedQuery.open()
        }

        // Save the settings
        appConnectionSettings.setHost(serverField.text)
        appConnectionSettings.setPort(portField.text)
        appConnectionSettings.setNickname(nicknameField.text)
        appConnectionSettings.setUsername(usernameField.text)
        appConnectionSettings.setPassword(passwordField.text)
        appConnectionSettings.setRealname(realnameField.text)
        appConnectionSettings.setQuitMessage(quitMessageField.text)
    }
}
