#include "ocvcameraframe.h"

#include <QBuffer>

ocvCameraFrame::ocvCameraFrame(QObject *parent) : QObject(parent)
{

}

QString ocvCameraFrame::capture()
{
    cv::Mat frame;

    cv::VideoCapture vid(0);

    if (vid.read(frame)) {
        imshow("WebCam", frame);
        return "Captured";
    }

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

    return imgIn;
}
