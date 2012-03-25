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

    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString user READ user WRITE setUser NOTIFY userChanged)
    Q_PROPERTY(QString server READ server WRITE setServer NOTIFY serverChanged)
    Q_PROPERTY(QString realname READ realname WRITE setRealname NOTIFY realnameChanged)
    Q_PROPERTY(bool dataComplete READ dataComplete WRITE setDataComplete NOTIFY dataCompleteChanged)
    Q_PROPERTY(QString channels READ channels WRITE setChannels NOTIFY channelsChanged)
    Q_PROPERTY(QDateTime onlineSince READ onlineSince WRITE setOnlineSince NOTIFY onlineSinceChanged)

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

    bool operator =(WhoIsItem other);
    bool operator <(WhoIsItem other);

    
signals:
    void nameChanged();
    void userChanged();
    void serverChanged();
    void realnameChanged();
    void dataCompleteChanged();
    void channelsChanged();
    void onlineSinceChanged();
    
public slots:

private:
    QString m_name;
    QString m_user;
    QString m_server;
    QString m_realname;
    bool m_dataComplete;
    QStringList m_channels; // Stored as a list so it's easier to filter duplicates
    QDateTime m_onlineSince;

    
};

#endif // WhoIsItem_H
