# Add more folders to ship with the application, here
folder_01.source = qml/QMLIrc
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

symbian:TARGET.UID3 = 0xE2F428B1
symbian:ICON = QMLIrc.svg

DEFINES += COMMUNI_STATIC

# Smart Installer package's UID
# This UID is from the protected range and therefore the package will
# fail to install if self-signed. By default qmake uses the unprotected
# range value if unprotected UID is defined for the application and
# 0x2002CCCF value if protected UID is given to the application
#symbian:DEPLOYMENT.installer_header = 0x2002CCCF

QT += core gui network

# Allow network access on Symbian
symbian:TARGET.CAPABILITY += NetworkServices

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
# CONFIG += mobility
# MOBILITY +=

# Speed up launching on MeeGo/Harmattan when using applauncherd daemon
# CONFIG += qdeclarative-boostable

# Add dependency to Symbian components
CONFIG += qt-components communi
# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    version.cpp \
    connectionsettings.cpp \
    sessionwrapper.cpp

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

RESOURCES +=

OTHER_FILES += \
    TabArray.js \
    qml/QMLIrc/OutputFlickable.qml


# Create a macro from the Git describe command, to use in about boxes.
BUILDSTR = '\\"$$system(git describe)\\"'
DEFINES += BUILD=\"$${BUILDSTR}\"

HEADERS += \
    version.h \
    connectionsettings.h \
    sessionwrapper.h

symbian {
    # Copied from QTCREATORBUG-5589
    # Required for S^3 SDK, else linking fails
    LIBS += -lusrt2_2.lib
}

win32:CONFIG(release, debug|release): LIBS += -L$$PWD/../communi/lib/ -lCommuni
else:win32:CONFIG(debug, debug|release): LIBS += -L$$PWD/../communi/lib/ -lCommunid
else:symbian: LIBS += -lCommuni

INCLUDEPATH += $$PWD/../communi/include
DEPENDPATH += $$PWD/../communi/include

win32:CONFIG(release, debug|release): PRE_TARGETDEPS += $$PWD/../communi/lib/Communi.lib
else:win32:CONFIG(debug, debug|release): PRE_TARGETDEPS += $$PWD/../communi/lib/Communid.lib
