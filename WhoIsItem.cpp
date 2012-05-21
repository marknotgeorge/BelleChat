#include "whoisitem.h"

WhoIsItem::WhoIsItem(QObject *parent) :
    QObject(parent)
{
    m_dataComplete = false;
}

void WhoIsItem::setName(QString newName)
{
    m_name = newName;
    emit whoIsItemChanged();
}

QString WhoIsItem::name()
{
    return m_name;
}

void WhoIsItem::setUser(QString newUser)
{
    m_user = newUser;
    emit whoIsItemChanged();
}

QString WhoIsItem::user()
{
    return m_user;
}

void WhoIsItem::setServer(QString newServer)
{
    m_server = newServer;
    emit whoIsItemChanged();
}

QString WhoIsItem::server()
{
    return m_server;
}

void WhoIsItem::setRealname(QString newRealname)
{
    m_realname = newRealname;
    whoIsItemChanged();
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
    emit whoIsItemChanged();
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
    emit whoIsItemChanged();
}

QDateTime WhoIsItem::onlineSince()
{
    return m_onlineSince;
}

void WhoIsItem::setOnlineSince(QDateTime newOnlineSince)
{
    m_onlineSince = newOnlineSince;
    emit whoIsItemChanged();
}

QString WhoIsItem::clientVersion()
{
    return m_clientVersion;
}

void WhoIsItem::setClientVersion(QString newClientVersion)
{
    m_clientVersion = newClientVersion;
    emit whoIsItemChanged();
}

QString WhoIsItem::userInfo()
{
    return m_userInfo;
}

void WhoIsItem::setUserInfo(QString newUserInfo)
{
    m_userInfo = newUserInfo;
    emit whoIsItemChanged();
}


bool WhoIsItem::operator =(WhoIsItem other)
{
    return name() == other.name();
}

bool WhoIsItem::operator <(WhoIsItem other)
{
    return name() < other.name();
}
