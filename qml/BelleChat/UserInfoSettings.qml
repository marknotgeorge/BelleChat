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
            text: qsTr("User Info Settings")
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

            LabelledSwitch {
                id: allowUserInfoSwitch
                text: qsTr("Allow BelleChat to send user info")
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

    QueryDialog {
        id: connectedQuery
        titleText: qsTr("Connected to server")
        message: qsTr("Settings changes will not apply until the next time you connect.\n")
        acceptButtonText: qsTr("Ok")
    }

    function saveSettings()
    {
        if (allowUserInfoSwitch.checked !== appConnectionSettings.allowUserInfo)
        {
            appConnectionSettings.setAllowUserInfo(allowUserInfoSwitch.checked)
        }


        if(userInfoField.text !== appConnectionSettings.userInfo)
        {
            appConnectionSettings.setUserInfo(userInfoField.text)
        }
    }
}
