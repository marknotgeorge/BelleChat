#ifndef USERLISTITEM_H
#define USERLISTITEM_H

#include <QObject>

class UserListItem : public QObject
{
    Q_OBJECT
public:
    explicit UserListItem(QObject *parent = 0);

    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)

    void setName(QString newName);
    QString name();

    bool operator =(UserListItem other);
    bool operator <(UserListItem other);

    
signals:
    void nameChanged();
    
public slots:

private:
    QString m_name;
    
};

#endif // USERLISTITEM_H
