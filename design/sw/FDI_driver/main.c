/*------------------------------------------------------------------------------
 -- main.c

 -- TODO LICENCE

 -- creator: dodotronix | BUT | 2019

 -- description:
 -----------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
-- Includes
------------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <time.h>

//local includes
#include "system.h"
#include "seqgen.h"
#include "server.h"
#include "daq.h"

#define DATA_LENGTH 20

/*------------------------------------------------------------------------------
-- Registers
------------------------------------------------------------------------------*/
uint32_t *seqgen_ctrl;
uint32_t *daq_stat;
uint32_t *daq_memory;

int sock_server, sock_client, rx;
char data[DATA_LENGTH];
char to_send[200*BUFFER_SIZE]; //maximum number size in chars (5)

/*------------------------------------------------------------------------------
-- Functions
------------------------------------------------------------------------------*/

int get_numbers(char *data, int len, int *values, int number)
{
  char str[8];
  memset(str, 0, 8);
  uint8_t offset = 0;
  uint8_t pos = 0;

  for(int i=0; i<len; ++i){
    if((number-pos) == 0)
      return i;

    str[i-offset] = data[i];
    if(data[i] == '\n'){
      values[pos] = atoi(str);
      memset(str, 0, 8);
      offset = i+1; 
      ++pos;
    }
  }
  return len;
}

void actions(int *sock_client, char *data, int got)
{
  for(int i=0; i<got;){
    int values[3] = {0, 0, 0}; //cmd, bitrate, order, repeat

    //get numbers from TCP buffer
    i += get_numbers(data+i, got-i, values, 1);
   
    switch(values[0]){
      case 1 :
        printf("Sequence setup ...\n");
        i += get_numbers(data+i, got-i, values, 3);
        sg_setup(seqgen_ctrl, values[0], values[2], values[1]); //[bitrate, repeat, order]
        break;
      case 2 : 
        printf("Measuring signal ...\n");
        sg_start(seqgen_ctrl);
        usleep(100000);

        read_daq(daq_memory, to_send);
        put_data(sock_client, to_send, 200*BUFFER_SIZE);
    }
  }
}

void control_device(int *sock_client)
{
  int rx;

  while(1){
    errno = 0;
    rx = get_data(sock_client, data, DATA_LENGTH);

    if(rx > 0)
      actions(sock_client, data, rx);

    else if (errno == 0)
      break;
  }
}

/*------------------------------------------------------------------------------
-- Main
------------------------------------------------------------------------------*/
int main(void)
{
  //Initialize 
  sg_init(&seqgen_ctrl);
  daq_init(&daq_stat, &daq_memory);
  server_init(&sock_server);

  while(1){
    printf("Waiting for client\n");
    get_client(&sock_server, &sock_client);

    //switch
    control_device(&sock_client);

    unconnect(&sock_client);
    printf("Client disconnected ...\n\n");
  }

  unconnect(&sock_server);
  return EXIT_SUCCESS;
}
