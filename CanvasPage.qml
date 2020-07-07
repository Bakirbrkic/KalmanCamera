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

                property int noiseType: noiseTypeGroup.checkedButton.noiseType
                property bool sendToSock: true
                property bool fuzzyOn: false
                property int fuzzinessAmount: 10
                property int fuzziness: fuzzinessAmount

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
                            s.noise = false;
                        else
                            s.noise = true;
                        if(crt.fuzzyOn){
                            s.y += crt.fuzziness;
                            s.x += crt.fuzziness;
                        }
                        s.base64 = false;
                        webSocket.sendTextMessage(JSON.stringify(s));
                    }

                    onPositionChanged: {
                        crt.requestPaint();
                        var s = {x: parseInt(mouseX.toFixed(0)), y: parseInt(mouseY.toFixed(0)), maxX: canvPage.width, maxY: canvPage.height*0.8, start: false}
                        if(crt.sendToSock)
                            s.noise = false;
                        else
                            s.noise = true;
                        if(crt.fuzzyOn){
                            s.y += crt.fuzziness;
                            s.x += crt.fuzziness;
                        }
                        s.base64 = false;
                        webSocket.sendTextMessage(JSON.stringify(s));
                    }
                }

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.lineWidth = 5;
                    if(!sendToSock && !fuzzyOn){ //com delay
                        ctx.strokeStyle = "#00ffff";
                    } else if(fuzzyOn && sendToSock){ //fuzzy
                        ctx.strokeStyle = "#ff00ff";
                    } else if(fuzzyOn && !sendToSock){ //both
                        ctx.strokeStyle = "#ffff00";
                    } else //no noise
                        ctx.strokeStyle = "#ffffff";

                    ctx.beginPath();
                    ctx.moveTo(lastX, lastY);
                    lastX = crt.fuzzyOn ? tch.mouseX + crt.fuzziness : tch.mouseX;
                    lastY = crt.fuzzyOn ? tch.mouseY + crt.fuzziness : tch.mouseY;
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
                width: canvPage.width*0.4
                height: canvPage.height*0.1
                text: noiseTimer.running ? "Stop Noise" : "Start Noise"

                onPressed: {
                    console.log("[NOISE] Selected noise type: " + noiseTypeGroup.checkedButton.noiseType + " " + noiseTypeGroup.checkedButton.text);
                    if(noiseTimer.running){
                        noiseTimer.running = false;
                        fuzzyTimer.running = false;
                        crt.sendToSock = true;
                        crt.fuzzyOn = false;
                    }else{
                        noiseTimer.running = true;
                        fuzzyTimer.running = true;
                    }
                }
            }
            Button{
                width: canvPage.width*0.3
                height: canvPage.height*0.1
                text: "Edit Noise"

                onPressed: {
                    noiseSettings.open();
                }
            }
        }

    }

    Popup {
        id: noiseSettings

        anchors.centerIn: parent
        width: parent.width-20
        modal: true
        focus: true
        padding: 0
        margins: 10
        transformOrigin: Popup.Top
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Column{
            width: parent.width-20
            spacing: 10
            padding: 10


            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 16
                color: "#ffffff"
                text: "Noise Settings"
            }

            ButtonGroup {
                id: noiseTypeGroup
                buttons: noiseTypeGroupButtons.children

                onClicked: {
                    console.log("[NOISE TYPE] selected: " + noiseTypeGroup.checkedButton.noiseType + " " + noiseTypeGroup.checkedButton.text);
                    crt.sendToSock = true;
                }
            }

            Label{
                text: "Noise Type"
            }

            Row{
                id: noiseTypeGroupButtons
                RadioButton {
                    text: "Communication delay"
                    checked: true
                    property int noiseType: 0
                }
                RadioButton {
                    text: "Fuzzy coordinats"
                    property int noiseType: 1
                }
                RadioButton {
                    text: "Both"
                    property int noiseType: 2
                }
            }

            Row{
                Label{
                    text: "Communication Delay Interval: "
                }
                Label{
                    text: noiseSlider.enabled ? noiseSlider.value + " ms" : "Random [10, 500] ms"
                }
            }

            Row{
                Slider{
                    id: noiseSlider
                    width: noiseSettings.width-40-noiseRandBox.width
                    value: noiseTimer.interval
                    stepSize: 10
                    from: 100
                    to: 1000

                    onMoved: {
                        saved.text = "Settings have been edited, but not saved";
                        saved.color = "#ff0000";
                    }
                }
                CheckBox{
                    id: noiseRandBox
                    text: "Rand."

                    onCheckStateChanged: {
                        if(checkState == Qt.Checked){
                            noiseSlider.value = 0;
                            noiseSlider.enabled = false;
                            noiseTimer.rand = true;
                        } else {
                            noiseSlider.value = 300;
                            noiseSlider.enabled = true;
                            noiseTimer.rand = false;
                        }
                    }
                }
            }

            Row{
                Label{
                    text: "Fuzziness Interval: "
                }
                Label{
                    text: fuzzySlider.enabled ? fuzzySlider.value + " ms" : "Random [1, 30] ms"
                }
            }

            Row{
                Slider{
                    id: fuzzySlider
                    width: noiseSettings.width-40-fuzzyRandBox.width
                    value: fuzzyTimer.interval
                    stepSize: 1
                    from: 1
                    to: 100

                    onMoved: {
                        saved.text = "Settings have been edited, but not saved";
                        saved.color = "#ff0000";
                    }
                }
                CheckBox{
                    id: fuzzyRandBox
                    text: "Rand."

                    onCheckStateChanged: {
                        if(checkState == Qt.Checked){
                            fuzzySlider.value = 0;
                            fuzzySlider.enabled = false;
                            fuzzyTimer.rand = true;
                        } else {
                            fuzzySlider.value = 50;
                            fuzzySlider.enabled = true;
                            fuzzyTimer.rand = false;
                        }
                    }
                }
            }

            Row{
                Label{
                    text: "Fuzziness Factor: "
                }
                Label{
                    text: fuzzyAmountSlider.enabled ? fuzzyAmountSlider.value + " px" : "Random  [1, 5] px"
                }
            }

            Row{
                Slider{
                    id: fuzzyAmountSlider
                    width: noiseSettings.width-40-fuzzyAmountRandBox.width
                    value: crt.fuzzinessAmount
                    stepSize: 1
                    from: 1
                    to: 10

                    onMoved: {
                        saved.text = "Settings have been edited, but not saved";
                        saved.color = "#ff0000";
                    }
                }
                CheckBox{
                    id: fuzzyAmountRandBox
                    text: "Rand."

                    onCheckStateChanged: {
                        if(checkState == Qt.Checked){
                            fuzzyAmountSlider.value = 0;
                            fuzzyAmountSlider.enabled = false;
                            fuzzyTimer.randAmount = true;
                        } else {
                            fuzzyAmountSlider.value = 50;
                            fuzzyAmountSlider.enabled = true;
                            fuzzyTimer.randAmount = false;
                        }
                    }
                }
            }

            Text {
                id: saved
                text: "Settings have been saved"
                color: "#00ff00"
            }

            Button{
                id: saveNoiseSettings
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Save Noise Settings"

                onPressed: {
                    noiseTimer.interval = noiseSlider.value;
                    fuzzyTimer.interval = fuzzySlider.value;
                    crt.fuzzinessAmount = fuzzyAmountSlider.value;
                    saved.text = "Settings have been saved"
                    saved.color = "#00ff00"
                }
            }
        }



    }

    Timer{
        id: noiseTimer
        interval: 300
        repeat: true;
        running: false

        property bool rand: false

        onTriggered: {
            if(rand){
                interval = Math.floor(Math.random()*490)+10;
            }

            if(crt.sendToSock == false && (crt.noiseType === 0 || crt.noiseType === 2)){
                crt.sendToSock = true;
            }
            else if(crt.sendToSock == true && (crt.noiseType === 0 || crt.noiseType === 2))
                crt.sendToSock = false;
        }
    }

    Timer{
        id: fuzzyTimer
        interval: 50
        repeat: true;
        running: false

        property bool rand: false
        property bool randAmount: false

        onTriggered: {
            if(rand){
                interval = Math.floor(Math.random()*29)+1;
            }
            if(randAmount){
                crt.fuzzinessAmount = Math.floor(Math.random()*4)+1;
            }

            if(crt.fuzzyOn == false && (crt.noiseType === 1 || crt.noiseType === 2)){
                var sign = Math.random() < 0.5 ? -1 : 1;
                crt.fuzziness = crt.fuzzinessAmount * sign;
                crt.fuzzyOn = true;
            } else if(crt.fuzzyOn == true && (crt.noiseType === 1 || crt.noiseType === 2)){
                crt.fuzzyOn = false;
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
