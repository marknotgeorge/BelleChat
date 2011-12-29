#include "tabhash.h"
#include <QHash>

TabHash::TabHash(QObject *parent) :
    QObject(parent)
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

