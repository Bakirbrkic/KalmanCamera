import QtQuick 2.12
import QtQuick.Controls 2.5
import QtWebSockets 1.1

Page {
    id: recPage
    title: qsTr("Page 2")

    property bool clientConnected: false
    property WebSocket wsClient: null

    // Connections to the client
    Connections {
        target: (wsRoot.wsClient) ? wsRoot.wsClient : null
        onStatusChanged: {
            // Note: always use the 'status' property, not the argument from the signal.
            Logger.syslog(LogLevel.INFO, "Server: Client status : " + wsRoot.wsClient.status);
            if (wsRoot.wsClient.status === WebSocket.Error) {
                wsRoot.appendMessage("Server: Client error:" + wsRoot.wsClient.errorString);
            } else if (wsRoot.wsClient.status === WebSocket.Closing) {
                wsRoot.appendMessage("Server: Client socket closing.");
            } else if (wsRoot.wsClient.status === WebSocket.Closed) {
                wsRoot.appendMessage("Server: Client socket closed.");
                Logger.syslog(LogLevel.INFO, "Server: Client socket closed! ");
                wsRoot.clientConnected = false;
                if(wsRoot.wsClient) wsRoot.wsClient = null;
            }
        }
        onTextMessageReceived: {
            wsRoot.appendMessage("Server received message: " + message);
            wsRoot.wsClient.sendTextMessage("Server Echo: " + message);
        }
        onActiveChanged: {
            wsRoot.appendMessage("Server: Client connection active: " + wsRoot.wsClient.active);
        }
    }


    WebSocketServer {
        id: server
        port:12350
        host: configuration.getParameter("Network.IpAddress").value
        listen: true
        secure: false // set true for secure connection
        onClientConnected: {
            Logger.syslog(LogLevel.INFO, "WS Client connected!")
            wsRoot.appendMessage("Server: Client status: " +  webSocket.status)
            if(webSocket.peerAddress !== configuration.getParameter("Dvms.PeerDevice.IpAddress").value) {
                wsRoot.appendMessage("Server: Unknown Client connected, closing connection " +  webSocket.peerAddress);
                Logger.syslog(LogLevel.INFO, "Server: Unknown Client connected, closing connection " + webSocket.peerAddress);

                // Disconnect
                webSocket.url = "";
            }
            else if (wsRoot.clientConnected) {
                wsRoot.appendMessage("Server: Second client connected, closing connection " +  webSocket.peerAddress);
                Logger.syslog(LogLevel.INFO, "Server: Second Client connected, closing connection " + webSocket.peerAddress);
                // Disconnect
                webSocket.url = "";
            }
            else {
                wsRoot.appendMessage("Server: Client connected, accept connection " +  webSocket.peerAddress);
                Logger.syslog(LogLevel.INFO,"Server: Client connected, accept connection " +  webSocket.peerAddress)

                wsRoot.clientConnected = true;
                wsRoot.wsClient = webSocket;
            }
        }

        onErrorStringChanged: {
            wsRoot.appendMessage("Server error: "+ errorString);
        }
        Component.onCompleted: {
            wsRoot.appendMessage("Server URL: " + url);
            // activate the client connection
            clientSocket.url = url;
        }
    }
}
