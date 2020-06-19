import QtQuick 2.12
import QtQuick.Controls 2.5
import QZXing 2.3

Page {
    id: page
    title: qsTr("Generate QR code")

    Column {
        id: column
        anchors.fill: parent

        Rectangle {
            id: rectangle
            width: column.width
            height: button.height
            color: "#00000000"

            TextField {
                id: textField
                width: rectangle.width*0.75
                text: qsTr("Text Field")
                horizontalAlignment: Text.AlignHCenter
            }

            Button {
                id: button
                x: 120
                y: 0
                text: qsTr("Generate QR")
                anchors.right: parent.right
                anchors.rightMargin: 0
                width: rectangle.width*0.25

                onPressed: {
                    image.source = "http://api.qrserver.com/v1/create-qr-code/?data="+textField.text+"&size=200x200";
                }
            }
        }

        Image {
            id: image
            width: column.width
            sourceSize.height: 0
            fillMode: Image.PreserveAspectFit
            source: "iron.png"
        }
    }

    QZXing{
        id: encoder
    }
}

/*##^##
Designer {
    D{i:5;anchors_height:100;invisible:true}D{i:1;anchors_width:600;anchors_y:61}
}
##^##*/
