#include "channellistitem.h"

ChannelListItem::ChannelListItem(QObject *parent) :
    QObject(parent)
{    

}

ChannelListItem::ChannelListItem(QString newChannel, int newUsers, QString newTopic)
{
    m_channel = newChannel;
    m_users = newUsers;
    m_topic = newTopic;
}

QString ChannelListItem::channel()
{
    return m_channel;
}

void ChannelListItem::setChannel(QString newChannel)
{
    m_channel = newChannel;
}

int ChannelListItem::users()
{
    return m_users;
}

void ChannelListItem::setUsers(int newUsers)
{
    m_users = newUsers;
}

QString ChannelListItem::topic()
{
    return m_topic;
}

void ChannelListItem::setTopic(QString newTopic)
{
    m_topic = newTopic;
}



