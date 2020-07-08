import QtQuick 2.12
import QtQuick.Controls 2.5
import SerialConnection 0.1

Page {
    id: canvPage

    Column{

        Row{
            padding: 10
            spacing: 10
            Label{
                text: "Command: "
                anchors.verticalCenter: parent.verticalCenter;
            }
            Switch{

            }

            Label{
                anchors.verticalCenter: parent.verticalCenter;
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

            Button{
                text: "Go Home"

                onPressed: {
                    comBox.text = "G0 X0 Y0";
                    getSerialMsgTimer.com = "G0 X0 Y0";
                    getSerialMsgTimer.send = true;
                    crt.clear();
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
                    ctx.moveTo(lastX, lastY);
                    lastX = tch.mouseX;
                    lastY = tch.mouseY;
                    ctx.lineTo(lastX, lastY);
                    ctx.stroke();
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
