#include <QtGui/QApplication>
#include "qmlapplicationviewer.h"

#include "connectionsettings.h"
#include <QDeclarativeContext>
#include "sessionwrapper.h"
#include "channellistitem.h"
#include "whoisitem.h"
#include "databasemanager.h"

#include <QtDeclarative>


Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QmlApplicationViewer viewer;
    Session appSession;
    appSession.context = viewer.rootContext();
    QString appVersion = VERSIONNO;
    QString appBuild = BUILD;

    //Creating the database...
    DatabaseManager database;
    bool databaseSuccess = false;
    databaseSuccess = database.openDB();
    if (databaseSuccess)
    {
        database.createTables();
        database.context = viewer.rootContext();
        database.refreshServersModel();
        database.initialiseServers();
    }


    qmlRegisterType<ConnectionSettings>("BelleChat",1,0,"ConnectionSettings");
    qmlRegisterType<WhoIsItem>("BelleChat",1,0,"WhoIsItem");
    QList<QObject *> channels;
    QStringList users;


    viewer.rootContext()->setContextProperty("Version", appVersion.remove('\"'));
    viewer.rootContext()->setContextProperty("Build", appBuild.remove('\"'));
    viewer.rootContext()->setContextProperty("Session", &appSession);
    viewer.rootContext()->setContextProperty("Database", &database);
    viewer.rootContext()->setContextProperty("ChannelModel", QVariant::fromValue(channels));
    viewer.rootContext()->setContextProperty("UserModel", QVariant::fromValue(users));




    //QCoreApplication::setAttribute(Qt::AA_S60DisablePartialScreenInputMode, false);

    viewer.setMainQmlFile(QLatin1String("qml/BelleChat/main.qml"));
    viewer.showExpanded();

    return app.exec();

}
