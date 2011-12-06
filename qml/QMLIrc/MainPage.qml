import QtQuick 1.1
import com.nokia.symbian 1.1


Page {

    property string serverOutput : "Welcome to QMLIrc!\n"
    property string channelOutput : ""


    TextField {
        id: inputField
        x: 0
        y: 530
        height: 50
        text: ""
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        placeholderText: "Tap to write..."
    }

    TabBar {
        id: tabbarLayout
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0

        TabButton {
            id: tabButtonServer
            x: 1
            y: 2
            text: "Not connected"
            tab: outputServer

        }

        TabButton {
            id: tabButtonChannel
            x: 465
            y: 159
            text: "Channel"
            tab: outputChannel
            visible: false
        }
    }

    TabGroup {
        id: tabgroup1
        x: 0
        y: 60
        anchors.bottomMargin: 0
        anchors.top: tabbarLayout.bottom
        anchors.right: parent.right
        anchors.bottom: inputField.top
        anchors.left: parent.left
        anchors.topMargin: 0

        OutputFlickable {
            id: outputServer
            x: 0
            y: 60
            anchors.fill: parent
            text: serverOutput


        }

        OutputFlickable {
            id: outputChannel
            x: -180
            y: 60
            anchors.fill: parent
            text: channelOutput
            visible: false


        }
    }


    function showChannelOutput(channel)
    {
        tabButtonChannel.text = channel
        tabButtonChannel.visible = true
        outputChannel.visible = true
        tabgroup1.currentTab = outputChannel
    }

    function hideChannelOutput()
    {
        tabButtonChannel.visible = false
        outputChannel.visible = false
        tabgroup1.currentTab = outputServer
        outputChannel.text = ""

    }

}
