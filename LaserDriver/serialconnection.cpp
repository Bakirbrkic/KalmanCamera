#include "serialconnection.h"

SerialConnection::SerialConnection(QObject *parent) : QObject(parent)
{

}

QString SerialConnection::getAllPortsJSON()
{
    SerialConnection::serialList = QSerialPortInfo::availablePorts();
    SerialConnection::numOfPorts = serialList.size();

    QString json = "{\"numOfPorts\":" + QString::number(numOfPorts) + ", \"portNames\":[";
    for (int i = 0; i < SerialConnection::numOfPorts; i++) {
        json += "\"" + serialList.at(i).portName() + "\"";
        if(i<SerialConnection::numOfPorts-1)
            json += ",";
    }
    json +="]}";

    return json;
}

QString SerialConnection::getPortName()
{
    if(SerialConnection::portName != NULL && SerialConnection::portName != "")
        return SerialConnection::portName;
    return "no port selected";
}

int SerialConnection::getBaudRate()
{
    return SerialConnection::baudRate;
}

QString SerialConnection::readLastMessage()
{
    if(serial.bytesAvailable()>0||serial.waitForReadyRead(10)){
        SerialConnection::ba=serial.readAll();
        //qDebug()<<ba;
    }
    //serial.close();
    if(SerialConnection::receivedMsg == ba)
        return "";
    SerialConnection::receivedMsg = ba;
    return SerialConnection::receivedMsg;
}

int SerialConnection::sendNewMessage(QString msg)
{
    const char* ms = msg.toStdString().c_str();
    serial.write(ms, msg.length());
    serial.write("\n");
    qDebug()<<"to send"<<msg.toStdString().c_str();
    return 1;
}

void SerialConnection::setPortName(QString pn)
{
    for (int i = 0; i < SerialConnection::numOfPorts; i++) {
        if(serialList.at(i).portName() == pn){
            SerialConnection::portName = pn;
            SerialConnection::portNumber = i;
            return;
        }
    }
}

void SerialConnection::setBaudRate(int baud)
{
    if(baud == 9600){
        SerialConnection::baudRate = baud;
        SerialConnection::serial.setBaudRate(QSerialPort::Baud9600);
    } else if(baud == 115200){
        SerialConnection::baudRate = baud;
        SerialConnection::serial.setBaudRate(QSerialPort::Baud115200);
    }
    serial.setStopBits(QSerialPort::OneStop);
    serial.setDataBits(QSerialPort::Data8);
}

int SerialConnection::begin()
{
    SerialConnection::ba = "";
    SerialConnection::receivedMsg = "";
    SerialConnection::setBaudRate(baudRate);

    serial.setPort(serialList.at(portNumber));
    serial.open(QIODevice::ReadWrite);
    return 1;
}
