#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlError>
#include <QDeclarativeContext>

class DatabaseManager : public QObject
{
    Q_OBJECT
public:
    explicit DatabaseManager(QObject *parent = 0);

    bool openDB();
    QSqlError lastError();
    bool createTables();
    int refreshServersModel();
    void initialiseServers();
    Q_INVOKABLE bool dropTables();

    // Needed to send the servers model to the QNL UI.
    QDeclarativeContext* context;


    
signals:
    
public slots:

private:
    QSqlDatabase db;
    
};

#endif // DATABASEMANAGER_H
