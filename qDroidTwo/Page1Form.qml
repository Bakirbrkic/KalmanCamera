import QtQuick 2.12
import QtQuick.Controls 2.5
import QtMultimedia 5.12
import QZXing 2.3


Page {
    id: page
    title: qsTr("Page 1")
    background: Rectangle{
        color: "red"
    }

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
    }

    VideoOutput {
        autoOrientation: true;
        id: viewfinder
        source: camera
        focus : visible // to receive focus and capture key events when visible
        anchors.fill: parent

        MouseArea {
            anchors.fill: parent;
            onClicked: {
                var res = camera.imageCapture.supportedResolutions;
                camera.imageCapture.resolution = res[Math.floor(res.length/4)];
                camera.imageCapture.capture();
            }
        }
    }

    Text{
        x: (page.width - width)/2
        text: "Tap on Screen to read the code..."
        font: {
            font.pointSize = 20
            font.bold = true

        }
        color: "#FFFFFF"
        y:page.height/2
    }

    BusyIndicator{
        id: loading
        visible: false
        anchors.fill: parent
    }

    Image {
        id: photoPreview
        fillMode: Image.PreserveAspectFit
        height: 100
        width: 100
    }

    QZXing{
        id: decoder
        enabledDecoders: QZXing.DecoderFormat_QR_CODE
        onDecodingStarted: {
            console.log("Decoding of image started...");
            loading.visible = true;
            loading.running = true;
        }
        onTagFound: {
            console.log("Barcode data: " + tag);
            page.title = tag;
        }
        onDecodingFinished: {
            console.log("Decoding finished " + (succeeded==true ? "successfully" :    "unsuccessfully") );
            loading.visible = false;
            loading.running = false;
        }
    }
}
