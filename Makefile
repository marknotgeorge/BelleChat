#############################################################################
# Makefile for building: BelleChat
# Generated by qmake (2.01a) (Qt 4.7.4) on: Sun 8. Apr 10:53:43 2012
# Project:  Bellechat.pro
# Template: app
# Command: c:\qtsdk\symbian\sdks\symbian3qt474\bin\qmake.exe -spec ..\..\QtSDK\Symbian\SDKs\Symbian3Qt474\mkspecs\symbian-sbsv2 CONFIG+=release -after  OBJECTS_DIR=obj MOC_DIR=moc UI_DIR=ui RCC_DIR=rcc OBJECTS_DIR=obj MOC_DIR=moc UI_DIR=ui RCC_DIR=rcc OBJECTS_DIR=obj MOC_DIR=moc UI_DIR=ui RCC_DIR=rcc -o bld.inf Bellechat.pro
#############################################################################

MAKEFILE          = Makefile
QMAKE             = c:\qtsdk\symbian\sdks\symbian3qt474\bin\qmake.exe
DEL_FILE          = del /q 2> NUL
DEL_DIR           = rmdir
CHK_DIR_EXISTS    = if not exist
MKDIR             = mkdir
MOVE              = move
DEBUG_PLATFORMS   = winscw gcce armv5 armv6
RELEASE_PLATFORMS = gcce armv5 armv6
MAKE              = make
SBS               = sbs

DEFINES	 = -DSYMBIAN -DUNICODE -DQT_KEYPAD_NAVIGATION -DQT_SOFTKEYS_ENABLED -DQT_USE_MATH_H_FLOATS -DCOMMUNI_STATIC -DBUILD="\"0.9.4-1-g7084eec\"" -DVERSIONNO="\"0.9.4\"" -DCOMMUNI_STATIC -DQ_COMPONENTS_SYMBIAN -DQT_NO_DEBUG -DQT_DECLARATIVE_LIB -DQT_GUI_LIB -DQT_NETWORK_LIB -DQT_CORE_LIB
INCPATH	 =  -I"C:/QtSDK/Symbian/SDKs/Symbian3Qt474/include/QtCore"  -I"C:/QtSDK/Symbian/SDKs/Symbian3Qt474/include/QtNetwork"  -I"C:/QtSDK/Symbian/SDKs/Symbian3Qt474/include/QtGui"  -I"C:/QtSDK/Symbian/SDKs/Symbian3Qt474/include/QtDeclarative"  -I"C:/QtSDK/Symbian/SDKs/Symbian3Qt474/include"  -I"C:/QtSDK/Symbian/SDKs/Symbian3Qt474/include/Communi"  -I"C:/QtSDK/Symbian/SDKs/Symbian3Qt474/mkspecs/common/symbian"  -I"C:/QtSDK/Symbian/SDKs/Symbian3Qt474/epoc32/include"  -I"C:/QtSDK/Symbian/SDKs/Symbian3Qt474/epoc32/include/stdapis"  -I"C:/QtSDK/Symbian/SDKs/Symbian3Qt474/epoc32/include/stdapis/sys"  -I"C:/QtProjects/BelleChat/qmlapplicationviewer"  -I"C:/QtProjects/communi/include"  -I"C:/QtSDK/Symbian/SDKs/Symbian3Qt474/epoc32/include/stdapis/stlportv5"  -I"C:/QtSDK/Symbian/SDKs/Symbian3Qt474/epoc32/include/mw"  -I"C:/QtSDK/Symbian/SDKs/Symbian3Qt474/epoc32/include/platform/mw"  -I"C:/QtSDK/Symbian/SDKs/Symbian3Qt474/epoc32/include/platform"  -I"C:/QtSDK/Symbian/SDKs/Symbian3Qt474/epoc32/include/platform/loc"  -I"C:/QtSDK/Symbian/SDKs/Symbian3Qt474/epoc32/include/platform/mw/loc"  -I"C:/QtSDK/Symbian/SDKs/Symbian3Qt474/epoc32/include/platform/loc/sc"  -I"C:/QtSDK/Symbian/SDKs/Symbian3Qt474/epoc32/include/platform/mw/loc/sc"  -I"C:/QtProjects/BelleChat/moc"  -I"C:/QtProjects/BelleChat"  -I"C:/QtProjects/BelleChat/ui" 
first: default

all: debug release

default: debug-winscw
qmake:
	$(QMAKE) "C:/QtProjects/BelleChat/Bellechat.pro"  -spec ..\..\QtSDK\Symbian\SDKs\Symbian3Qt474\mkspecs\symbian-sbsv2 CONFIG+=release -after  OBJECTS_DIR=obj MOC_DIR=moc UI_DIR=ui RCC_DIR=rcc OBJECTS_DIR=obj MOC_DIR=moc UI_DIR=ui RCC_DIR=rcc OBJECTS_DIR=obj MOC_DIR=moc UI_DIR=ui RCC_DIR=rcc

bld.inf: C:/QtProjects/BelleChat/Bellechat.pro
	$(QMAKE) "C:/QtProjects/BelleChat/Bellechat.pro"  -spec ..\..\QtSDK\Symbian\SDKs\Symbian3Qt474\mkspecs\symbian-sbsv2 CONFIG+=release -after  OBJECTS_DIR=obj MOC_DIR=moc UI_DIR=ui RCC_DIR=rcc OBJECTS_DIR=obj MOC_DIR=moc UI_DIR=ui RCC_DIR=rcc OBJECTS_DIR=obj MOC_DIR=moc UI_DIR=ui RCC_DIR=rcc

c:\QtProjects\BelleChat\BelleChat.loc: 
	$(QMAKE) "C:/QtProjects/BelleChat/Bellechat.pro"  -spec ..\..\QtSDK\Symbian\SDKs\Symbian3Qt474\mkspecs\symbian-sbsv2 CONFIG+=release -after  OBJECTS_DIR=obj MOC_DIR=moc UI_DIR=ui RCC_DIR=rcc OBJECTS_DIR=obj MOC_DIR=moc UI_DIR=ui RCC_DIR=rcc OBJECTS_DIR=obj MOC_DIR=moc UI_DIR=ui RCC_DIR=rcc

debug: c:\QtProjects\BelleChat\BelleChat.loc bld.inf
	$(SBS) -c winscw_udeb.mwccinc -c arm.v5.udeb.gcce4_4_1 -c arm.v6.udeb.gcce4_4_1
clean-debug: bld.inf
	$(SBS) reallyclean --toolcheck=off -c winscw_udeb.mwccinc -c arm.v5.udeb.gcce4_4_1 -c arm.v6.udeb.gcce4_4_1
freeze-debug: bld.inf
	$(SBS) freeze -c winscw_udeb.mwccinc -c arm.v5.udeb.gcce4_4_1 -c arm.v6.udeb.gcce4_4_1
release: c:\QtProjects\BelleChat\BelleChat.loc bld.inf
	$(SBS) -c arm.v5.urel.gcce4_4_1 -c arm.v6.urel.gcce4_4_1
clean-release: bld.inf
	$(SBS) reallyclean --toolcheck=off -c arm.v5.urel.gcce4_4_1 -c arm.v6.urel.gcce4_4_1
freeze-release: bld.inf
	$(SBS) freeze -c arm.v5.urel.gcce4_4_1 -c arm.v6.urel.gcce4_4_1

debug-winscw: c:\QtProjects\BelleChat\BelleChat.loc bld.inf
	$(SBS) -c winscw_udeb.mwccinc
clean-debug-winscw: bld.inf
	$(SBS) reallyclean -c winscw_udeb.mwccinc
freeze-debug-winscw: bld.inf
	$(SBS) freeze -c winscw_udeb.mwccinc
debug-gcce: c:\QtProjects\BelleChat\BelleChat.loc bld.inf
	$(SBS) -c arm.v5.udeb.gcce4_4_1
clean-debug-gcce: bld.inf
	$(SBS) reallyclean -c arm.v5.udeb.gcce4_4_1
freeze-debug-gcce: bld.inf
	$(SBS) freeze -c arm.v5.udeb.gcce4_4_1
debug-armv5: c:\QtProjects\BelleChat\BelleChat.loc bld.inf
	$(SBS) -c armv5_udeb
clean-debug-armv5: bld.inf
	$(SBS) reallyclean -c armv5_udeb
freeze-debug-armv5: bld.inf
	$(SBS) freeze -c armv5_udeb
debug-armv6: c:\QtProjects\BelleChat\BelleChat.loc bld.inf
	$(SBS) -c armv6_udeb
clean-debug-armv6: bld.inf
	$(SBS) reallyclean -c armv6_udeb
freeze-debug-armv6: bld.inf
	$(SBS) freeze -c armv6_udeb
release-gcce: c:\QtProjects\BelleChat\BelleChat.loc bld.inf
	$(SBS) -c arm.v5.urel.gcce4_4_1
clean-release-gcce: bld.inf
	$(SBS) reallyclean -c arm.v5.urel.gcce4_4_1
freeze-release-gcce: bld.inf
	$(SBS) freeze -c arm.v5.urel.gcce4_4_1
release-armv5: c:\QtProjects\BelleChat\BelleChat.loc bld.inf
	$(SBS) -c armv5_urel
clean-release-armv5: bld.inf
	$(SBS) reallyclean -c armv5_urel
freeze-release-armv5: bld.inf
	$(SBS) freeze -c armv5_urel
release-armv6: c:\QtProjects\BelleChat\BelleChat.loc bld.inf
	$(SBS) -c armv6_urel
clean-release-armv6: bld.inf
	$(SBS) reallyclean -c armv6_urel
freeze-release-armv6: bld.inf
	$(SBS) freeze -c armv6_urel
debug-armv5-gcce4.4.1: c:\QtProjects\BelleChat\BelleChat.loc bld.inf
	$(SBS) -c arm.v5.udeb.gcce4_4_1
clean-debug-armv5-gcce4.4.1: bld.inf
	$(SBS) reallyclean -c arm.v5.udeb.gcce4_4_1
freeze-debug-armv5-gcce4.4.1: bld.inf
	$(SBS) freeze -c arm.v5.udeb.gcce4_4_1
release-armv5-gcce4.4.1: c:\QtProjects\BelleChat\BelleChat.loc bld.inf
	$(SBS) -c arm.v5.urel.gcce4_4_1
clean-release-armv5-gcce4.4.1: bld.inf
	$(SBS) reallyclean -c arm.v5.urel.gcce4_4_1
freeze-release-armv5-gcce4.4.1: bld.inf
	$(SBS) freeze -c arm.v5.urel.gcce4_4_1
debug-armv6-gcce4.4.1: c:\QtProjects\BelleChat\BelleChat.loc bld.inf
	$(SBS) -c arm.v6.udeb.gcce4_4_1
clean-debug-armv6-gcce4.4.1: bld.inf
	$(SBS) reallyclean -c arm.v6.udeb.gcce4_4_1
freeze-debug-armv6-gcce4.4.1: bld.inf
	$(SBS) freeze -c arm.v6.udeb.gcce4_4_1
release-armv6-gcce4.4.1: c:\QtProjects\BelleChat\BelleChat.loc bld.inf
	$(SBS) -c arm.v6.urel.gcce4_4_1
clean-release-armv6-gcce4.4.1: bld.inf
	$(SBS) reallyclean -c arm.v6.urel.gcce4_4_1
freeze-release-armv6-gcce4.4.1: bld.inf
	$(SBS) freeze -c arm.v6.urel.gcce4_4_1

export: bld.inf
	$(SBS) export -c winscw_udeb.mwccinc -c arm.v5.udeb.gcce4_4_1 -c arm.v6.udeb.gcce4_4_1 -c arm.v5.urel.gcce4_4_1 -c arm.v6.urel.gcce4_4_1

cleanexport: bld.inf
	$(SBS) cleanexport -c winscw_udeb.mwccinc -c arm.v5.udeb.gcce4_4_1 -c arm.v6.udeb.gcce4_4_1 -c arm.v5.urel.gcce4_4_1 -c arm.v6.urel.gcce4_4_1

freeze: freeze-release

check: first

run:
	call C:/QtSDK/Symbian/SDKs/Symbian3Qt474/epoc32/release/winscw/udeb/BelleChat.exe $(QT_RUN_OPTIONS)

runonphone: sis
	runonphone $(QT_RUN_ON_PHONE_OPTIONS) --sis BelleChat.sis BelleChat.exe $(QT_RUN_OPTIONS)

BelleChat_template.pkg: C:/QtProjects/BelleChat/Bellechat.pro
	$(MAKE) -f $(MAKEFILE) qmake

BelleChat_installer.pkg: C:/QtProjects/BelleChat/Bellechat.pro
	$(MAKE) -f $(MAKEFILE) qmake

BelleChat_stub.pkg: C:/QtProjects/BelleChat/Bellechat.pro
	$(MAKE) -f $(MAKEFILE) qmake

sis: BelleChat_template.pkg
	$(if $(wildcard .make.cache), $(MAKE) -f $(MAKEFILE) ok_sis MAKEFILES=.make.cache , $(if $(QT_SIS_TARGET), $(MAKE) -f $(MAKEFILE) ok_sis , $(MAKE) -f $(MAKEFILE) fail_sis_nocache ) )

ok_sis:
	C:\QtSDK\Symbian\SDKs\Symbian3Qt474\bin\createpackage.bat -g $(QT_SIS_OPTIONS) BelleChat_template.pkg $(QT_SIS_TARGET) $(QT_SIS_CERTIFICATE) $(QT_SIS_KEY) $(QT_SIS_PASSPHRASE)

unsigned_sis: BelleChat_template.pkg
	$(if $(wildcard .make.cache), $(MAKE) -f $(MAKEFILE) ok_unsigned_sis MAKEFILES=.make.cache , $(if $(QT_SIS_TARGET), $(MAKE) -f $(MAKEFILE) ok_unsigned_sis , $(MAKE) -f $(MAKEFILE) fail_sis_nocache ) )

ok_unsigned_sis:
	C:\QtSDK\Symbian\SDKs\Symbian3Qt474\bin\createpackage.bat -g $(QT_SIS_OPTIONS) -o BelleChat_template.pkg $(QT_SIS_TARGET)

BelleChat.sis:
	$(MAKE) -f $(MAKEFILE) sis

installer_sis: BelleChat_installer.pkg sis
	$(MAKE) -f $(MAKEFILE) ok_installer_sis

ok_installer_sis: BelleChat_installer.pkg
	C:\QtSDK\Symbian\SDKs\Symbian3Qt474\bin\createpackage.bat $(QT_SIS_OPTIONS) BelleChat_installer.pkg - $(QT_SIS_CERTIFICATE) $(QT_SIS_KEY) $(QT_SIS_PASSPHRASE)

unsigned_installer_sis: BelleChat_installer.pkg unsigned_sis
	$(MAKE) -f $(MAKEFILE) ok_unsigned_installer_sis

ok_unsigned_installer_sis: BelleChat_installer.pkg
	C:\QtSDK\Symbian\SDKs\Symbian3Qt474\bin\createpackage.bat $(QT_SIS_OPTIONS) -o BelleChat_installer.pkg

fail_sis_nocache:
	$(error Project has to be built or QT_SIS_TARGET environment variable has to be set before calling 'SIS' target)

stub_sis: BelleChat_stub.pkg
	$(if $(wildcard .make.cache), $(MAKE) -f $(MAKEFILE) ok_stub_sis MAKEFILES=.make.cache , $(if $(QT_SIS_TARGET), $(MAKE) -f $(MAKEFILE) ok_stub_sis , $(MAKE) -f $(MAKEFILE) fail_sis_nocache ) )

ok_stub_sis:
	C:\QtSDK\Symbian\SDKs\Symbian3Qt474\bin\createpackage.bat -s $(QT_SIS_OPTIONS) BelleChat_stub.pkg $(QT_SIS_TARGET) $(QT_SIS_CERTIFICATE) $(QT_SIS_KEY) $(QT_SIS_PASSPHRASE)

deploy: sis
	call BelleChat.sis

mocclean: compiler_moc_header_clean compiler_moc_source_clean

mocables: compiler_moc_header_make_all compiler_moc_source_make_all

compiler_moc_header_make_all: moc\moc_qmlapplicationviewer.cpp moc\moc_connectionsettings.cpp moc\moc_sessionwrapper.cpp moc\moc_channellistitem.cpp moc\moc_whoisitem.cpp moc\moc_palette.cpp
compiler_moc_header_clean:
	-$(DEL_FILE) moc\moc_qmlapplicationviewer.cpp moc\moc_connectionsettings.cpp moc\moc_sessionwrapper.cpp moc\moc_channellistitem.cpp moc\moc_whoisitem.cpp moc\moc_palette.cpp
moc\moc_qmlapplicationviewer.cpp: qmlapplicationviewer\qmlapplicationviewer.h
	C:\QtSDK\Symbian\SDKs\Symbian3Qt474\bin\moc.exe $(DEFINES) $(INCPATH) -DSYMBIAN c:\QtProjects\BelleChat\qmlapplicationviewer\qmlapplicationviewer.h -o c:\QtProjects\BelleChat\moc\moc_qmlapplicationviewer.cpp

moc\moc_connectionsettings.cpp: connectionsettings.h
	C:\QtSDK\Symbian\SDKs\Symbian3Qt474\bin\moc.exe $(DEFINES) $(INCPATH) -DSYMBIAN c:\QtProjects\BelleChat\connectionsettings.h -o c:\QtProjects\BelleChat\moc\moc_connectionsettings.cpp

moc\moc_sessionwrapper.cpp: ..\communi\include\IrcSession \
		..\communi\include\ircsession.h \
		..\communi\include\IrcGlobal \
		..\communi\include\ircglobal.h \
		..\communi\include\IrcMessage \
		..\communi\include\ircmessage.h \
		..\communi\include\IrcSender \
		..\communi\include\ircsender.h \
		connectionsettings.h \
		whoisitem.h \
		channellistitem.h \
		palette.h \
		sessionwrapper.h
	C:\QtSDK\Symbian\SDKs\Symbian3Qt474\bin\moc.exe $(DEFINES) $(INCPATH) -DSYMBIAN c:\QtProjects\BelleChat\sessionwrapper.h -o c:\QtProjects\BelleChat\moc\moc_sessionwrapper.cpp

moc\moc_channellistitem.cpp: channellistitem.h
	C:\QtSDK\Symbian\SDKs\Symbian3Qt474\bin\moc.exe $(DEFINES) $(INCPATH) -DSYMBIAN c:\QtProjects\BelleChat\channellistitem.h -o c:\QtProjects\BelleChat\moc\moc_channellistitem.cpp

moc\moc_whoisitem.cpp: whoisitem.h
	C:\QtSDK\Symbian\SDKs\Symbian3Qt474\bin\moc.exe $(DEFINES) $(INCPATH) -DSYMBIAN c:\QtProjects\BelleChat\whoisitem.h -o c:\QtProjects\BelleChat\moc\moc_whoisitem.cpp

moc\moc_palette.cpp: palette.h
	C:\QtSDK\Symbian\SDKs\Symbian3Qt474\bin\moc.exe $(DEFINES) $(INCPATH) -DSYMBIAN c:\QtProjects\BelleChat\palette.h -o c:\QtProjects\BelleChat\moc\moc_palette.cpp

compiler_rcc_make_all:
compiler_rcc_clean:
compiler_image_collection_make_all: ui\qmake_image_collection.cpp
compiler_image_collection_clean:
	-$(DEL_FILE) ui\qmake_image_collection.cpp
compiler_moc_source_make_all:
compiler_moc_source_clean:
compiler_uic_make_all:
compiler_uic_clean:
compiler_yacc_decl_make_all:
compiler_yacc_decl_clean:
compiler_yacc_impl_make_all:
compiler_yacc_impl_clean:
compiler_lex_make_all:
compiler_lex_clean:
compiler_clean: compiler_moc_header_clean 

dodistclean:
	-@ if EXIST "c:\QtProjects\BelleChat\BelleChat_template.pkg" $(DEL_FILE)  "c:\QtProjects\BelleChat\BelleChat_template.pkg"
	-@ if EXIST "c:\QtProjects\BelleChat\BelleChat_stub.pkg" $(DEL_FILE)  "c:\QtProjects\BelleChat\BelleChat_stub.pkg"
	-@ if EXIST "c:\QtProjects\BelleChat\BelleChat_installer.pkg" $(DEL_FILE)  "c:\QtProjects\BelleChat\BelleChat_installer.pkg"
	-@ if EXIST "c:\QtProjects\BelleChat\Makefile" $(DEL_FILE)  "c:\QtProjects\BelleChat\Makefile"
	-@ if EXIST "c:\QtProjects\BelleChat\BelleChat_exe.mmp" $(DEL_FILE)  "c:\QtProjects\BelleChat\BelleChat_exe.mmp"
	-@ if EXIST "c:\QtProjects\BelleChat\BelleChat_reg.rss" $(DEL_FILE)  "c:\QtProjects\BelleChat\BelleChat_reg.rss"
	-@ if EXIST "c:\QtProjects\BelleChat\BelleChat.rss" $(DEL_FILE)  "c:\QtProjects\BelleChat\BelleChat.rss"
	-@ if EXIST "c:\QtProjects\BelleChat\BelleChat.loc" $(DEL_FILE)  "c:\QtProjects\BelleChat\BelleChat.loc"
	-@ if EXIST "c:\QtProjects\BelleChat\bld.inf" $(DEL_FILE)  "c:\QtProjects\BelleChat\bld.inf"

distclean: clean dodistclean

clean: bld.inf
	-$(SBS) reallyclean --toolcheck=off -c winscw_udeb.mwccinc -c arm.v5.udeb.gcce4_4_1 -c arm.v6.udeb.gcce4_4_1 -c arm.v5.urel.gcce4_4_1 -c arm.v6.urel.gcce4_4_1


