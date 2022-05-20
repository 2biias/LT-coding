#include "contiki.h"
#include "net/netstack.h"
#include "net/nullnet/nullnet.h"
#include "dev/button-sensor.h"
#include "lib/sensors.h"
#include <string.h>
#include <stdio.h>
#include "decoder.h"
#include "sys/rtimer.h"

// Log configuration
#include "sys/log.h"
#define LOG_MODULE "App"
#define LOG_LEVEL LOG_LEVEL_INFO

/*---------------------------------------------------------------------------*/
PROCESS(main_process, "Main process");
AUTOSTART_PROCESSES(&main_process);
/*---------------------------------------------------------------------------*/

const linkaddr_t broadcast_addr = {{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }};

/* edgesTable maps: decoded packet num -> vector of code symbols with edge to that packet num. */
static edgesVector_t edgesTable[KPACKETS];
static packet_t codePackets[4*KPACKETS]; /* We need to buffer coded packets somewhere. Assume < 4K. */
static uint8_t decodedPackets[KPACKETS][PACKET_LENGTH];
static uint8_t decodedPacketsNo[KPACKETS];
static uint8_t codePacketsCount = 0;
static uint8_t decodedCount = 0;
static int receivedPackets = 0;
rtimer_clock_t t1, t2, total;

#ifdef STOP_BY_ACK
static uint8_t ackBuffer[1];
static uint8_t ackReceived = 0;
#endif

static void resetDecoder() {
    initialiseTable(edgesTable);
    initialiseCodePackets(codePackets);
    initialiseDecodedPackets(decodedPackets, decodedPacketsNo);
    codePacketsCount = 0;
    decodedCount = 0;
    receivedPackets = 0;
}

void input_callback(const void *data, uint16_t len, const linkaddr_t *src, const linkaddr_t *dest)
{ 
    /* Incoming packets: [degree, xor1, xor2, ... xorN, data1, data2, data3, data4] */
    if(linkaddr_cmp(dest, &broadcast_addr) && len > 5) {
        if(decodedCount < KPACKETS) {
            receivedPackets++;
            t1 = RTIMER_NOW();
            // If we find degree 1 we start decoding, otherwise the code symbol is just stored 
            int foundPacket = storePacket(decodedPackets, decodedPacketsNo, decodedCount, codePackets, edgesTable, (const uint8_t*)data, codePacketsCount);
            if(foundPacket == -1) {
                // If degree > 1 we check if any code symbols can be reduced
                codePacketsCount++;
                decodedCount = checkTable(decodedPackets, decodedPacketsNo, decodedCount, codePackets, edgesTable);
            } else if(foundPacket != -2) {
                decodedPacketsNo[decodedCount] = foundPacket;
                decodedCount++;
                decodedCount = decode(decodedPackets, decodedPacketsNo, decodedCount, codePackets, edgesTable, foundPacket);
            }
           t2 = RTIMER_NOW();
           total += (t2 - t1);
        }
        if(decodedCount >= KPACKETS) {
#ifdef STOP_BY_ACK
            if(!ackReceived) {
                // All packets are decoded. Send ack to gateway
                ackBuffer[0] = 0xff;
                nullnet_buf = ackBuffer;
                nullnet_len = 1;
                printf("node sending ack to %d, %d\n", src->u8[0], src->u8[1]);
                NETSTACK_NETWORK.output(src);
            }
#else        
            printf("Decoding %i packets: %lums total.\n", receivedPackets, ((unsigned long)total * 1000) / RTIMER_SECOND);
            total = 0;
            resetDecoder();
#endif
        }
    } else {
#ifdef STOP_BY_ACK
        if(((uint8_t*)data)[0] == linkaddr_node_addr.u8[0] && !ackReceived) {
            ackReceived = 1;
            printf("Decoding %i packets: %lums total.\n", receivedPackets, ((unsigned long)total * 1000) / RTIMER_SECOND);
            total = 0;
        }
#endif
    }
}

/*---------------------------------------------------------------------------*/
PROCESS_THREAD(main_process, ev, data)
{
    SENSORS_ACTIVATE(button_sensor);
    PROCESS_BEGIN();
    // Watchdog is disabled
    watchdog_stop();
    
    /* Initialise packets */
    initialiseTable(edgesTable);
    initialiseCodePackets(codePackets);
    initialiseDecodedPackets(decodedPackets, decodedPacketsNo);

    // Initialize NullNet
    nullnet_set_input_callback(input_callback);

    // Yield the process for ever.
    while(1) {
        PROCESS_WAIT_EVENT_UNTIL(ev == sensors_event && data == &button_sensor);
        // Reset everything to initial state
        resetDecoder();
#ifdef STOP_BY_ACK
        ackReceived = 0;
#endif
    }
    PROCESS_END();
}