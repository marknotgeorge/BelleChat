#include <QtGui/QApplication>
#include "qmlapplicationviewer.h"

#include "connectionsettings.h"
#include <QDeclarativeContext>
#include "sessionwrapper.h"
#include "channellistitem.h"
#include "userlistitem.h"
#include <QtDeclarative>


Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QmlApplicationViewer viewer;
    Session appSession;
    appSession.context = viewer.rootContext();
    QString appVersion = BUILD;


    qmlRegisterType<ConnectionSettings>("BelleChat",1,0,"ConnectionSettings");
    QList<QObject *> channels;
    QList<QObject *> users;

    viewer.rootContext()->setContextProperty("Version", appVersion);
    viewer.rootContext()->setContextProperty("Session", &appSession);
    viewer.rootContext()->setContextProperty("ChannelModel", QVariant::fromValue(channels));
    viewer.rootContext()->setContextProperty("UserModel", QVariant::fromValue(users));




    //QCoreApplication::setAttribute(Qt::AA_S60DisablePartialScreenInputMode, false);

    viewer.setMainQmlFile(QLatin1String("qml/BelleChat/main.qml"));
    viewer.showExpanded();

    int returnValue = app.exec();

    //qDebug() << returnValue;

    appSession.context = 0;

    return returnValue;
}
