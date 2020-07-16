import QtQuick 2.12
import QtQuick.Controls 2.5
import QtWebSockets 1.1
import SerialConnection 0.1

Page {
    id: canvPage

    WebSocket{
        id: webSocket
        //url: //"ws://"+ip.localIP+":12350"
        onTextMessageReceived: {
            //console.log("[SOCKET][TEXT] Received message: " + message);
            var s = JSON.parse(message);
            if(!s.base64){
                console.log(message);
                if(s.start){
                    crt.lastX = (s.x / s.maxX) * crt.height*0.8;
                    crt.lastY = (s.y / s.maxX) * crt.height*0.8;
                    crt.oldX = (s.x / s.maxX) * crt.height*0.8;
                    crt.oldY = (s.y / s.maxX) * crt.height*0.8;
                    crt.requestPaint();
                } else{
                    crt.lastX = (s.x / s.maxX) * crt.height*0.8;
                    crt.lastY = (s.y / s.maxX) * crt.height*0.8;
                    crt.requestPaint();
                }
                if(getSerialMsgTimer.send == false){
                    var m = "G";
                    if (relativeSw.position == 1){
                        s.x = s.x * (20)
                        s.y = s.y * (20)
                        m += "91 ";
                    }else
                        m += "0 "
                    m += "X" + s.y + " Y" + s.x;
                    comBox.text = m;
                    //serial.newMessage = "$";//s;//"$J=G91X1.0Y1.0F1000";
                    getSerialMsgTimer.com = m;
                    getSerialMsgTimer.send = true;
                }
            }
        }

        onBinaryMessageReceived: {
            //console.log("[SOCKET][BINARY] Received message: " + message);
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

    Column{
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
            Rectangle {
                height: canvPage.height*0.1
                color: "#00000000"
                width: canvPage.width*0.1
            }
            Switch{
                id: relativeSw
                text: "relative move"
            }
        }

        Label{
            anchors.horizontalCenter: parent.horizontalCenter;
            text: "$J=G91X1.0Y1.0F1000"
            id: comBox

            MouseArea{
                anchors.fill: parent

                onClicked: {
                    comBox.text = "$";
                    getSerialMsgTimer.com = "$";
                    getSerialMsgTimer.send = true;
                }
            }
        }

        Row{
            Canvas{
                id: crt

                height: canvPage.height*0.9
                width: canvPage.width

                property int lastX: 0
                property int lastY: 0
                property int oldX: 0
                property int oldY: 0

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
                        var s = "G0 X" + parseInt(mouseY.toFixed(0)) + " Y" + parseInt(mouseX.toFixed(0));
                        comBox.text = s;
                        //serial.newMessage = s;
                        getSerialMsgTimer.com = s;
                        getSerialMsgTimer.send = true;
                    }

                    onPositionChanged: {
                        crt.requestPaint();
                        var s = "G0 X" + parseInt(mouseY.toFixed(0)) + " Y" + parseInt(mouseX.toFixed(0));
                        comBox.text = s;
                        //serial.newMessage = "$";//s;//"$J=G91X1.0Y1.0F1000";
                        getSerialMsgTimer.com = s;
                        getSerialMsgTimer.send = true;
                    }
                }

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.lineWidth = 5;
                    ctx.strokeStyle = "#0000ff";

                    ctx.beginPath();
                    ctx.moveTo(oldX, oldY);

                    ctx.lineTo(lastX, lastY);
                    ctx.stroke();

                    oldX = lastX;
                    oldY = lastY;
                }
            }
        }
    }
    Serial{
        id: serial
    }

    Component.onCompleted: {
        var ports = serial.AllPortsJSON;
        console.log(ports);
        serial.portName = JSON.parse(ports).portNames[0];
        console.log(serial.portName);
        serial.baudRate = 115200;
        console.log(serial.baudRate);
        serial.beginSerial;
        getSerialMsgTimer.start();
    }

    Timer{
        id: getSerialMsgTimer
        interval: 200
        repeat: true
        running: false

        property string com: "value";
        property bool send: false;

        onTriggered: {
            var m = serial.lastMessage;
            if(m!="")
                console.log(m);

            if(send){
                serial.newMessage = com;
                com = "";
                send = false;
            }
        }
    }
}
