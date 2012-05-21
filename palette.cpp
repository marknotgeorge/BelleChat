#include "palette.h"
#include <QSettings>

Palette::Palette(QObject *parent) :
    QObject(parent)
{

}

QString Palette::motd()
{
    QSettings settings;

    return settings.value("PaletteMOTD", "lightgrey").toString();
}

QString Palette::info()
{
    QSettings settings;
    return settings.value("PaletteINFO", "white").toString();
}

QString Palette::serverReply()
{
    QSettings settings;
    return settings.value("PaletteServerReply", "lightgreen").toString();
}

QString Palette::userColour()
{
    QSettings settings;
    return settings.value("PaletteUserColour", "red").toString();
}

QString Palette::kickColour()
{
    QSettings settings;
    return settings.value("PaletteKickColour", "red").toString();
}

QString Palette::action()
{
    QSettings settings;
    return settings.value("PaletteAction", "violet").toString();
}

QString Palette::quitColour()
{
    QSettings settings;
    return settings.value("PaletteQuitColour", "royalblue").toString();
}

QString Palette::nickColour()
{
    QSettings settings;
    return settings.value("PaletteNickColour", "yellow").toString();
}

QString Palette::timestampColour()
{
    QSettings settings;
    return settings.value("PaletteTimestampColour", "grey").toString();
}

QString Palette::ctcpReplyColour()
{
    QSettings settings;
    return settings.value("PaletteCtcpReplyColour", "orange").toString();
}

void Palette::setMotd(QString newMotd)
{
    QSettings settings;
    settings.setValue("PaletteMOTD", newMotd);
    emit motdChanged(newMotd);
}

void Palette::setInfo(QString newInfo)
{
    QSettings settings;
    settings.setValue("PaletteINFO", newInfo);
    emit infoChanged(newInfo);
}

void Palette::setServerReply(QString newServerReply)
{
    QSettings settings;
    settings.setValue("PaletteServerReply", newServerReply);
    emit serverReplyChanged(newServerReply);
}

void Palette::setUserColour(QString newUserColour)
{
    QSettings settings;
    settings.setValue("PaletteUserColour", newUserColour);
    emit userColourChanged(newUserColour);
}

void Palette::setKickColour(QString newKickColour)
{
    QSettings settings;
    settings.setValue("PaletteKickColour", newKickColour);
    emit kickColourChanged(newKickColour);
}

void Palette::setAction(QString newAction)
{
    QSettings settings;
    settings.setValue("PaletteAction", newAction);
    emit actionChanged(newAction);
}

void Palette::setQuitColour(QString newQuitColour)
{
    QSettings settings;
    settings.setValue("PaletteQuitColour", newQuitColour);
    emit quitColourChanged(newQuitColour);
}

void Palette::setNickColour(QString newNickColour)
{
    QSettings settings;
    settings.setValue("PaletteNickColour", newNickColour);
    emit nickColourChanged(newNickColour);
}

void Palette::setTimestampColour(QString newTimestampColour)
{
    QSettings settings;
    settings.setValue("PaletteTimestampColour", newTimestampColour);
    emit timestampColourChanged(newTimestampColour);
}

void Palette::setCtcpReplyColour(QString newCtcpReplyColour)
{
    QSettings settings;
    settings.setValue("PaletteCtcpReplyColour", newCtcpReplyColour);
    emit ctcpReplyColourChanged(newCtcpReplyColour);
}


