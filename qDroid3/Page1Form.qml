import QtQuick 2.12
import QtQuick.Controls 2.5
import QtMultimedia 5.12
import QZXing 2.3


Page {
    signal tagDecoded(string tag)
    property string tagContent: "value"

    id: page

    title: qsTr("Capture")

    Camera {
        id: camera

        imageCapture {
            onImageCaptured: {
                // Show the preview in an Image
                photoPreview.source = preview
            }
            onImageSaved: {
                console.log("saved to: " + path);
                decoder.decodeImageQML(path);
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
                camera.imageCapture.resolution = res[Math.floor(res.length/4)];
                //camera.imageCapture.capture();
                console.log("Resolution is: " + camera.imageCapture.resolution);
            }
            else
                console.log("CS: " + camera.cameraStatus);
        }
    }

    Grid {
        id: grid
        anchors.fill: parent
        spacing: 2
        rows: 3
        columns: 1


        VideoOutput {
            autoOrientation: true;
            id: viewfinder
            source: camera
            focus : visible // to receive focus and capture key events when visible
            anchors.fill: parent

            MouseArea {
                anchors.fill: parent;

                onPressed: {
                    camera.imageCapture.capture();
                }

            }
        }

        Text{
            id: infoTxt
            text: "Tap on Screen to read the code..."
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font: {
                font.pointSize = 20
                font.bold = true

            }
            color: "#FFFFFF"
        }

        Image {
            id: photoPreview
            fillMode: Image.PreserveAspectFit
            height: 100
            width: 100
        }

        BusyIndicator{
            id: loading
            width: 74
            height: 76
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            visible: false
        }
    }

    Timer{
        id: infoTxtTimer
        interval: 1500
        repeat: false

        onTriggered:{
            infoTxt.text = "Tap on Screen to read the code...";
        }
    }

    QZXing{
        id: decoder
        enabledDecoders: QZXing.DecoderFormat_QR_CODE | QZXing.DecoderFormat_CODE_128 | QZXing.DecoderFormat_UPC_EAN_EXTENSION | QZXing.DecoderFormat_UPC_A | QZXing.DecoderFormat_UPC_E | QZXing.DecoderFormat_EAN_13 | QZXing.DecoderFormat_EAN_8 | QZXing.DecoderFormat_CODABAR | QZXing.DecoderFormat_CODE_39 | QZXing.DecoderFormat_CODE_93 | QZXing.DecoderFormat_ITF
        onDecodingStarted: {
            console.log("Decoding of image started...");
            loading.visible = true;
            loading.running = true;
        }
        onTagFound: {
            console.log("Barcode data: " + tag);
            tagContent = tag;
        }
        onDecodingFinished: {
            console.log("Decoding finished " + (succeeded==true ? "successfully" :    "unsuccessfully") );
            loading.visible = false;
            loading.running = false;
            if(!succeeded){
                infoTxt.text = "Didn't found a code,\nplease try again...";
                infoTxtTimer.restart();
            } else
                tagDecoded(tagContent);
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}D{i:2;anchors_height:400;anchors_width:400}
}
##^##*/
