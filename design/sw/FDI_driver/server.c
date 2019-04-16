/*------------------------------------------------------------------------------
 -- server.c

 -- TODO LICENCE

 -- creator: dodotronix | BUT | 2019

 -- description:
 -----------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
-- Includes
------------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "server.h"

/*------------------------------------------------------------------------------
-- Functions
------------------------------------------------------------------------------*/

/*
 * initialize tcp server
*/
int server_init(int *sock_server)
{
  int yes = 1;
  if((*sock_server = socket(AF_INET, SOCK_STREAM, 0)) < 0){
    perror("socket");
    return EXIT_FAILURE;
  }

  setsockopt(*sock_server, SOL_SOCKET, SO_REUSEADDR, (void *)&yes , sizeof(yes));

  //setup listening address
  struct sockaddr_in addr;
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = htonl(INADDR_ANY);
  addr.sin_port = htons(PORT);

  //get access to system source
  int r = 0;
  if( ( r = bind(*sock_server,
        (struct sockaddr *)&addr, sizeof( addr ) ) ) < 0 ){
    printf("ERR bind(): %d\n", r );
    return 1;
  }

  return EXIT_SUCCESS;
}

/*
 * get client 
*/
int get_client(int *sock_server, int *sock_client)
{
  //listen for requests
  listen(*sock_server, 1024);
  printf("Listening on port %d ...\n", PORT);

  //get first client
  if((*sock_client = accept(*sock_server, NULL, NULL)) < 0){
    perror("accept");
    return EXIT_FAILURE;
  }

  printf("Connected ... \n");
  return EXIT_SUCCESS;
}

/*
 * put data from client
*/
int put_data(int *sock_client, void *data, int size)
{
  return send(*sock_client, data, size, MSG_NOSIGNAL);
}

/*
 * get data from client 
*/
int get_data(int *sock_client, void *data, int len)
{
  return recv(*sock_client, data, len, MSG_DONTWAIT);
}

void unconnect(int *sock_client)
{
  close(*sock_client);
}
