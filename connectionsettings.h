#ifndef CONNECTIONSETTINGS_H
#define CONNECTIONSETTINGS_H

#include <QObject>
#include <QSettings>

class ConnectionSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY (QString host READ host WRITE setHost NOTIFY hostChanged)
    Q_PROPERTY (int port READ port WRITE setPort NOTIFY portChanged)
    Q_PROPERTY (QString nickname READ nickname WRITE setNickname NOTIFY nicknameChanged)
    Q_PROPERTY (QString password READ password WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY (QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY (QString realname READ realname WRITE setRealname NOTIFY realnameChanged)
    Q_PROPERTY (bool showTimestamp READ showTimestamp WRITE setShowTimestamp NOTIFY showTimestampChanged)
    Q_PROPERTY (bool autoFetchWhois READ autoFetchWhois WRITE setAutoFetchWhois NOTIFY autoFetchWhoisChanged)
    Q_PROPERTY (int textColour READ textColour WRITE setTextColour NOTIFY textColourChanged)
    Q_PROPERTY (int backgroundColour READ backgroundColour WRITE setBackgroundColour NOTIFY backgroundColourChanged)



public:
    explicit ConnectionSettings(QObject *parent = 0);
    
    Q_INVOKABLE QString host();
    Q_INVOKABLE int port();
    Q_INVOKABLE QString nickname();
    Q_INVOKABLE QString password();
    Q_INVOKABLE QString username();
    Q_INVOKABLE QString realname();
    Q_INVOKABLE bool showTimestamp();
    Q_INVOKABLE bool autoFetchWhois();
    Q_INVOKABLE int textColour();
    Q_INVOKABLE int backgroundColour();


signals:
    void hostChanged(QString newHost);
    void portChanged(QString newPort);
    void nicknameChanged(QString newNickname);
    void passwordChanged(QString newPassword);
    void usernameChanged(QString newUsername);
    void realnameChanged(QString newRealname);
    void showTimestampChanged(bool newShowTimestamp);
    void autoFetchWhoisChanged(bool newAutoFetchWhois);
    void textColourChanged(int newTextColour);
    void backgroundColourChanged(int newBackgroundColour);
    
public slots:
    Q_INVOKABLE void setHost(QString newHost);
    Q_INVOKABLE void setPort(int newPort);
    Q_INVOKABLE void setPort(QString newPortString);
    Q_INVOKABLE void setNickname(QString newNickname);
    Q_INVOKABLE void setPassword(QString newPassword);
    Q_INVOKABLE void setUsername(QString newUsername);
    Q_INVOKABLE void setRealname(QString newRealname);
    Q_INVOKABLE void setShowTimestamp(bool newShowTimestamp);
    Q_INVOKABLE void setAutoFetchWhois(bool newAutoFetchWhois);
    Q_INVOKABLE void setTextColour(int newTextColour);
    Q_INVOKABLE void setBackgroundColour(int newBackgroundColour);

private:


};

#endif // CONNECTIONSETTINGS_H
