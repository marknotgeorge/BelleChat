#ifndef TABHASH_H
#define TABHASH_H

#include <QObject>
#include <QHash>
#include <QHashIterator>
#include <QDeclarativeItem>

class TabHash : public QObject
{
    Q_OBJECT
private:
    QHash<QString, QObject *> m_tabs;
    QHashIterator<QString, QObject *> iterator;


public:
    explicit TabHash(QObject *parent = 0);
    Q_INVOKABLE void insert(QString key, QObject *value);
    Q_INVOKABLE QObject *value(QString key);
    Q_INVOKABLE int count();
    Q_INVOKABLE int remove(QString key);
    Q_INVOKABLE void initIterator();
    Q_INVOKABLE bool iteratorHasNext();
    Q_INVOKABLE void iteratorNext();
    Q_INVOKABLE QString iteratorKey();




    
signals:
    
public slots:


    
};

#endif // TABHASH_H
