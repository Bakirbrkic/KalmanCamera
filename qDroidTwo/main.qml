import QtQuick 2.12
import QtQuick.Controls 2.5

ApplicationWindow {
    id: window
    visible: true
    width: 640
    height: 480
    title: qsTr("Stack")

    //Top Bar of the app
    header: ToolBar {
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            text: stackView.depth > 1 ? "\u25C0" : "Menu"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: {
                if (stackView.depth > 1) {
                    stackView.pop()
                } else {
                    drawer.open()
                }
            }
        }

        Label {
            text: stackView.currentItem.title
            anchors.centerIn: parent
        }


    }
    //end of Top Bar

    //Drawer
    Drawer {
        id: drawer
        width: window.width * 0.8
        height: window.height
        dragMargin: Qt.styleHints.startDragDistance + 5

        Column {
            anchors.fill: parent

            ItemDelegate {
                text: qsTr("Empty Home Page")
                width: parent.width
                onClicked: {
                    if(stackView.currentItem.title !== text)
                        stackView.push("Page1Form.qml");
                    drawer.close();
                    stackView.focus = true;
                }
            }
            ItemDelegate {
                text: qsTr("Server Page")
                width: parent.width
                onClicked: {
                    if(stackView.currentItem.title !== text)
                        stackView.push("Page2.qml");
                    drawer.close();
                    stackView.focus = true;
                }
            }
            ItemDelegate {
                text: qsTr("Client Page")
                width: parent.width
                onClicked: {
                    if(stackView.currentItem.title !== text)
                        stackView.push("Page3.qml");
                    drawer.close();
                    stackView.focus = true;
                }
            }
        }
    }
    //end of drawer

    //App content
    StackView {
        id: stackView
        initialItem: "HomeForm.ui.qml"
        anchors.fill: parent
        focus: true

        Keys.onBackPressed: {
            event.accepted = true;
            if(stackView.depth > 1)
            {
                stackView.pop();
            }
            else
            {
                toastAnchor.ToolTip.text = "This is the Home Page";
                toastAnchor.ToolTip.visible = true;
            }
        }
    }
    //end of app content

    //toast messages
    Rectangle{
        id: toastAnchor
        height: 0
        width: window.width
        anchors.bottom: parent.bottom

        ToolTip.text: ""
        ToolTip.visible: false
        ToolTip.timeout: 2000
        ToolTip.delay: 500
    }
    //end of toast message
}
