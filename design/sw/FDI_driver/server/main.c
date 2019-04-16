/*------------------------------------------------------------------------------
 -- main.c

 -- TODO LICENCE

 -- creator: dodotronix | BUT | 2019

 -- description:
 -----------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

// main
int main(void)
{
  int sock_server, sock_client, yes = 1, rx;
  struct sockaddr_in addr;
  uint32_t command;

  if((sock_server = socket(AF_INET, SOCK_STREAM, 0)) < 0)
  {
    perror("socket");
    return EXIT_FAILURE;
  }

  setsockopt(sock_server, SOL_SOCKET, SO_REUSEADDR, (void *)&yes , sizeof(yes));

  /* setup listening address */
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = htonl(INADDR_ANY);
  addr.sin_port = htons(1001);

  listen(sock_server, 1024);
  printf("Listening on port 1001 ...\n");

  if((sock_client = accept(sock_server, NULL, NULL)) < 0)
  {
    perror("accept");
    return EXIT_FAILURE;
  }
  printf("Connection requested ...");

  while(1){

    rx = recv(sock_client, (char *)&command, 4, MSG_DONTWAIT);

    if(rx > 0){
      printf("%d\n", command);
      send(sock_client, "ahoj", 20, MSG_NOSIGNAL);
    }
  }

  return EXIT_SUCCESS;
}
