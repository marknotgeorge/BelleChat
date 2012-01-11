#include <QtGui/QApplication>
#include "qmlapplicationviewer.h"
#include "version.h"
#include "connectionsettings.h"
#include <QDeclarativeContext>
#include "sessionwrapper.h"
#include "channellistitem.h"


Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));
    QScopedPointer<QmlApplicationViewer> viewer(QmlApplicationViewer::create());
    QDeclarativeContext *context = viewer->rootContext();



    Version *appVersion = new Version(context);
    ConnectionSettings *appConnectionSettings = new ConnectionSettings(context);
    Session *appSession = new Session(context);
    appSession->context = context;

    QList<QObject *> channels;

    // Fill ChannelListItem with dummy data;
    //channels.append(new ChannelListItem("#Wibble", 23, "Wibble, Wibble, I'm a hatstand"));
    //channels.append(new ChannelListItem("#biggun", 12, "That's what she said"));
    //channels.append(new ChannelListItem("#Banana", 45, "The rain in spain falls mainly on the plain"));

    context->setContextProperty("Version", appVersion);
    context->setContextProperty("Connection", appConnectionSettings);
    context->setContextProperty("Session", appSession);
    context->setContextProperty("ChannelModel", QVariant::fromValue(channels));



    QCoreApplication::setAttribute(Qt::AA_S60DisablePartialScreenInputMode, false);

    viewer->setMainQmlFile(QLatin1String("qml/QMLIrc/main.qml"));
    viewer->showExpanded();

    return app->exec();

    appVersion->deleteLater();
    appConnectionSettings->deleteLater();
    appSession->deleteLater();

}
