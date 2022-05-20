#ifndef DECODER_H_
#define DECODER_H_

#include "contiki.h"
#include "project-conf.h"

/* Defines for readability when indexing meta-data */
#define DEGREE 0
#define EDGES 1

/* packets must add their packet number to the edges from which they are encoded *
 * This will ease the work of searching for packet onto which a packet should be *
 * XOR'ed */
typedef struct edgesVector {
    uint16_t size;
    uint8_t edges[KPACKETS];
    uint16_t capacity;
} edgesVector_t;

typedef struct packet {
    uint8_t degree;
    uint8_t edges[KPACKETS];
    uint8_t data[PACKET_LENGTH];
} packet_t;

void initialiseTable(edgesVector_t edgesTable_[KPACKETS]);
void initialiseCodePackets(packet_t codePackets_[4*KPACKETS]);
void initialiseDecodedPackets(uint8_t decodedPackets_[KPACKETS][PACKET_LENGTH], uint8_t decodedPacketsNo_[KPACKETS]);

void addPacketToTable(edgesVector_t edgesTable_[KPACKETS], uint8_t packetNo_, uint8_t edgeNo_);

uint8_t decode(uint8_t decodedPackets_[KPACKETS][PACKET_LENGTH],
               uint8_t decodedPacketsNo_[KPACKETS],
               uint8_t decodedCount_,
               packet_t codePackets_[4*KPACKETS],
               edgesVector_t edgesTable_[KPACKETS],
               uint8_t decodedSymbolNo_);

uint8_t checkTable(uint8_t decodedPackets_[KPACKETS][PACKET_LENGTH],
               uint8_t decodedPacketsNo_[KPACKETS],
               uint8_t decodedCount_,
               packet_t codePackets_[4*KPACKETS],
               edgesVector_t edgesTable_[KPACKETS]);

int storePacket(uint8_t decodedPackets_[KPACKETS][PACKET_LENGTH],
                uint8_t decodedPacketsNo_[KPACKETS],
                uint8_t decodedCount_,
                packet_t codePackets_[4*KPACKETS],
                edgesVector_t edgesTable_[KPACKETS],
                const uint8_t* data_,
                uint8_t codeSymbolNo_);

extern void XORPackets(uint8_t packetIn[PACKET_LENGTH], uint8_t packetOut[PACKET_LENGTH]);

#endif /* DECODER_H_ */