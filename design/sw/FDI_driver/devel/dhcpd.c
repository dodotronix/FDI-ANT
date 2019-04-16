/*------------------------------------------------------------------------------
 -- dhcpd.c

 -- TODO LICENCE

 -- creator: dodotronix | BUT | 2019

 -- description:
 -----------------------------------------------------------------------------*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

//setup coder
int server_init(int *socket_server)
{
  int size;
  int yes = 1;
  struct sockaddr_in addr;

  if((*socket_server = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    perror("socket");
    return EXIT_FAILURE;
  }

  setsockopt(*socket_server, SOL_SOCKET, SO_REUSEADDR, (void *)&yes , sizeof(yes));

  //[> setup listening address <]
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = htonl(INADDR_ANY);
  addr.sin_port = htons(1001);

  if(bind(*socket_server, (struct sockaddr *)&addr, sizeof(addr)) < 0){
    perror("bind");
    return EXIT_FAILURE;
  }

  listen(*socket_server, 1024);
  printf("Listening on port 1001 ...\n");

  return 0;
}

int client_init(int *socket_client, int *socket_server)
{
  if((*socket_client = accept(*socket_server, NULL, NULL)) < 0){
    perror("accept");
    return EXIT_FAILURE;
  }

  return 0;
}
