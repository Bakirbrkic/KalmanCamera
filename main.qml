import QtQuick 2.12
import QtQuick.Controls 2.5


ApplicationWindow {
    visible: true
    height: 800
    width: 450

    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        CanvasPage {
        }

        CameraPage {
        }


    }

    footer: TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex
        TabButton {
            text: qsTr("Canvas")
        }

        TabButton {
            text: qsTr("Camera")
        }

    }
}
