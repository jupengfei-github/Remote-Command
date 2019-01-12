default: libsocket.so liblog.so libutil.so

OUTPUT_DIR := ../lib
libsocket.so : socket.c
	gcc -shared -fPIC socket.c -o $(OUTPUT_DIR)/libsocket.so

liblog.so : vlog.c
	gcc -shared -fPIC vlog.c -o $(OUTPUT_DIR)/liblog.so

libutil.so : util.c
	gcc -shared -fPIC util.c -o $(OUTPUT_DIR)/libutil.so

clean :
	rm $(OUTPUT_DIR)/libsocket.so -rf > /dev/null
	rm $(OUTPUT_DIR)/liblog.so    -rf > /dev/null
	rm $(OUTPUT_DIR)/libutil.so   -rf > /dev/null
