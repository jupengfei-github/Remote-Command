libsocket.so : libsocket.c
	gcc -shared -fPIC libsocket.c -o libsocket.so
	mv libsocket.so ../test

clean :
	rm *.o libsocket.so -rf > /dev/null
	rm *.o ../test/libsocket.so -rf > /dev/null
