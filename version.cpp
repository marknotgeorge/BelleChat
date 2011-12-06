#include "version.h"

Version::Version(QObject *parent) :
    QObject(parent)
{
    m_version = BUILD;
}

QString Version::version()
{
    return m_version;
}
