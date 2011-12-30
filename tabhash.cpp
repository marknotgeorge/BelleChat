#include "tabhash.h"
#include <QHash>
#include <QHashIterator>

TabHash::TabHash(QObject *parent) :
    QObject(parent), iterator(m_tabs)
{
}

void TabHash::insert(QString key, QObject *value)
{
    m_tabs.insert(key.toLower(), value);
}

QObject *TabHash::value(QString key)
{
    if (m_tabs.contains(key.toLower()))
    {
        return m_tabs.value(key.toLower());
    }
    else return 0;
}

int TabHash::count()
{
    return m_tabs.count();
}

int TabHash::remove(QString key)
{
    return m_tabs.remove(key);
}

void TabHash::initIterator()
{
    QHashIterator<QString,QObject *>iterator(m_tabs);
}

bool TabHash::iteratorHasNext()
{
    return iterator.hasNext();
}

void TabHash::iteratorNext()
{
    iterator.next();
}

QString TabHash::iteratorKey()
{
    return iterator.key();
}



