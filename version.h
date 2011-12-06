#ifndef VERSION_H
#define VERSION_H

#include <QObject>

class Version : public QObject
{
    Q_OBJECT
public:
    explicit Version(QObject *parent = 0);

    Q_INVOKABLE QString version();

private:
    QString m_version;



};

#endif // VERSION_H
