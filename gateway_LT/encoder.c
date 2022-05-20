#include "encoder.h"
#include "distributions.h"
#include "stdio.h"
#include "sys/rtimer.h"
#ifdef SIMULATED
#include "lib/random.h"
#endif

uint8_t EncodePackage(uint8_t packets_[KPACKETS][PACKET_LENGTH], uint8_t outputBuffer[MAX_HEADER_LENGTH+PACKET_LENGTH]) {
    uint8_t degree = ChooseDegreee();
    uint8_t packetToXOR;
    uint8_t uniquePacket = 0;
    outputBuffer[0] = degree;
    
    /* XOR degree packets together */
    for(uint8_t i = 0; i < degree; ++i) {
        if(i == 0) {
            packetToXOR = NeumannExtractor(KNBITS);
            outputBuffer[1] = packetToXOR;
        } else {
            // Ensure same package is not used >1
            while(!uniquePacket) {
                // We assume packet to be unique 
                uniquePacket = 1;
                packetToXOR = NeumannExtractor(KNBITS);
                for(uint8_t j = 0; j < i; j++) {
                    // We try to find a counter example for our assumption
                    if(outputBuffer[1+j] == packetToXOR) {
                        uniquePacket = 0;
                    }
                }
            }
            outputBuffer[1+i] = packetToXOR;
            uniquePacket = 0;
        }
        XORPackets(&packets_[packetToXOR][0], &outputBuffer[1+degree]);
    }
    return 1+degree+PACKET_LENGTH;
}

inline void XORPackets(uint8_t packetIn[PACKET_LENGTH], uint8_t packetOut[PACKET_LENGTH]) {
    for(uint8_t i = 0; i < PACKET_LENGTH; ++i) {
        packetOut[i] ^= packetIn[i];
    } 
}

uint16_t ChooseDegreee() {
    /* Determine uniformly distributed U using QUANTISE_N bits */
    uint16_t U = NeumannExtractor(QUANTISE_N);
    /* Inverse transform sampling using soliton CDF */
    for(uint8_t d = 0; d < KPACKETS; d++) {
        if(U > CDF_quantised[d])
            continue;
        else
            return d+1;
    }
    return 1;
}

/* Function for generating number with U ~ [0, 2^n - 1] */
uint16_t NeumannExtractor(uint16_t n) {
    uint16_t output = 0;
    #ifdef SIMULATED
    output = random_rand() >> (16-n);
    #else
    uint16_t cnt = 0;
    uint16_t input;
    /* Extract n uniformly distributed bits as a Bernoulli process */
    while(cnt < n) {
        input = ADCSingle();
        if((input & 0x01) != (ADCSingle() & 0x01)) {
            output |= (input & 0x01) << cnt;
            cnt++;
        }
    }
    #endif
    return output;
}

uint16_t ADCSingle() {
    /* Disable conversion */     
    ADC12CTL0 &= ~ENC;
    /* wait for conversion to stop */
    while (ADC12CTL1 & ADC12BUSY);
    /* Set up the ADC. */
    ADC12CTL0 = ADC12ON; // + SHT0_0
    ADC12CTL1 = CONSEQ_0 + CSTARTADD_0 + SHP + ADC12SSEL_1;    
    /* Enable conversion and start conversion */
    ADC12CTL0 |= ENC;
    ADC12CTL0 |= ADC12SC;
    while (ADC12CTL1 & ADC12BUSY);
    return ADC12MEM0;
}