#include "contiki.h"
#include "net/netstack.h"
#include "net/nullnet/nullnet.h"
#include <string.h>
#include <stdio.h>
#include "dev/button-sensor.h"
#include "lib/sensors.h"
#include "project-conf.h"

// Log configuration
#include "sys/log.h"
#define LOG_MODULE "App\0"
#define LOG_LEVEL LOG_LEVEL_INFO

// Configuration
#define SEND_INTERVAL (8 * CLOCK_SECOND)
#define PACKET_TRANSMISSION_INTERVAL (2 * CLOCK_SECOND)
//#define PACKET_BUFFER_LENGTH 8
#define K_PACKETS 16
#define PACKET_LENGTH 4

static unsigned packet_seq = 0;
static unsigned number_of_retansmissions = 0;
static unsigned packets_transmitted = 0;
static bool completed = false;
static linkaddr_t nodesAcked[NUMBER_OF_NODES];
static uint8_t nodesAckedCnt = 0;
/*---------------------------------------------------------------------------*/
PROCESS(main_process, "Main process");
AUTOSTART_PROCESSES(&main_process);

/*---------------------------------------------------------------------------*/



void input_callback(const void *data, uint16_t len, const linkaddr_t *src, const linkaddr_t *dest)
{
  // Copy as much, as ther will fit, of the incoming packet into the packetbuffer.  
  uint8_t packet_buffer[PACKET_LENGTH];
  memcpy(packet_buffer, data, PACKET_LENGTH > len ? len : PACKET_LENGTH);
  uint8_t packet_seq_l = packet_buffer[0];
  if(packet_buffer[1] == 'a'){
    if(packet_seq_l == 15) {
      static linkaddr_t src_local;
      linkaddr_copy(&src_local, src);
      int saved = 0;
      for(uint8_t i = 0; i < NUMBER_OF_NODES; i++) {
          if(linkaddr_cmp(&src_local, &nodesAcked[i])) {
              saved = 1;
              break;
          }
      }
      if(!saved) {
          linkaddr_copy(&nodesAcked[nodesAckedCnt], &src_local);
          nodesAckedCnt++;
      }
      if(nodesAckedCnt == NUMBER_OF_NODES)
        completed = true;
    }
  }
  else if(packet_buffer[1] == 'n'){
    //TODO: store information about which packet was not received by the nodes. to be used for selevtiv repeat  
    printf("Received NACK on packet %d\n", packet_seq_l); 
    packet_seq = packet_seq_l;
    number_of_retansmissions++;
    completed = false;
  }
  else{
    printf("Received packet with unknown header from ?\n");
  }
}


/* void send_msg(void){
  //static unsigned packet_seq = 0;
  static uint8_t packet[PACKET_BUFFER_LENGTH] = {1,2,3,4,5,6,7,8};

  while(packet_seq < 8){
  LOG_INFO("Sending packet %u to ", packet_seq);
  LOG_INFO_LLADDR(NULL);
  LOG_INFO_("\n");
  
  //Construct packet and send
  packet[0] = packet_seq;
  nullnet_buf = packet;
  nullnet_len = PACKET_BUFFER_LENGTH;
  NETSTACK_NETWORK.output(NULL);
  packet_seq++;
  // TODO: need a pause in transmission between packets, to allow nodes to send ACK/NACK.
  }
  packet_seq = 0;
}
*/
/*---------------------------------------------------------------------------*/

PROCESS_THREAD(main_process, ev, data)
{
  static struct etimer transmission_pause_timer;
  SENSORS_ACTIVATE(button_sensor);
  PROCESS_BEGIN();

  //Initialize NullNet
  nullnet_set_input_callback(input_callback);

  while(1) {
    
    static uint8_t packet[PACKET_LENGTH] = {1,2,3,4};
    PROCESS_WAIT_EVENT_UNTIL(ev == sensors_event && data == &button_sensor);
    etimer_set(&transmission_pause_timer, PACKET_TRANSMISSION_INTERVAL);
    while(!completed){

      //Construct packet and send
      packet[0] = packet_seq;
      nullnet_buf = packet;
      nullnet_len = PACKET_LENGTH;
      NETSTACK_NETWORK.output(NULL);
      packet_seq++;
      packets_transmitted++;

      etimer_reset(&transmission_pause_timer);
      PROCESS_YIELD_UNTIL(etimer_expired(&transmission_pause_timer));
    }
    printf("Completed transmission after a total of %u packets \n", packets_transmitted);
    number_of_retansmissions = 0;
    packet_seq = 0;
    packets_transmitted = 0;
    completed = false;
    nodesAckedCnt = 0;
    for(uint8_t i = 0; i < NUMBER_OF_NODES; i++) {
        nodesAcked[i] = linkaddr_null;
    }
  }

  PROCESS_END();
}