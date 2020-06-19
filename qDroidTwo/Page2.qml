import QtQuick 2.12
import QtQuick.Controls 2.5
import QtWebSockets 1.1
import ba.bamzar.deviceIp 1.0

Page {
    id: recPage
    title: qsTr("Page 2")

    Rectangle{
        id: wsRoot
        height: 0

        property bool clientConnected: false
        property WebSocket wsClient: null

        DeviceIp{
            id: ip
        }

        // Connections to the client
        Connections {
            target: (wsRoot.wsClient) ? wsRoot.wsClient : null
            onStatusChanged: {
                // Note: always use the 'status' property, not the argument from the signal.
                console.log("Server: Client status : " + wsRoot.wsClient.status);
                if (wsRoot.wsClient.status === WebSocket.Error) {
                    console.log("Server: Client error:" + wsRoot.wsClient.errorString);
                } else if (wsRoot.wsClient.status === WebSocket.Closing) {
                    console.log("Server: Client socket closing.");
                } else if (wsRoot.wsClient.status === WebSocket.Closed) {
                    console.log("Server: Client socket closed.");
                    wsRoot.clientConnected = false;
                    if(wsRoot.wsClient) wsRoot.wsClient = null;
                }
            }
            onTextMessageReceived: {
                console.log("Server received message: " + message);
                wsRoot.wsClient.sendTextMessage("Server Echo: " + message);
                var s = JSON.parse(message);
                if(s.start){
                    crt.lastX = s.x;
                    crt.lastY = s.y;
                    crt.oldX = s.x;
                    crt.oldY = s.y;
                    crt.requestPaint();
                } else{
                    crt.lastX = s.x;
                    crt.lastY = s.y;
                    crt.requestPaint();
                }
            }
            onActiveChanged: {
                console.log("Server: Client connection active: " + wsRoot.wsClient.active);
            }
        }

        WebSocketServer {
            id: server
            port:12350
            host: ip.localIP//"10.0.1.142"//configuration.getParameter("Network.IpAddress").value
            listen: true
            onClientConnected: {
                console.log("WS Client connected!")
                console.log("Server: Client status: " +  webSocket.status)

                console.log("Server: Client connected, accept connection " +  webSocket.peerAddress);
                console.log("Server: Client connected, accept connection " +  webSocket.peerAddress);


                wsRoot.clientConnected = true;
                wsRoot.wsClient = webSocket;

            }

            onErrorStringChanged: {
                console.log("Server error: "+ errorString);
            }

            onHostChanged: {
                recPage.title = ip.localIP;
                console.log("my ip is:" + ip.localIP);
            }

        }
    }

    Canvas{
        id: crt
        anchors.fill: parent

        property int lastX: 0
        property int lastY: 0
        property int oldX: 0
        property int oldY: 0

        function clear(){
            var ctx = getContext("2d");
            ctx.reset();
            crt.requestPaint();
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.lineWidth = 5;
            ctx.beginPath();
            ctx.moveTo(oldX, oldY);

            ctx.lineTo(lastX, lastY);
            ctx.stroke();

            oldX = lastX;
            oldY = lastY;
        }
    }
}
