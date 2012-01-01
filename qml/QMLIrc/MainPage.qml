import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: page1

    Component {
        id: outputFlickableFactory
        OutputFlickable {}
    }

    Component {
        id: tabButtonFactory
        TabButton {

        }
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
        onCurrentTabChanged: currentChannel = currentTab.channel
    }

    Component.onCompleted: {

        createTab("Server");
    }

    function findButton(channel)
    {
        // Returns the button with text channel, or undefined if not found

        for (var i = 0;i<tabBarLayout.children.length; ++i)
        {
            if (tabBarLayout.children[i].text === channel)
            {
                console.log(channel, "found!")
                return tabBarLayout.children[i]
            }
        }
        // Not found.
        console.log(channel , "not found!")
        return
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
                tabGroup.currentTab = page
    }

    function closeTab(channel)
    {
        var button = findButton(channel)
        if (button)
        {
            console.log("Closing tab ", channel)
            if (channel !== Session.host)
                Session.partChannel(channel)

            button.tab.destroy()
            button.destroy()
        }

    }

    function closeChannelTabs()
    {
        // Close all tabs...
        for (var i = 0;i<tabBarLayout.children.length; ++i)
        {
            closeTab(tabBarLayout.children[i].text)
        }
        // Create a new Server tab...
        createTab("Server")
    }

    function outputToTab(channel, output) {

        var outputChannel
        if (channel === Connection.host)
            outputChannel = "Server"
        else
            outputChannel = channel

        console.log("Sender:", channel)
        console.log("Output tab:", outputChannel)
        console.log("Message:", output)


        var button = findButton(outputChannel)
        if (button) {
            var page = button.tab
            page.outputText.text += output
        }
    }

    function selectTab(channel)
    {
        var button = findButton(channel)
        if(button)
        {
            tabGroup.currentTab = button.tab
            lastChannel = currentChannel
            currentChannel = channel
        }
    }

    function clearTab(channel)
    {
        var outputChannel
        if (channel === Connection.host)
            outputChannel = "Server"
        else
            outputChannel = channel

        console.log("Sender:", channel)
        console.log("Output tab:", outputChannel)

        var button = findButton(outputChannel)
        if (button) {
            var page = button.tab
            page.outputText.text = ""
        }
    }


}



