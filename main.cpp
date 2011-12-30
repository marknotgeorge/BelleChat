#include <QtGui/QApplication>
#include "qmlapplicationviewer.h"
#include "version.h"
#include "connectionsettings.h"
#include <QDeclarativeContext>
#include "sessionwrapper.h"
#include "tabhash.h"
#include <QHash>
#include <QHashIterator>


Q_DECL_EXPORT int main(int argc, char *argv[])
{
    Version appVersion;
    ConnectionSettings appConnectionSettings;
    Session appSession;
    TabHash appTabHash;



    QScopedPointer<QApplication> app(createApplication(argc, argv));
    QScopedPointer<QmlApplicationViewer> viewer(QmlApplicationViewer::create());

    QDeclarativeContext *context = viewer->rootContext();

    context->setContextProperty("Version", &appVersion);
    context->setContextProperty("Connection", &appConnectionSettings);
    context->setContextProperty("Session", &appSession);
    context->setContextProperty("TabHash", &appTabHash);


    QCoreApplication::setAttribute(Qt::AA_S60DisablePartialScreenInputMode, false);

    viewer->setMainQmlFile(QLatin1String("qml/QMLIrc/main.qml"));
    viewer->showExpanded();

    return app->exec();
}
