default: libsocket.so liblog.so

libsocket.so : socket.c
	gcc -shared -fPIC socket.c -o libsocket.so

liblog.so : vlog.c
	gcc -shared -fPIC vlog.c -o liblog.so

clean :
	rm *.o libsocket.so -rf > /dev/null
	rm *.o liblog.so -rf > /dev/null
