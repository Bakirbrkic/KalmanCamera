import QtQuick 2.12
import QtQuick.Controls 2.5

Page {
    id: page

    signal gotoCaptureRequested
    signal gotoEncodeQRRequested
    signal tagRecieved(string tag)

    topPadding: 20

    title: qsTr("Home")

    Column {
        id: column
        width: 200
        height: 190
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5

        TextField {
            id: textInput
            width: page.width - 50
            color: "#ffffff"
            text: qsTr("Scanned data will appear here")
            verticalAlignment: Text.AlignVCenter
            selectByMouse: true
            horizontalAlignment: Text.AlignHCenter
            cursorVisible: true
            readOnly: false
            font.family: "Arial"
            font.pointSize: 22
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            id: gotoCapture
            text: qsTr("Scan a QR Code")
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            id: gotoEncodeqr
            text: qsTr("Create a QR code")
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Connections {
        target: gotoCapture
        onPressed: gotoCaptureRequested()
    }

    Connections {
        target: gotoEncodeqr
        onPressed: gotoEncodeQRRequested()
    }

    Connections {
        target: page
        onTagRecieved: {
            console.log("home form recieved tag " + tag)
            textInput.text = tag
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:3;anchors_height:100;anchors_width:100}
D{i:4;anchors_height:100;anchors_width:100}D{i:1;anchors_height:400;anchors_width:200}
}
##^##*/

