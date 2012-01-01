#include <QtGui/QApplication>
#include "qmlapplicationviewer.h"
#include "version.h"
#include "connectionsettings.h"
#include <QDeclarativeContext>
#include "sessionwrapper.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    Version appVersion;
    ConnectionSettings appConnectionSettings;
    Session appSession;

    QScopedPointer<QApplication> app(createApplication(argc, argv));
    QScopedPointer<QmlApplicationViewer> viewer(QmlApplicationViewer::create());

    QDeclarativeContext *context = viewer->rootContext();

    context->setContextProperty("Version", &appVersion);
    context->setContextProperty("Connection", &appConnectionSettings);
    context->setContextProperty("Session", &appSession);

    QCoreApplication::setAttribute(Qt::AA_S60DisablePartialScreenInputMode, false);

    viewer->setMainQmlFile(QLatin1String("qml/QMLIrc/main.qml"));
    viewer->showExpanded();

    int exitValue;

    exitValue = app->exec();
    qDebug() << "Exit value: " << exitValue;

    return exitValue;
}
