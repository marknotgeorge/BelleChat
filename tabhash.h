#ifndef TABHASH_H
#define TABHASH_H

#include <QObject>
#include <QHash>
#include <QDeclarativeItem>

class TabHash : public QObject
{
    Q_OBJECT
public:
    explicit TabHash(QObject *parent = 0);
    Q_INVOKABLE void insert(QString key, QObject *value);
    Q_INVOKABLE QObject *value(QString key);

    
signals:
    
public slots:

private:
    QHash<QString, QObject *> m_tabs;
    
};

#endif // TABHASH_H
