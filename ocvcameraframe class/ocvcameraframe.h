#ifndef OCVCAMERAFRAME_H
#define OCVCAMERAFRAME_H

#include "opencv2/imgcodecs.hpp"
#include "opencv2/highgui.hpp"

#include <QImage>
#include <echoclient.h>
#include <QObject>

class ocvCameraFrame : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString capture READ capture)
    Q_PROPERTY(QImage captureImage READ captureImg)

public:
    QUrl sockUrl;
    EchoClient *client;

    explicit ocvCameraFrame(QObject *parent = nullptr);

    QString capture();
    QImage captureImg();

signals:

};

#endif // OCVCAMERAFRAME_H
