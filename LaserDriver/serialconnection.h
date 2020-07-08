#ifndef SERIALCONNECTION_H
#define SERIALCONNECTION_H

#include <QObject>

#include <QSerialPort>
#include <QSerialPortInfo>
#include <QDebug>
#include <QTextStream>

class SerialConnection : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString AllPortsJSON READ getAllPortsJSON)
    Q_PROPERTY(QString portName READ getPortName WRITE setPortName)
    Q_PROPERTY(int baudRate READ getBaudRate WRITE setBaudRate)
    Q_PROPERTY(QString lastMessage READ readLastMessage)
    Q_PROPERTY(int beginSerial READ begin)
    Q_PROPERTY(QString newMessage READ readLastMessage WRITE sendNewMessage)

public:
    explicit SerialConnection(QObject *parent = nullptr);

    //getters
    QString getAllPortsJSON();
    QString getPortName();
    int getBaudRate();

    //setters
    void setPortName(QString pn);
    void setBaudRate(int baud);

    //aux methods
    int begin();
    QString readLastMessage();
    int sendNewMessage(QString msg);

private:
    QSerialPort serial;
    QList<QSerialPortInfo> serialList;
    QByteArray ba;
    QString receivedMsg;
    QString portName;
    int numOfPorts;
    int baudRate = 9600;
    int portNumber;

signals:

};

#endif // SERIALCONNECTION_H

/*
    QSerialPort serial;
    QList<QSerialPortInfo> serialList = QSerialPortInfo::availablePorts();
    int numOfPorts = serialList.size();
    qDebug() << numOfPorts;
    for (int i = 0; i < numOfPorts; i++) {
        qDebug() << i << ". " << serialList.at(i).portName();
    }

    qDebug()<<"Select port (by inputing number next to the option): ";
    in = cin.readLine();
    while(in.toInt() < 0 || in.toInt() > numOfPorts){
        qDebug()<<"Not valid";
        qDebug()<<"Select port (by inputing number next to the option): ";
        in = cin.readLine();
    }
    qDebug()<< in << ". port selected: " << serialList.at(in.toInt()).portName();

    serial.setPort(serialList.at(in.toInt()));
    serial.setBaudRate(QSerialPort::Baud9600);
    serial.open(QIODevice::ReadWrite);
    while(in != "exit"){
        if(serial.bytesAvailable()>0||serial.waitForReadyRead(10)){
            QByteArray ba;
            ba=serial.readAll();
            serial.write(ba);
            qDebug()<<ba;
        }
    }

*/
