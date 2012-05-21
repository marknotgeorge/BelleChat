#ifndef PALETTE_H
#define PALETTE_H

#include <QObject>
#include <QSettings>

class Palette : public QObject
{
    Q_OBJECT
    Q_PROPERTY (QString motd READ motd WRITE setMotd NOTIFY motdChanged)
    Q_PROPERTY (QString info READ info WRITE setInfo NOTIFY infoChanged)
    Q_PROPERTY (QString serverReply READ serverReply WRITE setServerReply NOTIFY serverReplyChanged)
    Q_PROPERTY (QString userColour READ userColour WRITE setUserColour NOTIFY userColourChanged)
    Q_PROPERTY (QString kickColour READ kickColour WRITE setKickColour NOTIFY kickColourChanged)
    Q_PROPERTY (QString action READ action WRITE setAction NOTIFY actionChanged)
    Q_PROPERTY (QString quitColour READ quitColour WRITE setQuitColour NOTIFY quitColourChanged)
    Q_PROPERTY (QString nickColour READ nickColour WRITE setNickColour NOTIFY nickColourChanged)
    Q_PROPERTY (QString timestampColour READ timestampColour WRITE setTimestampColour NOTIFY timestampColourChanged)
    Q_PROPERTY (QString ctcpReplyColour READ ctcpReplyColour WRITE setCtcpReplyColour NOTIFY ctcpReplyColourChanged)


public:
    explicit Palette(QObject *parent = 0);

signals:
    void motdChanged(QString newMotd);
    void infoChanged(QString newInfo);
    void serverReplyChanged(QString newServerReply);
    void userColourChanged(QString newUserColour);
    void actionChanged(QString newAction);
    void kickColourChanged(QString newKickColour);
    void quitColourChanged(QString newQuitColour);
    void nickColourChanged(QString newNickColour);
    void timestampColourChanged(QString newTimestampColourChanged);
    void ctcpReplyColourChanged(QString newCtcpReply);

public slots:
    QString motd();
    QString info();
    QString serverReply();
    QString userColour();
    QString kickColour();
    QString action();
    QString quitColour();
    QString nickColour();
    QString timestampColour();
    QString ctcpReplyColour();

    void setMotd(QString newMotd);
    void setInfo(QString newInfo);
    void setServerReply(QString newServerReply);
    void setUserColour(QString newUserColour);
    void setKickColour(QString newKickColour);
    void setAction(QString newAction);
    void setQuitColour(QString newQuitColour);
    void setNickColour(QString newNickColour);
    void setTimestampColour(QString newTimestampColour);
    void setCtcpReplyColour(QString newCtcpReplyColour);

private:

};

#endif // PALETTE_H
