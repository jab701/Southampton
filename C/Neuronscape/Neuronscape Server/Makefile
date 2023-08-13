CC=g++
COMMON_SRC=../Common/Utilities.cpp ../Common/CartesianVector.cpp ../Common/SphericalVector.cpp
APP_SRC=DBRecord_Client.cpp DBRecord_Object.cpp DB_Client.cpp DB_Object.cpp NetworkStackServer.cpp MainFrame.cpp App.cpp
FLAGS=`wx-config --cppflags` `wx-config --libs`
WX_S_OBJ=-Wl,--rpath,/opt/wxWidgets-2.9.3/lib/

TGT=nsSvr

# note: the following must be on the path:
# PATH=$PATH:/opt/wxWidgets-2.9.3/bin/:/opt/wxWidgets-2.9.3/lib
# it is not currently in bashrc.

compile:
	${CC} ${FLAGS} -c ${WX_S_OBJ} ${COMMON_SRC} ${APP_SRC} 

build:
	${CC} ${FLAGS} ${WX_S_OBJ} ${COMMON_SRC} ${APP_SRC} -o ${TGT}


clean:
	rm *.o ${TGT}

#g++ `wx-config --cppflags` `wx-config --libs` -c -Wl,--rpath,/opt/wxWidgets-2.9.3/lib/DBRecord_Client.cpp DB_Client.cpp NetworkStackServer.cpp MainFrame.cpp DB_Object.cpp App.cpp DBRecord_Object.cpp ../Common/CartesianVector.cpp ../Common/SphericalVector.cpp ../Common/Utilities.cpp




