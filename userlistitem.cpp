#include "userlistitem.h"

UserListItem::UserListItem(QObject *parent) :
    QObject(parent)
{
    m_dataComplete = false;
}

void UserListItem::setName(QString newName)
{
    m_name = newName;
}

QString UserListItem::name()
{
    return m_name;
}

void UserListItem::setUser(QString newUser)
{
    m_user = newUser;
}

QString UserListItem::user()
{
    return m_user;
}

void UserListItem::setServer(QString newServer)
{
    m_server = newServer;
}

QString UserListItem::server()
{
    return m_server;
}

void UserListItem::setRealname(QString newRealname)
{
    m_realname = newRealname;
}

QString UserListItem::realname()
{
    return m_realname;
}

bool UserListItem::dataComplete()
{
    return m_dataComplete;
}

void UserListItem::setDataComplete(bool newComplete)
{
    m_dataComplete = newComplete;
}

QString UserListItem::channels()
{
    return m_channels.join(" ");
}

void UserListItem::setChannels(QString newChannels)
{
    QStringList newChannelsList = newChannels.split(" ", QString::SkipEmptyParts);

    foreach(QString channel, newChannelsList)
    {
        // Check to see if channel is already there before adding...
        if (!m_channels.contains(channel))
            m_channels.append(channel);
    }
}

QDateTime UserListItem::onlineSince()
{
    return m_onlineSince;
}

void UserListItem::setOnlineSince(QDateTime newOnlineSince)
{
    m_onlineSince = newOnlineSince;
}

bool UserListItem::operator =(UserListItem other)
{
    return name() == other.name();
}

bool UserListItem::operator <(UserListItem other)
{
    return name() < other.name();
}
