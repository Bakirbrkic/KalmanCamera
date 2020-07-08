import QtQuick 2.12
import QtQuick.Controls 2.5
import QtMultimedia 5.12
import QtWebSockets 1.1
import ba.bamzar.img2base64 1.0


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

    Img2base64{
        id:i2b

        onEncoded: {
            console.log("[IMG_2_BASE64] encoding done");
            photoPreview.source = encode2base64;
            //console.log("[IMG_2_BASE64] base64: " + encode2base64);
            var s = {base64: true};
            s.img = encode2base64;
            //console.log("[IMG_2_BASE64] JSON MESSAGE: " + JSON.stringify(s));
            webSocket.sendTextMessage(JSON.stringify(s));
        }
    }

    Camera {
        id: camera
        deviceId: QtMultimedia.availableCameras[cameraSide.currentIndex].deviceId
        //captureMode: Camera.CaptureViewfinder
        cameraState: Camera.UnloadedState;

        imageCapture {

            onImageCaptured: {
                // Show the preview in an Image
                //photoPreview.source = preview;

                //webSocket.sendBinaryMessage(0x1);
                //webSocket.sendBinaryMessage(preview);
                //webSocket.sendTextMessage("1");
            }
            onImageSaved: {
                console.log("[CAMERA] saved to: " + path);
                i2b.encode2base64 = path;
                //webSocket.sendBinaryMessage(ba);
            }
        }

        onCameraStateChanged: {
            if(cameraState == Camera.UnloadedState){
                console.log("[CAMERA] camera not loaded");
            }
            else if(cameraState == Camera.LoadedState){
                console.log("[CAMERA] camera loaded");
                f.focusMode = Camera.FocusContinuous;
                f.focusPointMode = Camera.FocusPointAuto;
            }
        }

        focus {
            id: f
            focusMode: Camera.FocusContinuous
            focusPointMode: Camera.FocusPointAuto
        }

        onCameraStatusChanged: {
            if(camera.cameraStatus == Camera.LoadedStatus){
                console.log("[CAMERA] loaded, status: " + camera.cameraStatus);
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
            TextField{
                width: cameraPage.width*0.70
                height: cameraPage.height*0.1
                id: recIp
                text: "192.168.10.100"
                horizontalAlignment: Text.AlignHCenter
                color: "#ff0000"

                selectByMouse: true
            }
            Text {
                width: cameraPage.width*0.05
                color: "#ffffff"
                text: ":"
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize: 22
            }
            TextField{
                width: cameraPage.width*0.25
                height: cameraPage.height*0.1
                id: recPort
                text: "20000"

                selectByMouse: true
            }
        }


        Row{
            height: cameraPage.height*0.1
            VideoOutput {
                autoOrientation: true;
                id: viewfinder
                source: camera
                focus : visible // to receive focus and capture key events when visible
                width: cameraPage.width*0.2
                height: parent.height

                MouseArea {
                    anchors.fill: parent;

                    onPressed: {
                        camera.imageCapture.capture();
                    }

                }
            }
            Button{
                id: startSock
                width: cameraPage.width*0.6
                height: cameraPage.height*0.1
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
                width: cameraPage.width*0.3
                height: cameraPage.height*0.1
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
                width: cameraPage.width*0.3
                height: cameraPage.height*0.1
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
            ComboBox{
                id: cameraSide
                width: cameraPage.width*0.2
                height: cameraPage.height*0.1

                model: ["Main", "Selfie"]

                onCurrentIndexChanged: {
                    camera.deviceId = QtMultimedia.availableCameras[cameraSide.currentIndex].deviceId
                }
            }

        }



        Row{
            height: cameraPage.height*0.7
            Image {
                id: photoPreview
                fillMode: Image.PreserveAspectFit
                height: parent.height
                width: cameraPage.width

                MouseArea {
                    anchors.fill: parent;

                    onPressed: {
                        camera.imageCapture.capture();
                    }

                }
            }
        }


        Row{
            height: cameraPage.height*0.1

            Switch{
                id: cameraSwitch
                height: cameraPage.height*0.1
                text: "Camera"

                onToggled: {
                    console.log("[CAMERA SWITCH] " + cameraSwitch.position)
                    try{
                        console.log("[CAMERA SWITCH] available cameras: " + QtMultimedia.availableCameras[0].displayName + ", " + QtMultimedia.availableCameras[1].displayName)
                    } catch(e) {
                        console.log("[CAMERA SWITCH] no multiple cameras");
                        cameraSide.visible = false;

                    }

                    if(camera.cameraState == Camera.UnloadedState && cameraSwitch.position == 1){
                        console.log("[CAMERA] camera will start loading");
                        camera.cameraState = Camera.LoadedState;
                        camera.start();
                        cameraSide.visible = false;
                    }
                    else if(camera.cameraState == 2 && cameraSwitch.position == 0){
                        console.log("[CAMERA] camera will disconnect");
                        camera.stop();
                        camera.cameraState = Camera.UnloadedState;
                        cameraSide.visible = true;
                    }
                }
            }

            Button{
                width: cameraPage.width - cameraSwitch.width - fpsButton.width
                height: cameraPage.height*0.1
                text: streamTimer.running ? "Stop Sending Frames" : "Start Sending Frames"

                onPressed: {
                    if(streamTimer.running)
                        streamTimer.running = false;
                    else
                        streamTimer.running = true;

                    console.log("[TIMER] timer running: " + streamTimer.running);
                }
            }
            ComboBox{
                id:fpsButton
                width: cameraPage.width*0.2
                height: cameraPage.height*0.1

                model: ["1", "5", "10", "15", "20"]

                onCurrentTextChanged: {
                    var div = parseInt(currentText);
                    streamTimer.interval = 1000/div;
                    console.log("[TIMER] current interval: " + streamTimer.interval);
                }
            }
        }

    }

    Timer{
        id: streamTimer
        interval: 1000
        repeat: true
        running: false//true

        onTriggered: {
            if(webSocket.status == WebSocket.Open)
            camera.imageCapture.capture();
        }
    }

}
