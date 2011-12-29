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

public:
    explicit ConnectionSettings(QObject *parent = 0);
    
    Q_INVOKABLE QString host();
    Q_INVOKABLE int port();
    Q_INVOKABLE QString nickname();
    Q_INVOKABLE QString password();
    Q_INVOKABLE QString username();
    Q_INVOKABLE QString realname();
signals:
    void hostChanged(QString newHost);
    void portChanged(QString newPort);
    void nicknameChanged(QString newNickname);
    void passwordChanged(QString newPassword);
    void usernameChanged(QString newUsername);
    void realnameChanged(QString newRealname);
    
public slots:
    Q_INVOKABLE void setHost(QString newHost);
    Q_INVOKABLE void setPort(int newPort);
    Q_INVOKABLE void setPort(QString newPortString);
    Q_INVOKABLE void setNickname(QString newNickname);
    Q_INVOKABLE void setPassword(QString newPassword);
    Q_INVOKABLE void setUsername(QString newUsername);
    Q_INVOKABLE void setRealname(QString newRealname);

private:


};

#endif // CONNECTIONSETTINGS_H
