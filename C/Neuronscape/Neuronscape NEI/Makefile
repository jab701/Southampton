CC=g++
#COMMON_SRC=../Common/Utilities.cpp ../Common/CartesianVector.cpp ../Common/SphericalVector.cpp \
../Common/DBRecord_ClientObject.cpp ../Common/DB_ClientObject.cpp ../Common/NetworkStackClient.cpp \
../Common/GLUtilities.cpp ../Common/GLTexture.cpp
COMMON_SRC=../Common/Utilities.cpp ../Common/CartesianVector.cpp ../Common/SphericalVector.cpp \
../Common/DBRecord_ClientObject.cpp ../Common/DB_ClientObject.cpp ../Common/NetworkStackClient.cpp \
../Common/GLUtilities.cpp ../Common/GLTexture.cpp


NEI_SRC=SCP.cpp SpinnakerNetStack.cpp \
RetinaThread.cpp MotorThread.cpp \
EyePanel.cpp \
MainFrame.cpp App.cpp

#APP_SRC=DBRecord_Client.cpp DBRecord_Object.cpp DB_Client.cpp DB_Object.cpp NetworkStackServer.cpp MainFrame.cpp App.cpp
PY_INC=-I/usr/include/python2.7
O_GL_LIB=-lglut -lGL 
CFLAGS=`wx-config --cppflags` ${PY_INC}
MYFLAGS=-I/opt/wxWidgets-2.9.3/lib/wx/include/gtk2-unicode-2.9 -I/opt/wxWidgets-2.9.3/include/wx-2.9 -D_FILE_OFFSET_BITS=64 -DWXUSINGDLL -D__WXGTK__
LFLAGS=`wx-config --libs --gl-libs` ${O_GL_LIB} ${MYFLAGS}
WX_S_OBJ=-Wl,--rpath,/opt/wxWidgets-2.9.3/lib/

NEI_TGT=NEI.exe

# note: the following must be on the path:
# PATH=$PATH:/opt/wxWidgets-2.9.3/bin/:/opt/wxWidgets-2.9.3/lib
# it is not currently in bashrc.

compile:
	${CC} ${CFLAGS} -c ${WX_S_OBJ} ${COMMON_SRC} ${NEI_SRC} 

build:
	${CC} ${LFLAGS} ${WX_S_OBJ} ${COMMON_SRC} ${NEI_SRC} -o ${NEI_TGT}


clean:
	rm *.o ${NEI_TGT}

#g++ `wx-config --cppflags` `wx-config --libs` -c -Wl,--rpath,/opt/wxWidgets-2.9.3/lib/DBRecord_Client.cpp DB_Client.cpp NetworkStackServer.cpp MainFrame.cpp DB_Object.cpp App.cpp DBRecord_Object.cpp ../Common/CartesianVector.cpp ../Common/SphericalVector.cpp ../Common/Utilities.cpp


# buildorder / deps



top: App.o MainFrame.o ${MF_OBJS}
	${CC} ${FLAGS} ${WX_S_OBJ} App.o MainFrame.o ${MF_OBJS} -o ${NEI_TGT}

App.o: MainFrame.o 
	${CC} ${FLAGS} ${WX_S_OBJ} -c App.cpp MainFrame.o 

MAINFRAME_DEPS=../Common/Utilities.cpp ../Common/NetworkStackClient.cpp ../Common/DBRecord_ClientObject.cpp ../Common/DB_ClientObject.cpp ../Common/CartesianVector.cpp ../Common/SphericalVector.cpp EyePanel.cpp RetinaThread.cpp MotorThread.cpp
MF_OBJS=${MAINFRAME_DEPS:.cpp=.o}

MainFrame.o: ${MAINFRAME_DEPS}
	${CC} ${FLAGS} ${WX_S_OBJ} -c MainFrame.cpp ${MAINFRAME_DEPS}

