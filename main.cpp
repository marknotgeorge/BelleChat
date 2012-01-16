#include <QtGui/QApplication>
#include "qmlapplicationviewer.h"
#include "version.h"
#include "connectionsettings.h"
#include <QDeclarativeContext>
#include "sessionwrapper.h"
#include "channellistitem.h"
#include <QtDeclarative>


Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QmlApplicationViewer viewer;
    Session appSession;
    appSession.context = viewer.rootContext();

    qmlRegisterType<Version>("QMLIrc",1,0,"Version");
    qmlRegisterType<ConnectionSettings>("QMLIrc",1,0,"ConnectionSettings");


    QList<QObject *> channels;

    // Fill ChannelListItem with dummy data;
    //channels.append(new ChannelListItem("#Wibble", 23, "Wibble, Wibble, I'm a hatstand"));
    //channels.append(new ChannelListItem("#biggun", 12, "That's what she said"));
    //channels.append(new ChannelListItem("#Banana", 45, "The rain in spain falls mainly on the plain"));


    viewer.rootContext()->setContextProperty("Session", &appSession);
    viewer.rootContext()->setContextProperty("ChannelModel", QVariant::fromValue(channels));



    //QCoreApplication::setAttribute(Qt::AA_S60DisablePartialScreenInputMode, false);

    viewer.setMainQmlFile(QLatin1String("qml/QMLIrc/main.qml"));
    viewer.showExpanded();

    int returnValue = app.exec();

    qDebug() << returnValue;

    appSession.context = 0;

    return returnValue;
}
