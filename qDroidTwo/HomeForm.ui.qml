import QtQuick 2.12
import QtQuick.Controls 2.5

Page {
    id: page
    width: 600
    height: 400
    property alias hometext: hometext

    title: qsTr("Home")

    Label {
        id: hometext
        x: 217
        y: 191
        text: qsTr("You are on the home page.")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
}

/*##^##
Designer {
    D{i:1;anchors_x:217;anchors_y:191}
}
##^##*/
