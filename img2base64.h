#ifndef IMG2BASE64_H
#define IMG2BASE64_H

#include <QObject>
#include <QQuickItem>

#include <QImage>
#include <QtXml/QtXml>

class img2base64 : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString encode2base64 READ getEncoded WRITE encode NOTIFY encoded)
private:
    QString base64result;

public:
    explicit img2base64(QObject *parent = nullptr);

    void encode(QString path);

    QString getEncoded();

signals:
    void encoded(QString);
};

#endif // IMG2BASE64_H
