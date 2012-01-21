// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1

Page {
    id: window

    tools: ToolBarLayout {
        id: settingsToolBarLayout

        ToolButton {
            flat: true
            iconSource: "toolbar-back"
            onClicked: {
                pageStack.pop()
            }
        }
    }

}
