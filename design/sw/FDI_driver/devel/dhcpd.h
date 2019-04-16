/*------------------------------------------------------------------------------
 -- dhcpd.h

 -- TODO LICENCE

 -- creator: dodotronix | BUT | 2019

 -- description:
 -----------------------------------------------------------------------------*/

#ifndef DHCPD_H
#define DHCPD_H

extern void server_init(int *socket_server);
extern int client_init(int *socket_client, int *socket_server);

#endif //DHCPD_H
