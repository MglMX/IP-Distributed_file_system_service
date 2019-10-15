all: client server registry

client: client/client.o
	gcc -o client/client client/client.o messages/messages.c

server: server/server.o
	gcc -o server/server server/server.o messages/messages.c

registry: registry/registry.o
	gcc -o registry/registry registry/registry.o messages/messages.c

clean:
	rm -f client/client server/server registry/registry
