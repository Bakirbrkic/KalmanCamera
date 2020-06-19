import QtQuick 2.12
import QtQuick.Controls 2.5
import ba.bamzar.ocvCameraFrame 1.0

Page {
    id: canvPage
    property alias outWidth: out.width

    OcvCameraFrame{
        id: ocf
    }

    Row{
        id: imRow
        height: canvPage.height*0.5
        width: canvPage.width
        Image{
            id: im
            anchors.fill: parent
        }
    }

    Row{
        id: textRow
        height: canvPage.height*0.5
        anchors.top: imRow.bottom
        anchors.topMargin: 0
        width: canvPage.width
        Text {
            id: out
            width: out.contentWidth
            height: out.contentHeight
            text: "Take a Picture"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 43


            MouseArea{
                anchors.fill: parent

                onClicked: {
                    //out.text = ocf.capture
                    var i = ocf.captureImage
                    console.log("[OCF] captureImage returned: " + i);
                    im.source = i;
                }
            }
        }
    }



}
