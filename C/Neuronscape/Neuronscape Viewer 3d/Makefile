CC=g++
#COMMON_SRC=../Common/Utilities.cpp ../Common/CartesianVector.cpp ../Common/SphericalVector.cpp \
../Common/DBRecord_ClientObject.cpp ../Common/DB_ClientObject.cpp ../Common/NetworkStackClient.cpp \
../Common/GLUtilities.cpp ../Common/GLTexture.cpp
COMMON_SRC=../Common/Utilities.cpp ../Common/CartesianVector.cpp ../Common/SphericalVector.cpp \
../Common/DBRecord_ClientObject.cpp ../Common/DB_ClientObject.cpp ../Common/NetworkStackClient.cpp \
../Common/GLUtilities.cpp ../Common/GLTexture.cpp \
../Common/View3D.cpp

VWR_SRC=KeyboardMap.cpp \
ViewerFrame.cpp \
MainFrame.cpp \
App.cpp


NEI_SRC=SCP.cpp SpinnakerNetStack.cpp \
RetinaThread.cpp MotorThread.cpp \
Eye.cpp EyePanel.cpp \
MainFrame.cpp App.cpp

#APP_SRC=DBRecord_Client.cpp DBRecord_Object.cpp DB_Client.cpp DB_Object.cpp NetworkStackServer.cpp MainFrame.cpp App.cpp
PY_INC=-I/usr/include/python2.7
O_GL_LIB=-lglut -lGL 
CFLAGS=`wx-config --cppflags` ${PY_INC}
MYFLAGS=-I/opt/wxWidgets-2.9.3/lib/wx/include/gtk2-unicode-2.9 -I/opt/wxWidgets-2.9.3/include/wx-2.9 -D_FILE_OFFSET_BITS=64 -DWXUSINGDLL -D__WXGTK__
LFLAGS=`wx-config --libs --gl-libs` ${O_GL_LIB} ${MYFLAGS}
WX_S_OBJ=-Wl,--rpath,/opt/wxWidgets-2.9.3/lib/

NEI_TGT=NEI.exe
VWR_TGT=VWR.exe

# note: the following must be on the path:
# PATH=$PATH:/opt/wxWidgets-2.9.3/bin/:/opt/wxWidgets-2.9.3/lib
# it is not currently in bashrc.

compile:
	${CC} ${CFLAGS} -c ${WX_S_OBJ} ${COMMON_SRC} ${VWR_SRC} 

build:
	${CC} ${LFLAGS} ${WX_S_OBJ} ${COMMON_SRC} ${VWR_SRC} -o ${VWR_TGT}


clean:
	rm *.o ${VWR_TGT}

#g++ `wx-config --cppflags` `wx-config --libs` -c -Wl,--rpath,/opt/wxWidgets-2.9.3/lib/DBRecord_Client.cpp DB_Client.cpp NetworkStackServer.cpp MainFrame.cpp DB_Object.cpp App.cpp DBRecord_Object.cpp ../Common/CartesianVector.cpp ../Common/SphericalVector.cpp ../Common/Utilities.cpp


# buildorder / deps

CCC=${CC} ${CFLAGS}


#main.exe : $(OBJECTS)
#	$(CC) $(CFLAGS) $(OBJECTS) -o main.exe
#
#main.o : main.c
#	$(CC) $(CFLAGS) -c main.c
#
#foo.o : foo.c
#	$(CC) $(CFLAGS) -c foo.c


COMMON_OBJS=${COMMON_SRC:.cpp=.o}
VWR_OBJS=${VWR_SRC:.cpp=.o}
COMMON_OBJS_LOC=$(COMMON_OBJS,F)

top2: 
	echo ${COMMON_OBJS}
	echo ${COMMON_OBJS_LOC}

top: App.o
	echo ${COMMON_OBJS}
	echo ${VWR_SRC}	
	#${CC} ${LFLAGS} ${WX_S_OBJ} ${COMMON_OBJS} ${VWR_OBJS}  -o ${VWR_TGT}

App.o: ViewerFrame.o MainFrame.o 
	${CC} ${CFLAGS} ${WX_S_OBJ} -c App.cpp

MainFrame.o: ViewerFrame.o ${COMMON_OBJS}
	${CC} ${CFLAGS} ${WX_S_OBJ} -c MainFrame.cpp

ViewerFrame.o: View3d.o ViewBirdsEye.o ${COMMON_OBJS}
	${CC} ${CFLAGS} ${WX_S_OBJ} -c ViewerFrame.cpp

View3d.o: KeyboardMap.o ${COMMON_OBJS}
	${CC} ${CFLAGS} ${WX_S_OBJ} -c View3d.cpp

#${COMMON_OBJS}
#echo c flags are :${CFLAGS}
ViewBirdsEye.o: ${COMMON_OBJS} 
	${CC} ${CFLAGS} ${WX_S_OBJ} -c ViewBirdsEye.cpp

#echo ${WX_S_OBJ} ${COMMON_SRC}
KeyboardMap.o:
	${CC} ${CFLAGS} ${WX_S_OBJ} -c KeyboardMap.cpp
	
common: ${COMMON_OBJS}
	${CC} ${CFLAGS} ${WX_S_OBJ} -c ${COMMON_SRC}


foo = a.o b.o c.o
bar = $(foo:.o=.c)

test:
	echo ${foo} ${VWR_SRC}
	echo ${bar} ${VWR_OBJS}
	echo $(foo)
	echo ${CC} ${CFLAGS} ${WX_S_OBJ} -c App.cpp

#top: App.o MainFrame.o ${MF_OBJS}
#	${CC} ${FLAGS} ${WX_S_OBJ} App.o MainFrame.o ${MF_OBJS} -o ${NEI_TGT}

#App.o: MainFrame.o 
#	${CC} ${FLAGS} ${WX_S_OBJ} -c App.cpp MainFrame.o 

#MAINFRAME_DEPS=../Common/Utilities.cpp ../Common/NetworkStackClient.cpp ../Common/DBRecord_ClientObject.cpp ../Common/DB_ClientObject.cpp ../Common/CartesianVector.cpp ../Common/SphericalVector.cpp EyePanel.cpp RetinaThread.cpp MotorThread.cpp
#MF_OBJS=${MAINFRAME_DEPS:.cpp=.o}

#MainFrame.o: ${MAINFRAME_DEPS}
#	${CC} ${FLAGS} ${WX_S_OBJ} -c MainFrame.cpp ${MAINFRAME_DEPS}

