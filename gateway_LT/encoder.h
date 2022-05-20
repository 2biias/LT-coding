#ifndef ENCODER_H_
#define ENCODER_H_

#include "contiki.h"
#include "lib/sensors.h"
#include "project-conf.h"

uint8_t EncodePackage(uint8_t packets[KPACKETS][PACKET_LENGTH], uint8_t outputBuffer[MAX_HEADER_LENGTH+PACKET_LENGTH]);
extern void XORPackets(uint8_t packetIn[PACKET_LENGTH], uint8_t packetOut[PACKET_LENGTH]);
uint16_t ChooseSymbols(uint16_t amount);
uint16_t ChooseDegreee();
uint16_t NeumannExtractor(uint16_t bits);
uint16_t ADCSingle();

#endif /* ENCODER_H_ */