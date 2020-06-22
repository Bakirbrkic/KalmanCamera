import QtQuick 2.12
import QtQuick.Controls 2.5
import QtMultimedia 5.12
import QtWebSockets 1.1


Page {
    id: cameraPage
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
                         } else if (webSocket.status == WebSocket.Closed) {
                            console.log("[SOCKET] Socket is closed");
                         }
        active: false
    }

    Camera {
        id: camera
        //captureMode: Camera.CaptureViewfinder

        imageCapture {

            onImageCaptured: {
                // Show the preview in an Image
                photoPreview.source = preview;

                //webSocket.sendBinaryMessage(0x1);
                //webSocket.sendBinaryMessage(preview);
                //webSocket.sendTextMessage("1");
            }
            onImageSaved: {
                console.log("[CAMERA] saved to: " + path);
                //webSocket.sendBinaryMessage(ba);
            }
        }

        focus {
            focusMode: Camera.FocusContinuous
            focusPointMode: Camera.FocusPointAuto
        }

        onCameraStatusChanged: {
            if(camera.cameraStatus == Camera.LoadedStatus){
                console.log("[CAMERA] loaded" + camera.cameraStatus);
                var res = camera.imageCapture.supportedResolutions;
                camera.imageCapture.resolution = res[0];//res[Math.floor(res.length/4)];
                //camera.imageCapture.capture();
                console.log("[CAMERA] resolution is: " + camera.imageCapture.resolution);
            }
            else
                console.log("[CAMERA] camera status: " + camera.cameraStatus);
        }
    }

    Column {
        anchors.fill: parent
        Row{
            height: cameraPage.height*0.1
            Image {
                id: photoPreview
                fillMode: Image.PreserveAspectFit
                height: 100
                width: cameraPage.width*0.2
            }
            TextField{
                width: cameraPage.width*0.25
                id: recIp
                text: "192.168.10.100"
            }
            Text {
                text: ":"
            }
            TextField{
                width: cameraPage.width*0.15
                id: recPort
                text: "20000"
            }
            Button{
                id: startSock
                width: cameraPage.width*0.2
                text: "Start"

                onClicked: {
                    webSocket.url = "ws://"+recIp.text+":"+recPort.text;
                    console.log(webSocket.url);
                    webSocket.active = true;
                    console.log("[SOCKET] socket status: " + webSocket.status);
                    //streamTimer.start();
                }
            }
            Button{
                id: stopSock
                width: cameraPage.width*0.2
                text: "Stop"

                onClicked: {
                    webSocket.active = false;
                    console.log("[SOCKET] socket status: " + webSocket.status);
                    streamTimer.stop();
                }
            }
        }



        Row{
            height: cameraPage.height*0.9
            VideoOutput {
                autoOrientation: true;
                id: viewfinder
                source: camera
                focus : visible // to receive focus and capture key events when visible
                width: cameraPage.width
                height: parent.height

                MouseArea {
                    anchors.fill: parent;

                    onPressed: {
                        camera.imageCapture.capture();
                    }

                }
            }
        }
    }

    Timer{
        id: streamTimer
        interval: 40
        repeat: true
        running: false//true

        onTriggered: {
            ocf.capture;
            //if(webSocket.status == WebSocket.Open)
                //camera.imageCapture.capture();
        }
    }

}
