import QtQuick 2.12
import QtQuick.Controls 2.5
import QtWebSockets 1.1
import ba.bamzar.deviceIp 1.0

Page {
    DeviceIp{
        id: ip
    }

    WebSocket{
        id: webSocket
        //url: //"ws://"+ip.localIP+":12350"
        onTextMessageReceived: {
            console.log(" Received message: " + message);
        }
        onStatusChanged: if (webSocket.status == WebSocket.Error) {
                             console.log("Error: " + webSocket.errorString)
                         } else if (webSocket.status == WebSocket.Open) {

                         } else if (webSocket.status == WebSocket.Closed) {

                         }
        active: false
    }

    id: canPage
    title: qsTr("Page 3")

    Column{
        id: column
        anchors.fill: parent
        Row{
            TextField{
                id: recIp
                text: "192.168.1.102"
            }
            Text {
                text: ":"
            }
            TextField{
                id: recPort
                //text: "12350"
                text: "20000"
            }
            Button{
                id: startSock
                width: canPage.width*0.2
                text: "Start"

                onClicked: {
                    webSocket.url = "ws://"+recIp.text+":"+recPort.text;
                    console.log(webSocket.url);
                    webSocket.active = true;
                }
            }
        }

        Canvas{
            id: crt

            height: canPage.height - 50
            width: canPage.width

            property int lastX: 0
            property int lastY: 0

            function clear(){
                var ctx = getContext("2d");
                ctx.reset();
                crt.requestPaint();
            }

            MouseArea{
                id: tch
                anchors.fill: parent

                onPressed: {
                    crt.lastX = mouseX;
                    crt.lastY = mouseY;
                    var s = {x: parseInt(mouseX.toFixed(0)), y: parseInt(mouseY.toFixed(0)), maxX: canPage.width, maxY: canPage.height, start: true}
                    webSocket.sendTextMessage(JSON.stringify(s));
                }

                onPositionChanged: {
                    crt.requestPaint();
                    canPage.title = "x: " + mouseX.toFixed(0) +" y: " + mouseX.toFixed(0);
                    var s = {x: parseInt(mouseX.toFixed(0)), y: parseInt(mouseY.toFixed(0)), maxX: canPage.width, maxY: canPage.height, start: false}
                    webSocket.sendTextMessage(JSON.stringify(s));
                }
            }

            onPaint: {
                var ctx = getContext("2d");
                ctx.lineWidth = 5;
                ctx.beginPath();
                ctx.moveTo(lastX, lastY);
                lastX = tch.mouseX;
                lastY = tch.mouseY;
                ctx.lineTo(lastX, lastY);
                ctx.stroke();
            }
        }
    }

}
