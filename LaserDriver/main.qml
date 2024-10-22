import QtQuick 2.12
import QtQuick.Controls 2.5

ApplicationWindow {
    id: window
    visible: true
    width: 640
    height: 480
    title: qsTr("Stack")

    //    header: ToolBar {
    //        contentHeight: toolButton.implicitHeight

    //        ToolButton {
    //            id: toolButton
    //            text: stackView.depth > 1 ? "\u25C0" : "\u2630"
    //            font.pixelSize: Qt.application.font.pixelSize * 1.6
    //            onClicked: {
    //                if (stackView.depth > 1) {
    //                    stackView.pop()
    //                } else {
    //                    drawer.open()
    //                }
    //            }
    //        }

    //        Label {
    //            text: stackView.currentItem.title
    //            anchors.centerIn: parent
    //        }
    //    }

    Drawer {
        id: drawer
        width: window.width * 0.66
        height: window.height
        dragMargin: Qt.styleHints.startDragDistance + 5;

        Column {
            anchors.fill: parent

            ItemDelegate {
                text: qsTr("Free Canvas")
                width: parent.width
                onClicked: {
                    stackView.pop();
                    stackView.push("canvasPage.qml");
                    drawer.close();
                }
            }
            ItemDelegate {
                text: qsTr("client Page")
                width: parent.width
                onClicked: {
                    stackView.pop();
                    stackView.push("clientPage.qml");
                    drawer.close();
                }
            }
        }
    }

    StackView {
        id: stackView
        initialItem: "clientPage.qml"
        anchors.fill: parent
    }
}
