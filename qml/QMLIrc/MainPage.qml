import QtQuick 1.1
import com.nokia.symbian 1.1

import "TabArray.js" as TabArray



Page {
    id: page1

    Component {
        id: outputFlickableFactory
        OutputFlickable {}
    }

    Component {
        id: tabButtonFactory
        TabButton {}
    }


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
        Keys.onReturnPressed: {
            var page = tabGroup.currentTab
            console.log(inputField.text);
            Session.onInputReceived(page.channel, inputField.text);
            inputField.text = "";
        }
    }

    TabBarLayout {
        id: tabBarLayout
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0


    }

    TabGroup {
        id: tabGroup
        anchors.bottomMargin: 0
        anchors.top: tabBarLayout.bottom
        anchors.right: parent.right
        anchors.bottom: inputField.top
        anchors.left: parent.left
        anchors.topMargin: 0
    }

    Component.onCompleted: {

        createTab("Server");
    }

    function createTab(channel)
    {
        var page = outputFlickableFactory.createObject(tabGroup)
        var button = tabButtonFactory.createObject(tabBarLayout);

        //console.log("Creating tab %s",channel)
        button.text = channel
        page.channel = channel
        page.outputText.text = ""
        button.tab = page
        TabHash.insert(channel, button)
        tabGroup.currentTab = page

    }

    function closeTab(channel)
    {
        var button = TabHash.value(channel)
        if (button)
        {
            button.tab.destroy();
            button.destroy();
        }

    }


    function outputToTab(channel, output) {

        var outputChannel
        if (channel === Connection.host)
            outputChannel = "Server"
        else
            outputChannel = channel;

        console.log("Writing to ", outputChannel)

        var button = TabHash.value(outputChannel);
        if (button) {
           // console.log("Found tab ", outputChannel)
            var page = button.tab
            page.outputText.text += output;
            //console.log("Output length:", output.length)
        }
    }
}



