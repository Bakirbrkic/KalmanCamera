import QtQuick 2.12
import QtQuick.Controls 2.5

Page {
    title: "Popup Test"


    Column{

        anchors.fill: parent

        Rectangle{
            id: song
            width: parent.width
            height: 100

            Rectangle{
                color: "red"
                anchors.fill: parent

                MouseArea{
                    anchors.fill: parent
                    onPressed: {
                        popup.open();
                    }
                }
            }

            Text {
                id: element
                text: qsTr("Song")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 48
            }

            Popup {
                id: popup
//                anchors.centerIn: song
                width: parent.width
                height: 400
                modal: true
                focus: true
                padding: 0
                margins: 0
                transformOrigin: Popup.Top
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                Rectangle{
                    color: "red"
                    height: 300
                    width: parent.width
                }

                Row{
                    width: song.width
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    height: 100
                    visible: true
                    Rectangle{
                        color: "blue"
                        height: 100
                        width: parent.width*0.333
                    }
                    Rectangle{
                        color: "green"
                        height: 100
                        width: parent.width*0.333
                    }
                    Rectangle{
                        color: "white"
                        height: 100
                        width: parent.width*0.333
                    }
                }
            }


        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:3;anchors_height:100;anchors_width:640}
}
##^##*/
