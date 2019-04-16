/*------------------------------------------------------------------------------
 -- server.h

 -- TODO LICENCE

 -- creator: dodotronix | BUT | 2019

 -- description:
 -----------------------------------------------------------------------------*/

#ifndef SERVER_H
#define SERVER_H

#define PORT 15000

extern int server_init(int *sock_server);
extern int get_client(int *sock_server, int *sock_client);
extern int put_data(int *sock_client, void *data, int size);
extern int get_data(int *sock_client, void *data, int len);
extern void unconnect(int *sock_client);

#endif //SERVER_H
