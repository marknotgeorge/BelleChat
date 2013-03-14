# Add more folders to ship with the application, here
folder_01.source = qml/BelleChat
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

symbian:TARGET = BelleChat

# Additional import path used to resolve QML modules in Creator's code model
# This needs to be the path to where Communi is installed
QML_IMPORT_PATH = ../communi/imports/Communi

# UIDs. Use this one when compiling self-signed...
#symbian:TARGET.UID3 = 0xE2F428B1
# Use this one when compuling using the developer cert/key pair...
symbian:TARGET.UID3 = 0x2006280c
symbian:ICON = BelleChat.svg

symbian {
     # DEPLOYMENT.installer_header=0xA000D7CE

      vendorinfo = "%{\"marknotgeorge-EN\"}" ":\"marknotgeorge\""

      my_deployment.pkg_prerules = vendorinfo

    my_deployment.pkg_prerules += \
        "; Dependency to Symbian Qt Quick components" \
        "(0x200346DE), 1, 1, 0, {\"Qt Quick components\"}"



      DEPLOYMENT += my_deployment
  }



DEFINES += COMMUNI_STATIC

QT += core gui network sql

# Smart Installer package's UID
# This UID is from the protected range and therefore the package will
# fail to install if self-signed. By default qmake uses the unprotected
# range value if unprotected UID is defined for the application and
# 0x2002CCCF value if protected UID is given to the application
# symbian:DEPLOYMENT.installer_header = 0xA000D7CE

# Allow network access on Symbian
symbian:TARGET.CAPABILITY += NetworkServices

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
CONFIG += mobility
MOBILITY += systeminfo

# Speed up launching on MeeGo/Harmattan when using applauncherd daemon
# CONFIG += qdeclarative-boostable

# Add dependency to Symbian components
CONFIG += qt-components communi
# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    connectionsettings.cpp \
    sessionwrapper.cpp \
    channellistitem.cpp \
    whoisitem.cpp \
    palette.cpp \
    sleeper.cpp \
    databasemanager.cpp \
    proxysqltablemodel.cpp \
    sqlquerymodel.cpp

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

# Create a macro from the Git describe command, to use in about boxes.
BUILDSTR = '\\"$$system(git describe)\\"'
DEFINES += BUILD=\"$${BUILDSTR}\"

# Create the version number from the git describe
VERSION = $$system(git describe --abbrev=0)
VERSIONSTR = '\\"$$system(git describe --abbrev=0)\\"'
DEFINES += VERSIONNO=\"$${VERSIONSTR}\"

HEADERS += \
    connectionsettings.h \
    sessionwrapper.h \
    channellistitem.h \
    whoisitem.h \
    palette.h \
    sleeper.h \
    databasemanager.h \
    proxysqltablemodel.h \
    sqlquerymodel.h

OTHER_FILES += \
    ReadMe.txt \
    HelpText.js

INCLUDEPATH += $$PWD/../communi/include
DEPENDPATH += $$PWD/../communi/include

win32:CONFIG(release, debug|release): LIBS += -L$$PWD/../communi/lib/ -lCommuni
else:win32:CONFIG(debug, debug|release): LIBS += -L$$PWD/../communi/lib/ -lCommunid
else:symbian: LIBS += -lCommuni

symbian {
    # Copied from QTCREATORBUG-5589
    # Required for S^3 SDK, else linking fails
    ## Needs to be after other libraries
    LIBS += -lusrt2_2.lib
}

