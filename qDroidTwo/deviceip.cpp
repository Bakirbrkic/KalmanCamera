#include "deviceip.h"

deviceIp::deviceIp(QObject *parent) : QObject(parent)
{

}

QString deviceIp::localIP(){
    const QHostAddress &localhost = QHostAddress(QHostAddress::LocalHost);
    for (const QHostAddress &address: QNetworkInterface::allAddresses()) {
        if (address.protocol() == QAbstractSocket::IPv4Protocol && address != localhost){
            qDebug() << address.toString();
            return address.toString().toStdString().c_str();
        }
    }
    return "Not found";
}
