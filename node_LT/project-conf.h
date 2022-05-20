#ifndef PROJECT_CONF_H_
#define PROJECT_CONF_H_

/* Configuration */
//#define ENERGEST_CONF_ON 1
#define KNBITS 4
#define KPACKETS 16
#define NPACKETS 0 /* Overhead */
#define PACKET_LENGTH 4
#define MAX_HEADER_LENGTH (2+KPACKETS)
#define MAX_PACKET_LENGTH (PACKET_LENGTH+MAX_HEADER_LENGTH)
#define STOP_BY_ACK 1

#endif /* PROJECT_CONF_H_ */