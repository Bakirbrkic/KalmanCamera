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
            console.log("[T] Received message: " + message);
        }

        onBinaryMessageReceived: {
            console.log("[B] Received message: " + message);
        }
        onStatusChanged: if (webSocket.status == WebSocket.Error) {
                             console.log("Error: " + webSocket.errorString)
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
                //console.log("saved to: " + path);
                var ba = JSON.stringify(photoPreview.data);
                console.log("[PHOTO PREVIEW] data: " + ba);
                webSocket.sendBinaryMessage(ba);
            }
        }

        focus {
            focusMode: Camera.FocusContinuous
            focusPointMode: Camera.FocusPointAuto
        }

        onCameraStatusChanged: {
            if(camera.cameraStatus == Camera.LoadedStatus){
                console.log("Loaded" + camera.cameraStatus);
                var res = camera.imageCapture.supportedResolutions;
                camera.imageCapture.resolution = res[0];//res[Math.floor(res.length/4)];
                //camera.imageCapture.capture();
                console.log("Resolution is: " + camera.imageCapture.resolution);
            }
            else
                console.log("CS: " + camera.cameraStatus);
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
                    //streamTimer.start();
                }
            }
            Button{
                id: stopSock
                width: cameraPage.width*0.2
                text: "Stop"

                onClicked: {
                    webSocket.active = false;
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
