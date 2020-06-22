#include "ocvcameraframe.h"

#include <QBuffer>

ocvCameraFrame::ocvCameraFrame(QObject *parent) : QObject(parent)
{
    sockUrl = "ws://172.20.10.3:1234";
    //sockUrl = "ws://demos.kaazing.com/echo";
    client = new EchoClient(sockUrl);
}

QString ocvCameraFrame::capture()
{
    cv::Mat frame;

    cv::VideoCapture vid(0);

    if (vid.read(frame)) {
        imshow("WebCam", frame);
        return "Captured";
    }

    client->sendTMsg(*new QString("Captured"));

    return "Capture failed";

}

QImage ocvCameraFrame::captureImg()
{


    cv::Mat frame;
    cv::VideoCapture vid(0);

    QImage imgIn;

    if (vid.read(frame)) {
        imshow("WebCam", frame);
        QImage imgIn = QImage((uchar*) frame.data, frame.cols, frame.rows, frame.step, QImage::Format_RGB888);
    }

    //client->sendTMsg(*new QString("Captured"));
    QByteArray arr = QByteArray::fromRawData((const char*)imgIn.bits(), imgIn.sizeInBytes());
    client->sendBMsg(arr);
    return imgIn;
}
