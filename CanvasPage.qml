import QtQuick 2.12
import QtQuick.Controls 2.5
import QtMultimedia 5.12
import QtWebSockets 1.1

Page {
    id: canvPage

    WebSocket{
        id: webSocket
        //url: //"ws://"+ip.localIP+":12350"
        onTextMessageReceived: {
            console.log("[SOCKET][TEXT] Received message: " + message);
        }

        onBinaryMessageReceived: {
            console.log("[SOCKET][BINARY] Received message: " + message);
        }
        onStatusChanged: if (webSocket.status == WebSocket.Error) {
                             console.log("[SOCKET] Error: " + webSocket.errorString)
                         } else if (webSocket.status == WebSocket.Open) {
                             console.log("[SOCKET] Socket is open!");
                             startSock.visible = false;
                             toggleSock.visible = true;
                             stopSock.visible = true;
                             recIp.color = "#00ff00";
                         } else if (webSocket.status == WebSocket.Closed) {
                             console.log("[SOCKET] Socket is closed");
                             recIp.color = "#ff0000";
                         }
        active: false
    }

    Column {
        anchors.fill: parent

        Row{
            height: canvPage.height*0.1
            TextField{
                width: canvPage.width*0.70
                height: canvPage.height*0.1
                id: recIp
                text: "192.168.10.100"
                horizontalAlignment: Text.AlignHCenter
                color: "#ff0000"

                selectByMouse: true
            }
            Text {
                width: canvPage.width*0.05
                color: "#ffffff"
                text: ":"
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: 22
            }
            TextField{
                width: canvPage.width*0.25
                height: canvPage.height*0.1
                id: recPort
                text: "20000"

                selectByMouse: true
            }
        }


        Row{
            height: canvPage.height*0.1
            Rectangle {
                height: canvPage.height*0.1
                color: "#00000000"
                width: canvPage.width*0.2
            }
            Button{
                id: startSock
                width: canvPage.width*0.6
                height: canvPage.height*0.1
                text: "Connect Socket"
                flat: false

                onClicked: {
                    if(recPort.text != ".")
                        webSocket.url = "ws://"+recIp.text+":"+recPort.text;
                    else
                        webSocket.url = "ws://"+recIp.text;
                    console.log(webSocket.url);
                    webSocket.active = true;
                    console.log("[SOCKET] socket status: " + webSocket.status);

                    //toggleSock.visible = true;

                    //streamTimer.start();
                }
            }
            Button{
                id: toggleSock
                width: canvPage.width*0.3
                height: canvPage.height*0.1
                text: webSocket.active ? "Pause Socket" : "Resume Socket";
                visible: false;

                onClicked: {
                    if(webSocket.active == true && toggleSock.text == "Pause Socket"){
                        webSocket.active = false;
                        console.log("[SOCKET] socket status: " + webSocket.status);
                    } else if(webSocket.active == false && toggleSock.text == "Resume Socket"){
                        webSocket.active = true;
                        console.log("[SOCKET] socket status: " + webSocket.status);
                    }
                    //streamTimer.stop();
                }
            }
            Button{
                id: stopSock
                width: canvPage.width*0.3
                height: canvPage.height*0.1
                text: "Disonnect Socket"

                visible: false;

                onClicked: {
                    webSocket.url = "";
                    webSocket.active = false;
                    console.log("[SOCKET] socket status: " + webSocket.status);
                    toggleSock.visible = false;
                    startSock.visible = true;
                    stopSock.visible = false;

                    //streamTimer.start();
                }
            }
        }


        Row{
            Canvas{
                id: crt

                height: canvPage.height*0.7
                width: canvPage.width

                property bool sendToSock: true
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
                        var s = {x: parseInt(mouseX.toFixed(0)), y: parseInt(mouseY.toFixed(0)), maxX: canvPage.width, maxY: canvPage.height*0.8, start: true}
                        if(crt.sendToSock)
                            webSocket.sendTextMessage(JSON.stringify(s));
                    }

                    onPositionChanged: {
                        crt.requestPaint();
                        var s = {x: parseInt(mouseX.toFixed(0)), y: parseInt(mouseY.toFixed(0)), maxX: canvPage.width, maxY: canvPage.height*0.8, start: false}
                        if(crt.sendToSock)
                            webSocket.sendTextMessage(JSON.stringify(s));
                    }
                }

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.lineWidth = 5;
                    ctx.strokeStyle = "#ffffff";
                    ctx.beginPath();
                    ctx.moveTo(lastX, lastY);
                    lastX = tch.mouseX;
                    lastY = tch.mouseY;
                    ctx.lineTo(lastX, lastY);
                    ctx.stroke();
                }
            }
        }

        Row{
            Button{
                width: canvPage.width*0.3
                height: canvPage.height*0.1
                text: "Clear Canvas"

                onPressed: {
                    crt.clear();
                }
            }
            Button{
                width: canvPage.width*0.7
                height: canvPage.height*0.1
                text: noiseTimer.running ? "Stop Noise" : "Start Noise"

                onPressed: {
                    if(noiseTimer.running){
                        noiseTimer.running=false;
                        crt.sendToSock = true
                    }else{
                        noiseTimer.running=true;
                    }
                }
            }
        }

    }

    Timer{
        id: noiseTimer
        interval: 300
        repeat: true;
        running: false

        onTriggered: {
            if(crt.sendToSock)
                crt.sendToSock = false
            else
                crt.sendToSock = true
        }
    }
}
