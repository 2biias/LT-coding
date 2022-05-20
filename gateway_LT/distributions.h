#ifndef DISTRIBUTIONS_H_
#define DISTRIBUTIONS_H_

#include "contiki.h"
#include "project-conf.h"

#ifdef DIST_O_IDEAL
#define QUANTISE_N 8
const uint16_t CDF_quantised[KPACKETS] = {15,143,186,207,220,228,234,239,
                                          243,245,248,250,251,253,254,255};
#elif DIST_O_1
#define QUANTISE_N 9
const uint16_t CDF_quantised[KPACKETS] = {71,289,369,414,443,464,480,487,
                                          492,497,500,503,505,508,509,511};

#elif DIST_O_2
#define QUANTISE_N 9
const uint16_t CDF_quantised[KPACKETS] = {60,243,311,348,373,390,404,491,
                                          495,499,502,504,506,508,510,511};
#endif

#endif