#ifndef DEVICEIP_H
#define DEVICEIP_H

#include <QObject>
#include <QtNetwork>

class deviceIp : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString localIP READ localIP)
public:
    explicit deviceIp(QObject *parent = nullptr);
    QString localIP();

signals:

};

#endif // DEVICEIP_H
