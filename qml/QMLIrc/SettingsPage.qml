// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

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

    Flickable {
        id: flickable
        anchors.fill: parent

        Column {
            id: layoutColumns
            x: 0
            y: 0
            spacing: 5
            anchors.fill: parent

            ListHeading {
                id: heading
                ListItemText {
                    id: headingText
                    anchors.fill: heading.paddingItem
                    role: "Heading"
                    text: "Server Settings"
                }
            }

            Label {
                id: serverLabel
                text: qsTr("Server")
                anchors.left: parent.left
                anchors.leftMargin: 20

            }

            TextField {
                id: serverField
                height: 50
                text: Connection.host
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 10
                onTextChanged: {
                    dirty = true;
                }

            }

            Label {
                id: portLabel
                text: qsTr("Port")
                anchors.left: parent.left
                anchors.leftMargin: 20

            }

            TextField {
                id: portField
                height: 50
                text: Connection.port
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 10
                validator: IntValidator {bottom: 0; top: 65535;}
                onTextChanged: {
                    dirty = true;
                }

            }

            Label {
                id: nicknameLabel
                text: qsTr("Nickname")
                anchors.left: parent.left
                anchors.leftMargin: 20

            }

            TextField {
                id: nicknameField
                height: 50
                text: Connection.nickname
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 10
                onTextChanged: {
                    dirty = true;
                }
            }

            Label {
                id: passwordLabel
                text: qsTr("Password")
                anchors.left: parent.left
                anchors.leftMargin: 20

            }

            TextField {
                id: passwordField
                height: 50
                text: Connection.password
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 10
                echoMode: TextInput.PasswordEchoOnEdit
                onTextChanged: {
                    dirty = true;
                }
            }

            Label {
                id: usernameLabel
                text: qsTr("Username")
                anchors.left: parent.left
                anchors.leftMargin: 20
            }

            TextField {
                id: usernameField
                height: 50
                text: Connection.username
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 10
                onTextChanged: {
                    dirty = true;
                }
            }

            Label {
                id: realNameLabel
                text: qsTr("Real name")
                anchors.left: parent.left
                anchors.leftMargin: 20
            }

            TextField {
                id: realnameField
                height: 50
                text: Connection.realname
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 10
                onTextChanged: {
                    dirty = true;
                }

            }
        }
    }

    function saveSettings()
    {
        Connection.setHost(serverField.text);
        Connection.setPort(portField.text);
        Connection.setNickname(nicknameField.text);
        Connection.setUsername(usernameField.text);
        Connection.setPassword(passwordField.text);
        Connection.setRealname(realnameField.text);
    }
}
