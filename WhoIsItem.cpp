#include "whoisitem.h"

WhoIsItem::WhoIsItem(QObject *parent) :
    QObject(parent)
{
    m_dataComplete = false;
}

void WhoIsItem::setName(QString newName)
{
    m_name = newName;
}

QString WhoIsItem::name()
{
    return m_name;
}

void WhoIsItem::setUser(QString newUser)
{
    m_user = newUser;
}

QString WhoIsItem::user()
{
    return m_user;
}

void WhoIsItem::setServer(QString newServer)
{
    m_server = newServer;
}

QString WhoIsItem::server()
{
    return m_server;
}

void WhoIsItem::setRealname(QString newRealname)
{
    m_realname = newRealname;
}

QString WhoIsItem::realname()
{
    return m_realname;
}

bool WhoIsItem::dataComplete()
{
    return m_dataComplete;
}

void WhoIsItem::setDataComplete(bool newComplete)
{
    m_dataComplete = newComplete;
}

QString WhoIsItem::channels()
{
    return m_channels.join(" ");
}

void WhoIsItem::setChannels(QString newChannels)
{
    QStringList newChannelsList = newChannels.split(" ", QString::SkipEmptyParts);

    foreach(QString channel, newChannelsList)
    {
        // Check to see if channel is already there before adding...
        if (!m_channels.contains(channel))
            m_channels.append(channel);
    }
}

QDateTime WhoIsItem::onlineSince()
{
    return m_onlineSince;
}

void WhoIsItem::setOnlineSince(QDateTime newOnlineSince)
{
    m_onlineSince = newOnlineSince;
}

bool WhoIsItem::operator =(WhoIsItem other)
{
    return name() == other.name();
}

bool WhoIsItem::operator <(WhoIsItem other)
{
    return name() < other.name();
}
