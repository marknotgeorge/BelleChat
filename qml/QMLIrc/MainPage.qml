import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: page1

    TextField {
        id: inputField
        x: 0
        y: 530
        height: 50
        text: ""
        focus: true
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        placeholderText: "Tap to write..."
        inputMethodHints: Qt.ImhNoPredictiveText
        Keys.onEnterPressed: {
            var page = outputTabGroup.currentTab
            console.log(inputField.text);
            Session.onInputReceived(page.channel, inputField.text);
            inputField.text = "";
        }
    }

    TabBarLayout {
        id: outputTabBarLayout
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0


    }

    TabGroup {
        id: outputTabGroup
        anchors.bottomMargin: 0
        anchors.top: outputTabBarLayout.bottom
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

        for (var i = 0;i<outputTabBarLayout.children.length; ++i)
        {
            if (outputTabBarLayout.children[i].text === channel)
            {
                console.log(channel, "found!")
                return outputTabBarLayout.children[i]
            }
        }
        // Not found.
        console.log(channel , "not found!")
        return
    }

    // Create a tab for channel
    function createTab(channel)
    {
        // Create an OutputFlickable item, attach it to the TabGroup
        var pageFactory = Qt.createComponent("OutputFlickable.qml")
        var page = pageFactory.createObject(outputTabGroup)

        // Create the TabButton and attach it to the TabBarLayout.
        var button = Qt.createQmlObject("import QtQuick 1.1; import com.nokia.symbian 1.1; TabButton{}", outputTabBarLayout)
        //console.log("Creating tab %s",channel)

        // set the TabButton text and the OutputFlickable text property
        button.text = channel
        page.channel = channel
        page.outputText.text = ""
        button.tab = page
        outputTabGroup.currentTab = page
    }

    // Remove the tab with text property channel fro hte TabBarLayout
    function closeTab(channel)
    {
        // Find the correct TabButton. findButton() returns undefined if
        // no button is found.
        var button = findButton(channel)
        if (button)
        {
            console.log("Closing tab ", channel)
            // If the channel isn't the server, leave the channel
            if (channel !== Session.host)
                Session.partChannel(channel)

            // Destroy the OutputFlickable (button.tab) and the TabButton
            button.tab.destroy()
            button.destroy()
        }

    }

    function closeAllTabs()
    {
        // Close all tabs...
        for (var i = 0;i<outputTabBarLayout.children.length; ++i)
        {
            closeTab(outputTabBarLayout.children[i].text)
        }
    }

    function outputToTab(channel, output) {

      var outputChannel
       if (channel === Session.host)
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
            outputTabGroup.currentTab = button.tab
            lastChannel = currentChannel
            currentChannel = channel
        }
    }

    function clearTab(channel)
    {
        var outputChannel
        if (channel === Session.host)
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



