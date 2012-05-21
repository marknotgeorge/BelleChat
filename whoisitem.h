#ifndef WHOISITEM_H
#define WHOISITEM_H

#include <QObject>
#include <QStringList>
#include <QDateTime>

class WhoIsItem : public QObject
{
    Q_OBJECT
public:
    explicit WhoIsItem(QObject *parent = 0);

    Q_PROPERTY(QString name READ name WRITE setName NOTIFY whoIsItemChanged)
    Q_PROPERTY(QString user READ user WRITE setUser NOTIFY whoIsItemChanged)
    Q_PROPERTY(QString server READ server WRITE setServer NOTIFY whoIsItemChanged)
    Q_PROPERTY(QString realname READ realname WRITE setRealname NOTIFY whoIsItemChanged)
    Q_PROPERTY(bool dataComplete READ dataComplete WRITE setDataComplete NOTIFY whoIsItemChanged)
    Q_PROPERTY(QString channels READ channels WRITE setChannels NOTIFY whoIsItemChanged)
    Q_PROPERTY(QDateTime onlineSince READ onlineSince WRITE setOnlineSince NOTIFY whoIsItemChanged)
    Q_PROPERTY(QString clientVersion READ clientVersion WRITE setClientVersion NOTIFY whoIsItemChanged)
    Q_PROPERTY(QString userInfo READ userInfo WRITE setUserInfo NOTIFY whoIsItemChanged)

    void setName(QString newName);
    QString name();
    void setUser(QString newUser);
    QString user();
    void setServer(QString newServer);
    QString server();
    void setRealname(QString newRealname);
    QString realname();
    bool dataComplete();
    void setDataComplete(bool newComplete);
    QString channels();
    void setChannels(QString newChannels);
    QDateTime onlineSince();
    void setOnlineSince(QDateTime newOnlineSince);
    QString clientVersion();
    void setClientVersion(QString newClientVersion);
    QString userInfo();
    void setUserInfo(QString newUserInfo);

    bool operator =(WhoIsItem other);
    bool operator <(WhoIsItem other);

    
signals:
    void whoIsItemChanged();
    
public slots:

private:
    QString m_name;
    QString m_user;
    QString m_server;
    QString m_realname;
    bool m_dataComplete;
    QStringList m_channels; // Stored as a list so it's easier to filter duplicates
    QDateTime m_onlineSince;
    QString m_clientVersion;
    QString m_userInfo;
};

#endif // WhoIsItem_H
