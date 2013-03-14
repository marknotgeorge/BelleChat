#include "databasemanager.h"
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlRecord>
#include "proxysqltablemodel.h"
#include "sqlquerymodel.h"
#include "connectionsettings.h"
#include <QDebug>
#include <QVariant>

DatabaseManager::DatabaseManager(QObject *parent) :
    QObject(parent)
{
}

bool DatabaseManager::openDB()
{
    // Find QSLite driver
    db = QSqlDatabase::addDatabase("QSQLITE");

    db.setDatabaseName("BelleChatDB.sqlite");

    // Open databasee
    return db.open();
}

QSqlError DatabaseManager::lastError()
{
    return db.lastError();
}

bool DatabaseManager::createTables()
{
    bool retValue = false;
    if (db.isOpen())
    {
        QSqlQuery query;
        retValue = query.exec("create table if not exists Servers"
                              "(id integer primary key autoincrement not null,"
                              "name text,"
                              "url text,"
                              "port integer,"
                              "password text,"
                              "username text,"
                              "realname text,"
                              "nickname text,"
                              "encoding text,"
                              "secure boolean,"
                              "autojoin boolean,"
                              "autoJoinChannels text,"
                              "sendNsPassword boolean,"
                              "nsPWisServerPW boolean,"
                              "nsPassword text); ");
    }
    return retValue;
}

int DatabaseManager::refreshServersModel()
{
    QString serversQuery = "SELECT * FROM Servers;";
    SqlQueryModel* serverModel = new SqlQueryModel();
    serverModel->setQuery(serversQuery);

    qDebug() << "Server Model Refeshed. No of Rows: "
             << serverModel->rowCount();

    context->setContextProperty("serversModel", serverModel);

    return serverModel->rowCount();
}


// Put the information  from the original QSettings into the database
void DatabaseManager::initialiseServers()
{
    ConnectionSettings settings;
    bool retValue = false;
    int newId = -1;

    if (db.isOpen())
    {
        int numRows = refreshServersModel();
        qDebug() << "Initial number of rows:" << numRows;
        if (!numRows)
        {
            QSqlQuery query;
            query.prepare("INSERT INTO Servers "
                          "(id, name, url, port, password, username, "
                          "realname, nickname, encoding, secure, "
                          "autojoin, autojoinchannels, sendNSPassword, "
                          "nsPWisServerPW, nsPassword)"
                          "VALUES (NULL, :name, :url, :port, :password, "
                          ":username, :realname, :nickname, NULL, "
                          ":secure, :autojoin, :autojoinchannels, "
                          ":sendNSPassword, :nsPWisServerPW, :nsPassword);");
            query.bindValue(":name", settings.host());
            query.bindValue(":url", settings.host());
            query.bindValue(":port", settings.port());
            query.bindValue(":password", settings.password());
            query.bindValue(":username", settings.username());
            query.bindValue(":realname", settings.realname());
            query.bindValue(":nickname", settings.nickname());
            query.bindValue(":secure", settings.secure());
            query.bindValue(":autojoin", settings.autoJoinChannels());
            query.bindValue(":autojoinchannels", settings.autoJoinChanList());
            query.bindValue(":sendNSPassword", settings.sendNsPassword());
            query.bindValue(":nsPWisServerPW", settings.nsPWIsServerPW());
            query.bindValue(":nsPassword", settings.nsPassword());

            retValue = query.exec();


            qDebug() << "retValue: " << retValue;

            // Get database autoincrement value...
            if (retValue)
            {
                newId = query.lastInsertId().toInt();
                qDebug() << "Initialise id: " << newId;
            }
            else
                qDebug() << lastError();
        }
    }
}

bool DatabaseManager::dropTables()
{
    QString dropString = "DROP TABLE IF EXISTS Servers;";
    bool ret = false;
    if (db.isOpen())
    {
        QSqlQuery query;
        ret = query.exec(dropString);
    }
    if (ret)
        qDebug() << "Table dropped";
    else
        qDebug() << lastError();

    return ret;
}
