#include "userlistitem.h"

UserListItem::UserListItem(QObject *parent) :
    QObject(parent)
{
}

void UserListItem::setName(QString newName)
{
    m_name = newName;
}

QString UserListItem::name()
{
    return m_name;
}

bool UserListItem::operator =(UserListItem other)
{
    return name() == other.name();
}

bool UserListItem::operator <(UserListItem other)
{
    return name() < other.name();
}
