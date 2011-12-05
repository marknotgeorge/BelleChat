#include <QtGui/QApplication>
#include "qmlapplicationviewer.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));
    QScopedPointer<QmlApplicationViewer> viewer(QmlApplicationViewer::create());

    QCoreApplication::setAttribute(Qt::AA_S60DisablePartialScreenInputMode, false);

    viewer->setMainQmlFile(QLatin1String("qml/QMLIrc/main.qml"));
    viewer->showExpanded();

    return app->exec();
}
