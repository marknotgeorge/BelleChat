#include "connectionsettings.h"
#include <QSettings>
#include <QCoreApplication>
#include <QDebug>

ConnectionSettings::ConnectionSettings(QObject *parent) :
    QObject(parent)
{
    QCoreApplication::setOrganizationName("marknotgeorge");
    QCoreApplication::setApplicationName("QMLIrc");
}

QString ConnectionSettings::host()
{
    QSettings settings;
    return settings.value("host", "irc.server.com").toString();
}

int ConnectionSettings::port()
{
    QSettings settings;
    return settings.value("port", "6667").toInt();
}

QString ConnectionSettings::nickname()
{
    QSettings settings;
    return settings.value("nickname", "nickname").toString();
}

QString ConnectionSettings::password()
{
    QSettings settings;
    return settings.value("password").toString();
}

QString ConnectionSettings::username()
{
    QSettings settings;
    return settings.value("username","username").toString();
}

QString ConnectionSettings::realname()
{
    QSettings settings;
    return settings.value("realname", "Dante Hicks").toString();
}

bool ConnectionSettings::showTimestamp()
{
    QSettings settings;
    return settings.value("showTimestamp", "false").toBool();
}

bool ConnectionSettings::autoFetchWhois()
{
    QSettings settings;
    return settings.value("autoFetchWhois", "false").toBool();
}

int ConnectionSettings::textColour()
{
    QSettings settings;
    return settings.value("textColour", "0").toInt();
}

int ConnectionSettings::backgroundColour()
{
    QSettings settings;
    return settings.value("backgroundColour", "1").toInt();
}

bool ConnectionSettings::textBold()
{
    QSettings settings;
    return settings.value("textBold", "false").toBool();
}

bool ConnectionSettings::textItalic()
{
    QSettings settings;
    return settings.value("textItalic", "false").toBool();
}

bool ConnectionSettings::textUnderline()
{
    QSettings settings;
    return settings.value("textUnderline", "false").toBool();
}

bool ConnectionSettings::formatText()
{
    QSettings settings;
    return settings.value("formatText", "false").toBool();
}

bool ConnectionSettings::showChannelList()
{
    QSettings settings;
    return settings.value("showChannelList", "true").toBool();
}

void ConnectionSettings::setHost(QString newHost)
{
    QSettings settings;
    settings.setValue("host", newHost);
    emit hostChanged(newHost);
}

void ConnectionSettings::setPort(int newPort)
{
    QSettings settings;
    settings.setValue("port", newPort);
    emit portChanged(QString::number(newPort));
}

void ConnectionSettings::setPort(QString newPortString)
{
    QSettings settings;
    settings.setValue("port", newPortString);
    emit portChanged(newPortString);
}

void ConnectionSettings::setNickname(QString newNickname)
{
    QSettings settings;
    settings.setValue("nickname", newNickname);
    emit nicknameChanged(newNickname);
}

void ConnectionSettings::setPassword(QString newPassword)
{
    QSettings settings;
    settings.setValue("password", newPassword);
    emit passwordChanged(newPassword);
}

void ConnectionSettings::setUsername(QString newUsername)
{
    QSettings settings;
    settings.setValue("username", newUsername);
    emit usernameChanged(newUsername);
}

void ConnectionSettings::setRealname(QString newRealname)
{
    QSettings settings;
    // qDebug() << "Setting value to " << newRealname;
    settings.setValue("realname", newRealname);
    emit realnameChanged(newRealname);
}

void ConnectionSettings::setShowTimestamp(bool newShowTimestamp)
{
    QSettings settings;
    settings.setValue("showTimestamp", newShowTimestamp);
    emit showTimestampChanged(newShowTimestamp);
}

void ConnectionSettings::setAutoFetchWhois(bool newAutoFetchWhois)
{
    QSettings settings;
    settings.setValue("autoFetchWhois", newAutoFetchWhois);
    emit autoFetchWhoisChanged(newAutoFetchWhois);
}

void ConnectionSettings::setTextColour(int newTextColour)
{
    QSettings settings;
    settings.setValue("textColour", newTextColour);
    emit textColourChanged(newTextColour);
}

void ConnectionSettings::setBackgroundColour(int newBackgroundColour)
{
    QSettings settings;
    settings.setValue("backgroundColour", newBackgroundColour);
    emit backgroundColourChanged(newBackgroundColour);
}

void ConnectionSettings::setTextItalic(bool newTextItalic)
{
    QSettings settings;
    settings.setValue("textItalic", newTextItalic);
    emit textBoldChanged(newTextItalic);
}

void ConnectionSettings::setTextBold(bool newTextBold)
{
    QSettings settings;
    settings.setValue("textBold", newTextBold);
    emit textBoldChanged(newTextBold);
}


void ConnectionSettings::setTextUnderline(bool newTextUnderline)
{
    QSettings settings;
    settings.setValue("textUnderline", newTextUnderline);
    emit textBoldChanged(newTextUnderline);
}

void ConnectionSettings::setFormatText(bool newFormatText)
{
    QSettings settings;
    settings.setValue("formatText", newFormatText);
    emit formatTextChanged(newFormatText);
}

void ConnectionSettings::setShowChannelList(bool newShowChannelList)
{
    QSettings settings;
    settings.setValue("showChannelList", newShowChannelList);
    emit showChannelListChanged(newShowChannelList);
}



