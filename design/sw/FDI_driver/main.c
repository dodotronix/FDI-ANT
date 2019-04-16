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
volatile uint32_t *seqgen_ctrl;
volatile uint32_t *daq_ctrl;
volatile uint32_t *daq_stat;
volatile uint16_t *daq_memory;

int sock_server, sock_client, rx;
char data[DATA_LENGTH];
int values[4]; //cmd, bitrate, order, repeat
char to_send[20*BUFFER_SIZE]; //maximum number size in chars (5)

/*------------------------------------------------------------------------------
-- Functions
------------------------------------------------------------------------------*/

void get_numbers(char *data, int len, int *values)
{
  char str[8];
  memset(str, 0, 8);
  uint8_t offset = 0;
  uint8_t pos = 0;

  for(int i=0; i<len; ++i){
    str[i-offset] = data[i];
    if(data[i] == '\n'){
      values[pos] = atoi(str);
      memset(str, 0, 8);
      offset = i+1; 
      ++pos;
    }
  }
}

void actions(int *sock_client, char *data, int got, int *values)
{
  //get numbers from TCP buffer
  get_numbers(data, got, values);

  switch(values[0]){
    case 1 :
      printf("Sequence setup ...\n");
      sg_setup(seqgen_ctrl, values[1], values[3], values[2]); //[bitrate, repeat, order]
      break;
    case 2 : 
      printf("Measuring signal ...\n");

      //activate DAQ @ Sequence generator
      daq_start(daq_ctrl);
      usleep(100);
      sg_start(seqgen_ctrl);

      //wait for daq flag
      while(IS_BIT_SET(daq_stat, DAQ_DONE_Msk));

      // read memory
      read_daq(daq_memory, to_send);
      put_data(sock_client, to_send, 20*BUFFER_SIZE);
  }
}

void control_device(int *sock_client)
{
  int rx;

  while(1){
    errno = 0;
    rx = get_data(sock_client, data, DATA_LENGTH);

    if(rx > 0)
      actions(sock_client, data, rx, values);

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
  daq_init(&daq_ctrl, &daq_stat, &daq_memory);
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
