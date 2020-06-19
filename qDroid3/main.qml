import QtQuick 2.12
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.0

ApplicationWindow {

    id: window
    visible: true
    width: 640
    height: 480
    title: qsTr("Stack")

    header: ToolBar {
        contentHeight: 50//toolButton.implicitHeight
        ToolButton {
            id: toolButton
            text: stackView.depth > 1 ? "Back" : "Menu"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: {
                if (stackView.depth > 1) {
                    stackView.pop()
                } else {
                    drawer.open()
                }
            }
            anchors.left: parent.left
        }

        Label {
            text: stackView.currentItem.title
            anchors.centerIn: parent
        }

        ToolButton {
            text: qsTr("⋮")
            onClicked: drawer.open()
            anchors.right: parent.right
        }
    }

    Drawer {
        id: drawer
        width: window.width * 0.66
        height: window.height
        dragMargin: Qt.styleHints.startDragDistance + 5

        Column {
            anchors.fill: parent

            ItemDelegate {
                text: qsTr("Home")
                width: parent.width
                onClicked: {
                    if(stackView.depth > 1)
                        stackView.pop();
                    drawer.close();
                }
            }

            ItemDelegate {
                text: qsTr("Capture Image")
                width: parent.width
                onClicked: {
                    if(stackView.depth > 1)
                        stackView.pop();
                    stackView.push("Page1Form.qml");
                    drawer.close();
                }
            }
            ItemDelegate {
                text: qsTr("Encode QR")
                width: parent.width
                onClicked: {
                    if(stackView.depth > 1)
                        stackView.pop();
                    stackView.push("Page2Form.qml")
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Popup test")
                width: parent.width
                onClicked: {
                    if(stackView.depth > 1)
                        stackView.pop();
                    stackView.push("Page3.qml")
                    drawer.close()
                }
            }
        }
    }

    StackView {
        id: stackView
        initialItem: "HomeForm.ui.qml"
        anchors.fill: parent
    }

    //if on homepage
    Connections {
        target: stackView.currentItem.title === "Home" ? stackView.currentItem : null
        onGotoEncodeQRRequested: {
            if(stackView.depth > 1)
                stackView.pop();
            stackView.push("Page2Form.qml");
        }
        onGotoCaptureRequested:{
            if(stackView.depth > 1)
                stackView.pop();
            stackView.push("Page1Form.qml");
        }
    }

    Connections {
        target: stackView.currentItem.title === "Capture" ? stackView.currentItem : null
        onTagDecoded: {
            if(stackView.depth > 1){
                stackView.pop();
                stackView.get(stackView.find(function(item) {
                    return item.title === "Home";
                })).tagRecieved(tag);
            }
        }
    }


}
