import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: page1
    focus: true

    property alias connected: inputField.enabled


    TextField {
        id: inputField
        focus: true
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        platformRightMargin: returnButton.width + platformStyle.paddingSmall
        placeholderText: "Tap to write..."
        inputMethodHints: Qt.ImhNoPredictiveText
        Keys.onEnterPressed: {
            var page = outputTabGroup.currentTab
            var inputChannel = page.channel
            //console.log(inputChannel, inputField.text)
            if (inputChannel === "Server")
                inputChannel = Session.host

            Session.onInputReceived(inputChannel, inputField.text)
            inputField.text = "";

        }
        //Required for the simulator...
        Keys.onReturnPressed: {
            var page = outputTabGroup.currentTab
            var inputChannel = page.channel
            //console.log(inputChannel, inputField.text)
            if (inputChannel === "Server")
                inputChannel = Session.host

            Session.onInputReceived(inputChannel, inputField.text)
            inputField.text = "";
        }
        onEnabledChanged: {
            returnButton.enabled = enabled
        }


        Button {
            id: returnButton
            //anchors.left: inputField.right
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: inputField.height
            iconSource: "icon-return.svg"
            enabled: inputField.enabled
            width: height
            onClicked: {
                var page = outputTabGroup.currentTab
                var inputChannel = page.channel
                //console.log(inputChannel, inputField.text)
                if (inputChannel === "Server")
                    inputChannel = Session.host

                Session.onInputReceived(inputChannel, inputField.text)
                inputField.text = "";

            }
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
        TabButton {
            id: serverButton
            text: "Server"
            tab: serverPage
        }
    }

    TabGroup {
        id: outputTabGroup
        anchors.bottomMargin: 0
        anchors.top: outputTabBarLayout.bottom
        anchors.right: parent.right
        anchors.bottom: inputField.top
        anchors.left: parent.left
        anchors.topMargin: 0
        onCurrentTabChanged: {
            Session.currentChannel = outputTabGroup.currentTab.channel
            //console.log("Current tab:" + currentChannel)
            if(Session.currentChannel === "Server")
            {
                buttonUsers.enabled = false
                partChannel.visible = false
                //inputField.enabled = false
                //returnButton.enabled = false
                enterChannel.visible = true
                selectChannelFromList.visible = true
            }
            else if (Session.isValidChannelName(Session.currentChannel))
            {
                // currentTab is a channel...
                buttonUsers.enabled = true
                partChannel.visible = true
                enterChannel.visible = true
                selectChannelFromList.visible = true
                closeQuery.visible = false
                //inputField.enabled = true
                //returnButton.enabled = true
            }
            else
            {
                // currentTab is a query tab
                buttonUsers.enabled = false
                partChannel.visible = false
                enterChannel.visible = false
                selectChannelFromList.visible = false
                closeQuery.visible = true
            }
        }
        TabPage {
            id: serverPage
            channel: "Server"
        }

    }

    Component.onCompleted: {

        //createTab("Server")
    }

    function findButton(channel)
    {
        // Returns the button with text channel, or undefined if not found

        for (var i = 0;i<outputTabBarLayout.children.length; ++i)
        {
            if (outputTabBarLayout.children[i].text === channel)
            {
                //console.log(channel, "found!")
                return outputTabBarLayout.children[i]
            }
        }
        // Not found.
        //console.log(channel , "not found!")
        return
    }

    // Create a tab for channel
    function createTab(channel)
    {
        // Create an OutputFlickable item, attach it to the TabGroup
        var pageFactory = Qt.createComponent("TabPage.qml")
        var page = pageFactory.createObject(outputTabGroup)

        // Create the TabButton and attach it to the TabBarLayout.
        var button = Qt.createQmlObject("import QtQuick 1.1; import com.nokia.symbian 1.1; TabButton{}", outputTabBarLayout)
        //console.log("Creating tab %s",channel)

        // set the TabButton text and the OutputFlickable text property
        button.text = channel
        page.channel = channel
        // page.outputText.text = ""
        button.tab = page
        outputTabGroup.currentTab = page
    }

    // Remove the tab with text property channel from the TabBarLayout
    function closeTab(channel)
    {
        // Find the correct TabButton. findButton() returns undefined if
        // no button is found.
        var button = findButton(channel)
        if (button)
        {
            //console.log("Closing tab ", channel)
            // If the channel isn't the server and it begins with #,
            // (and is therefore a channel, leave it.
            if ((channel !== Session.host) && (channel.charAt(0) === '#'))
                Session.partChannel(channel)

            // Destroy the OutputFlickable (button.tab) and the TabButton
            button.tab.destroy()
            button.destroy()

        }

    }

    function closeAllTabs()
    {
        // Close all tabs except the Server tab...
        for (var i = 0;i<outputTabBarLayout.children.length; ++i)
        {
            if (outputTabBarLayout.children[i].text !== "Server")
                closeTab(outputTabBarLayout.children[i].text)
        }
    }

    function outputToTab(channel, output) {

        var outputChannel
        if (channel === Session.host)
            outputChannel = "Server"
        else
            outputChannel = channel

        //console.log("Sender:", channel)
        //console.log("Output tab:", outputChannel)
        //console.log("Message:", output)


        var button = findButton(outputChannel)
        if (button) {
            var page = button.tab
            page.addOutput(output)
        }

    }

    function selectTab(channel)
    {
        var button = findButton(channel)
        if(button)
        {
            outputTabGroup.currentTab = button.tab
            Session.lastChannel = Session.currentChannel
            Session.currentChannel = channel
        }
    }

    function clearTab(channel)
    {
        var outputChannel
        if (channel === Session.host)
            outputChannel = "Server"
        else
            outputChannel = channel

        //console.log("Sender:", channel)
        //console.log("Output tab:", outputChannel)

        var button = findButton(outputChannel)
        if (button) {
            var page = button.tab
            page.clear()
        }
    }

    function dropToBottom()
    {
        // Drops the ListView in the currently selected Tab
        // to the bottom.
        var button = findButton(Session.currentChannel)
        if (button) {
            var page = button.tab
            page.dropToBottom()
        }
    }
}



