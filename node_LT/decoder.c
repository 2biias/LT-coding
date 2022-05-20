#include "decoder.h"
#include "stdlib.h"
#include <stdio.h>

void initialiseTable(edgesVector_t edgesTable_[KPACKETS]) {
    for(uint8_t entry = 0; entry < KPACKETS; ++entry) {
        edgesTable_[entry].size = 0;
        edgesTable_[entry].capacity = KPACKETS;
        for(uint8_t slot = 0; slot < edgesTable_[entry].capacity; slot++) {
            edgesTable_[entry].edges[slot] = 0;
        }
    }
}

void initialiseCodePackets(packet_t* codePackets_) {
    for(uint16_t i = 0; i < 4*KPACKETS; ++i) {
        codePackets_[i].degree = 0;
        for(uint8_t edge = 0; edge < KPACKETS; edge++)
            codePackets_[i].edges[edge] = 0;
        for(uint8_t j = 0; j < PACKET_LENGTH; ++j)
            codePackets_[i].data[j] = 0;
    }
}

void initialiseDecodedPackets(uint8_t decodedPackets_[KPACKETS][PACKET_LENGTH],
                              uint8_t decodedPacketsNo_[KPACKETS])
{
    for(uint8_t i = 0; i < KPACKETS; i++) {
        decodedPacketsNo_[i] = 0;
        for(uint8_t j = 0; j < PACKET_LENGTH; j++)
            decodedPackets_[i][j] = 0;
    }
}

void addPacketToTable(edgesVector_t edgesTable_[KPACKETS], uint8_t codeSymbolNo_, uint8_t edgeNo_) {
    if(edgesTable_[edgeNo_].size == edgesTable_[edgeNo_].capacity) {
        printf("Fatal error: edgetable entry %i reached KPACKETS slots. Expect bad behavior.\n", edgeNo_);
    }
    edgesTable_[edgeNo_].edges[edgesTable_[edgeNo_].size] = codeSymbolNo_;
    edgesTable_[edgeNo_].size += 1;
}

uint8_t decode(uint8_t decodedPackets_[KPACKETS][PACKET_LENGTH],
               uint8_t decodedPacketsNo_[KPACKETS],
               uint8_t decodedCount_,
               packet_t codePackets_[4*KPACKETS],
               edgesVector_t edgesTable_[KPACKETS],
               uint8_t decodedSymbolNo_)
{
    // Are there some code symbols that needs to be XOR'ed with information symbol decodedSymbolNo_
    if(edgesTable_[decodedSymbolNo_].size > 0) {
        // For each of those code symbols
        for(uint8_t i = 0; i < edgesTable_[decodedSymbolNo_].size; ++i) {
            // XOR packet with all packets that depend on that (has edges to it)
            XORPackets(decodedPackets_[decodedSymbolNo_], codePackets_[edgesTable_[decodedSymbolNo_].edges[i]].data);
            
            // Now we want to remove that edge from the code symbol
            for(uint8_t j = 0; j < codePackets_[edgesTable_[decodedSymbolNo_].edges[i]].degree; j++) {
                if(codePackets_[edgesTable_[decodedSymbolNo_].edges[i]].edges[j] == decodedSymbolNo_) {
                    codePackets_[edgesTable_[decodedSymbolNo_].edges[i]].edges[j] = codePackets_[edgesTable_[decodedSymbolNo_].edges[i]].edges[codePackets_[edgesTable_[decodedSymbolNo_].edges[i]].degree-1];
                    codePackets_[edgesTable_[decodedSymbolNo_].edges[i]].degree -= 1;
                }
            }
        }
        for(uint8_t i = 0; i < edgesTable_[decodedSymbolNo_].size; i++) {
            // If decoded return the number
            uint8_t unique = 1;
            if(codePackets_[edgesTable_[decodedSymbolNo_].edges[i]].degree == 1) {
                // Deduce decoded package number
                uint8_t decodedSymbolNoNew_ = codePackets_[edgesTable_[decodedSymbolNo_].edges[i]].edges[0];
                // We'll have to guarantee that no same package is labeled as decoded
                for(uint8_t j = 0; j < decodedCount_; j++) {
                    if(decodedPacketsNo_[j] == decodedSymbolNoNew_) {
                        unique = 0;
                        break;
                    }
                }
                if(unique) {
                    decodedPacketsNo_[decodedCount_] = decodedSymbolNoNew_;
                    // Add decoded package to decoded package buffer
                    for(uint8_t j = 0; j < PACKET_LENGTH; ++j) {
                        decodedPackets_[decodedSymbolNoNew_][j] = codePackets_[edgesTable_[decodedSymbolNo_].edges[i]].data[j];
                    }
                    decodedCount_++;
                }
                // Release edgetable index decodedSymbolNoNew_ so that it won't decode it self...
                for(uint8_t k = 0; k < edgesTable_[decodedSymbolNoNew_].size; k++) {
                    if(edgesTable_[decodedSymbolNoNew_].edges[k] == edgesTable_[decodedSymbolNo_].edges[i]) {
                        edgesTable_[decodedSymbolNoNew_].edges[k] = edgesTable_[decodedSymbolNoNew_].edges[edgesTable_[decodedSymbolNoNew_].size-1];
                        edgesTable_[decodedSymbolNoNew_].size--;
                    }
                }
            }
        }
        // All code symbols in edgesTable_[decodedSymbolNo_] must be removed after this process
        edgesTable_[decodedSymbolNo_].size = 0;
    }
    return decodedCount_;
}

uint8_t checkTable(uint8_t decodedPackets_[KPACKETS][PACKET_LENGTH],
               uint8_t decodedPacketsNo_[KPACKETS],
               uint8_t decodedCount_,
               packet_t codePackets_[4*KPACKETS],
               edgesVector_t edgesTable_[4*KPACKETS])
{
    uint8_t decodedCountOld = decodedCount_;
    /* Check if any packets depends on the already decoded packets (degree 1) */
    for(uint8_t i = 0; i < decodedCountOld; i++) {
        if(edgesTable_[decodedPacketsNo_[i]].size != 0) {
            decodedCount_ = decode(decodedPackets_, decodedPacketsNo_, decodedCount_, codePackets_, edgesTable_, decodedPacketsNo_[i]);
            if(decodedCount_ > KPACKETS)
                break;
        }
    }
    return decodedCount_;
}

/* Stores the data in packet and adds dependencies to edgesTable */
int storePacket(uint8_t decodedPackets_[KPACKETS][PACKET_LENGTH],
                uint8_t decodedPacketsNo_[KPACKETS],
                uint8_t decodedCount_,
                packet_t codePackets_[4*KPACKETS],
                edgesVector_t edgesTable_[KPACKETS],
                const uint8_t* data_,
                uint8_t codeSymbolNo_)
{
    const uint8_t degree = data_[DEGREE];
    if(degree == 1) {
        // Store as decoded (but only if it is not already there)
        uint8_t packetNo = data_[EDGES];
        for(uint8_t i = 0; i < decodedCount_; i++) {
            if(decodedPacketsNo_[i] == packetNo) {
                return -2;
            }
        }
        for(uint8_t i = 0; i < PACKET_LENGTH; ++i) {
            decodedPackets_[packetNo][i] = data_[2+i];
        }
        return packetNo;
    } else {
         /* Store the codePacket into codePacket buffer */
        codePackets_[codeSymbolNo_].degree = degree;
        for(uint8_t i = 0; i < degree; ++i) {
            addPacketToTable(edgesTable_, codeSymbolNo_, data_[EDGES+i]);
            codePackets_[codeSymbolNo_].edges[i] = data_[EDGES+i];
        }
        for(uint8_t i = 0; i < PACKET_LENGTH; ++i) {
            codePackets_[codeSymbolNo_].data[i] = data_[EDGES+degree+i];
        }
    }
    return -1;
}

inline void XORPackets(uint8_t packetIn_[PACKET_LENGTH], uint8_t packetOut_[PACKET_LENGTH]) {
    for(uint8_t i = 0; i < PACKET_LENGTH; ++i) {
        packetOut_[i] ^= packetIn_[i];
    } 
}