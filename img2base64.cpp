#include "img2base64.h"


img2base64::img2base64(QObject *parent) : QObject(parent)
{

}

void img2base64::encode(QString path)
{
    QFile fileImg(path); // == camera.imageCapture.capturedImagePath
    fileImg.open(QIODevice::ReadOnly);
    QByteArray imageData = fileImg.readAll();
    QByteArray imageData_Base64 = imageData.toBase64();
    //xmlWriter.writeAttribute("data:image/jpg;base64",imageData_Base64);
    base64result = QString(imageData_Base64);
    base64result.prepend("data:image/jpg;base64,");

    emit encoded(base64result);
}

QString img2base64::getEncoded()
{
    return base64result;
}
