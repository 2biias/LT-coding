#include "contiki.h"
#include "net/netstack.h"
#include "net/nullnet/nullnet.h"
#include <string.h>
#include <stdio.h>
#include "dev/button-sensor.h"
#include "lib/sensors.h"

// Log configuration
#include "sys/log.h"
#define LOG_MODULE "App\0"
#define LOG_LEVEL LOG_LEVEL_INFO

// Configuration
#define PACKET_BUFFER_LENGTH 4
#define ACK_LENGTH 2

const linkaddr_t broadcast_addr = {{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }};
uint8_t next_packet_in_seq = 0;
static bool listen_for_packets = true;
/*---------------------------------------------------------------------------*/
PROCESS(main_process, "Main process");
AUTOSTART_PROCESSES(&main_process);
/*---------------------------------------------------------------------------*/

void send_ack(uint8_t packet_seq, const linkaddr_t *dest_addr)
{
  static uint8_t packet[ACK_LENGTH] = {0};

  //printf("Sending ACK on packet %u\n", packet_seq);
    
  // Construct packet and send
  packet[0] = packet_seq;
  packet[1] = 'a';
  nullnet_buf = packet;
  nullnet_len = ACK_LENGTH;
  NETSTACK_NETWORK.output(dest_addr); 
}

void send_nack(uint8_t packet_seq, const linkaddr_t *dest_addr)
{
  static uint8_t packet[ACK_LENGTH] = {0};

  printf("Sending NACK on packet %u\n", packet_seq);
  
  // Construct packet and send
  packet[0] = packet_seq;
  packet[1] = 'n';
  nullnet_buf = packet;
  nullnet_len = ACK_LENGTH;
  NETSTACK_NETWORK.output(dest_addr); 
}

void input_callback(const void *data, uint16_t len, const linkaddr_t *src, const linkaddr_t *dest)
{
  static linkaddr_t src_local;
  static linkaddr_t dest_local;
  linkaddr_copy(&src_local, src);
  linkaddr_copy(&dest_local, dest);
  const uint8_t last_packet_in_seq = 15; // TODO: get the message length from header on packet zero
  if(listen_for_packets) {
    // Check if this packet is part of the broadcast.
    if(linkaddr_cmp(&dest_local, &broadcast_addr)){
    // Copy as much, as ther will fit, of the incoming packet into the packetbuffer.  
    uint8_t packet_buffer[PACKET_BUFFER_LENGTH];
    memcpy(packet_buffer, data, PACKET_BUFFER_LENGTH > len ? len : PACKET_BUFFER_LENGTH);
    uint8_t packet_seq = packet_buffer[0];
    
    if(packet_seq == next_packet_in_seq){
      //printf("Received packet number %d\n", packet_seq);
      next_packet_in_seq++;
      // TODO: when more nodes join the network, it might be necessary to add a small randome delay
      // before sending ACK to avoid crosstalk. unless this is completely handled by the CSMA mac layer
      send_ack(packet_seq, &src_local);
      if(packet_seq == last_packet_in_seq){
        //next_packet_in_seq = 0;
        printf("Completed reception of full message \n");
        listen_for_packets = false;
        }
      }
      else if(packet_seq > next_packet_in_seq){
        send_nack(next_packet_in_seq, &src_local);
      }
      else if(packet_seq < next_packet_in_seq){
        /*Ignore allready received packets*/
      }
    }
  } else if(linkaddr_cmp(&dest_local, &broadcast_addr) && ((uint8_t*)data)[1] != 'a') {
    send_ack(last_packet_in_seq, &src_local);
  }
}

/*---------------------------------------------------------------------------*/
PROCESS_THREAD(main_process, ev, data)
{
  SENSORS_ACTIVATE(button_sensor);
  PROCESS_BEGIN();

  // Initialize NullNet
  nullnet_set_input_callback(input_callback);

  // Yield the process for ever.
  while(1) {
    PROCESS_WAIT_EVENT_UNTIL(ev == sensors_event && data == &button_sensor);
    next_packet_in_seq = 0;
    listen_for_packets = true;
  }
  PROCESS_END();
}