#ifndef PROJECT_CONF_H_
#define PROJECT_CONF_H_


/* Configuration */
#define SEND_INTERVAL (0.3 * CLOCK_SECOND)
//#define ENERGEST_CONF_ON 1
#define DIST_O_1 1
#define KNBITS 4
#define KPACKETS 16 /* Information symbols to be transmitted */
#define NPACKETS 0 /* Overhead */
#define SIMULATED 1
#define PACKET_LENGTH 4
#define MAX_HEADER_LENGTH (2+KPACKETS)
#define OUT_PACKET_LENGTH (PACKET_LENGTH+MAX_HEADER_LENGTH)
#define NUMBER_OF_NODES 32
// Stop by ack enables a mechanism for automatically stopping the gateway in transmitting
// code symbols when all nodes have successfully decoded their code symbols and acked.
// This feature is not included in the energy calculations for now.
#define STOP_BY_ACK 1

#endif /* PROJECT_CONF_H_ */