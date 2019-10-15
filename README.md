# IP-Distributed_file_system_service
A distributed dropbox-like file system service.

## Environment
The program has been run in a virtual machine with Ubuntu 18.04.1 LTS. Source files have been compiled using gcc 7.3.0.
To compile the program execute the command make in the A3 folder where the makefile is.

## Execution
The order of the execution must be: First the registry, then as many servers as indicated to the registry and finally the client. The executables of each component are located in the directory with their names.

**Registry:**

``` $ registry/registry <port> <n_servers> ```

- *port:* Port where the registry will be listening. Must have 4 digits.
- *n_servers:* Number of server in the file system.

**Server:**

``` $ server/server <port> <reg_ip> <reg_port> <dir>```

- *port:* Port where the server will be listening. One of the servers must be listening to port 6666. Must have 4 digits.
- *reg_ip:* IP of the registry.
- *reg_port:* Port of the registry.
- *dir:* Directory where the files will be saved.

**Client:**

```$ client/client <command> <file>```

- *command:* Operation performed to the file. It can be *put, get or delete*.
- *file:* Path to the relevant file.

## Implementation
### Registry
The registry implements a fork on demand server. It expects <n_servers> to connect to it.

When each server connect, their ip, port and file descriptor of the socket is saved in an array and each server is given and id. After all servers are connected, the registry sends the code 40 to all of them so they start listening to clients.

The registry is all the time listening in case that a server performs a query of another server. In that case, it looks for the id of the requested server in the array and replies with its information.

### Server
#### File mapping
When the server receives a file, in order to know to which server it should go, the djb2 hash value of the filename is calculated. We obtain the server id doing module of the total number of servers to the hash value.

#### Register
When first launched, the server sends a message with its port to the registry and it receives its id and the total number of servers. Then it waits until the registry sends the code 40 and starts listening to the clients. The server implements for on demand. Each time a client connects, a new process is launch to listen to it.

#### Put
If the file maps to the the server receiving the put request, it reads the file from the socket and writes it in a file in chunk of 2000 bytes.
If the file maps to a remote server, the file is written to the server receiving the put request. After receiving the file, it asks the registry for the IP and port of the target server. Finally, it opens a new connection, as if it was a client, sends the file to the target server and deletes the file from its files directory so it is not duplicated.

#### Get
If the file maps to the the server receiving the get request, it reads the file from its files directory and sends it back to the client.
If the file maps to a remote server, the server ask the registry for the IP and port of the target server.
Then, the server sends back the IP and port of the target server to the client.
The client then creates a new connection to the target server and it sends back the file to the client.

#### Delete
If the file maps to the the server receiving the get request, it reads the file from its files directory and sends it back to the client.

If the file maps to a remote server, the server ask the registry for the IP and port of the target server. Then, the server sends back the IP and port of the target server to the client. The client then creates a new connection to the target server and it sends back the file to the client.

### Client
#### Put
The client reads from the file and send it in chunks of 2000 bytes. It waits for the server to reply with P_OK if the file was put properly or P_ERR if there was an error. For the client there is no difference if the file is stored in a remote server because it only communicates with the requested server.

#### Get
If the requested file is stored in the requested server, it reads from the socket in chunks of 2000 bytes and writes it in a file.
If the requested file is in a remote server, it will receive the IP and port of the remote server and it will make a new request to it. It will obtain the file if it exists, or receive a G_ERR if the file did not exist.

#### Delete
If the requested file is stored in the requested server, it reads from the socket in chunks of 2000 bytes and writes it in a file. For the client there is no difference if the file is stored in a remote server because it only communicates with the requested server.
