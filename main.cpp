#include <QtGui/QApplication>
#include "qmlapplicationviewer.h"
#include "version.h"
#include <QDeclarativeContext>

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    Version appVersion;

    QScopedPointer<QApplication> app(createApplication(argc, argv));
    QScopedPointer<QmlApplicationViewer> viewer(QmlApplicationViewer::create());

    QDeclarativeContext *context = viewer->rootContext();

    context->setContextProperty("Version", &appVersion);

    QCoreApplication::setAttribute(Qt::AA_S60DisablePartialScreenInputMode, false);

    viewer->setMainQmlFile(QLatin1String("qml/QMLIrc/main.qml"));
    viewer->showExpanded();

    return app->exec();
}
