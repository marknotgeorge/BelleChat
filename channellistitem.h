#ifndef CHANNELLISTITEM_H
#define CHANNELLISTITEM_H

#include <QObject>

class ChannelListItem : public QObject
{
    Q_OBJECT
public:
    explicit ChannelListItem(QObject *parent = 0);
    explicit ChannelListItem(QString newChannel, int newUsers, QString newTopic);

    Q_PROPERTY(QString channel READ channel WRITE setChannel NOTIFY channelChanged)
    Q_PROPERTY(int users READ users WRITE setUsers NOTIFY usersChanged)
    Q_PROPERTY(QString topic READ topic WRITE setTopic NOTIFY topicChanged)

    QString channel();
    void setChannel(QString newChannel);
    int users();
    void setUsers(int newUsers);
    QString topic();
    void setTopic(QString newTopic);
    
signals:
    void channelChanged();
    void usersChanged();
    void topicChanged();
public slots:

private:
    QString m_channel;
    int m_users;
    QString m_topic;
    
};

#endif // CHANNELLISTITEM_H
