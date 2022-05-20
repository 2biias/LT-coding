#include "contiki.h"
#include "net/netstack.h"
#include "dev/button-sensor.h"
#include "lib/sensors.h"
#include "net/nullnet/nullnet.h"
#include <string.h>
#include <stdio.h>
#include "encoder.h"
#include "project-conf.h"
#include "sys/rtimer.h"
#include "cc2420.h"

// Log configuration
#include "sys/log.h"
#define LOG_MODULE "App"
#define LOG_LEVEL LOG_LEVEL_INFO

/*---------------------------------------------------------------------------*/
PROCESS(main_process, "Main process");
AUTOSTART_PROCESSES(&main_process);

/*---------------------------------------------------------------------------*/

static uint8_t packetCnt = 0;
static rtimer_clock_t t1, t2, total;

#ifdef STOP_BY_ACK
static linkaddr_t nodesAcked[NUMBER_OF_NODES];
static uint8_t nodesAckedCnt = 0;
static bool stopEncoding = false;

void input_callback(const void *data, uint16_t len, const linkaddr_t *src, const linkaddr_t *dest)
{
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
    uint8_t msg = src->u8[0];
    nullnet_buf = &msg;
    nullnet_len = 1;
    NETSTACK_NETWORK.output(&src_local);
    if(nodesAckedCnt == NUMBER_OF_NODES) {
        printf("Encoding %i packets: %lums\n", packetCnt, ((unsigned long)total * 1000) / RTIMER_SECOND);
        stopEncoding = true;
    }
}

#else
void input_callback(const void *data, uint16_t len, const linkaddr_t *src, const linkaddr_t *dest)
{ }
#endif

PROCESS_THREAD(main_process, ev, data)
{
    static uint8_t packetOutLen = 0;
    static uint8_t packets[KPACKETS][PACKET_LENGTH];
    static uint8_t outputBuffer[OUT_PACKET_LENGTH] = {0};
    static struct etimer periodic_timer;
    SENSORS_ACTIVATE(button_sensor);
    PROCESS_BEGIN();

    // Initialize NullNet
    nullnet_set_input_callback(input_callback);

    // Initialise packets with some values
    for(uint16_t i = 0; i < KPACKETS; ++i) {
        for(uint16_t j = 0; j < PACKET_LENGTH; ++j) {
            packets[i][j] = i;
        }
    }

    while(1) {
        cc2420_off();
        /* Transmit k encoded packets when button is pressed */
        PROCESS_WAIT_EVENT_UNTIL(ev == sensors_event && data == &button_sensor);
#ifdef STOP_BY_ACK
        stopEncoding = false;
        nodesAckedCnt = 0;
        for(uint8_t i = 0; i < NUMBER_OF_NODES; i++) {
            nodesAcked[i] = linkaddr_null;
        }
#endif
        cc2420_on();
        etimer_set(&periodic_timer, SEND_INTERVAL);
        printf("Gateway multicasting %i packets.\n", KPACKETS+NPACKETS);
        for(packetCnt = 0; packetCnt < KPACKETS; packetCnt++) {
            etimer_reset(&periodic_timer);
            PROCESS_YIELD_UNTIL(etimer_expired(&periodic_timer));
            // Clear outputBuffer
            memset(outputBuffer, 0, packetOutLen);
            t1 = RTIMER_NOW();
            packetOutLen = EncodePackage(packets, outputBuffer);
            t2 = RTIMER_NOW();
            total += (t2 - t1);
            nullnet_buf = outputBuffer;
            nullnet_len = packetOutLen;
            NETSTACK_NETWORK.output(NULL);
        }
#ifdef STOP_BY_ACK
        // Keep transmitting packets untill all nodes have decoded the information packets
        while(stopEncoding == false) {
            etimer_reset(&periodic_timer);
            PROCESS_YIELD_UNTIL(etimer_expired(&periodic_timer));
            // Clear outputBuffer
            memset(outputBuffer, 0, packetOutLen);
            t1 = RTIMER_NOW();
            packetOutLen = EncodePackage(packets, outputBuffer);
            t2 = RTIMER_NOW();
            packetCnt++;
            total += (t2 - t1);
            nullnet_buf = outputBuffer;
            nullnet_len = packetOutLen;
            NETSTACK_NETWORK.output(NULL);
        }
#else
        printf("Encoding %i packets: %lums\n", packetCnt, ((unsigned long)total * 1000) / RTIMER_SECOND);
#endif
        total = 0;
    }
    PROCESS_END();
}