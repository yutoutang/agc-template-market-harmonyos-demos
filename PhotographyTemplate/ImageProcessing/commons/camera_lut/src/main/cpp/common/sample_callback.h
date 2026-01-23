#ifndef AVCODEC_SAMPLE_CALLBACK_H
#define AVCODEC_SAMPLE_CALLBACK_H

#include "sample_info.h"

class SampleCallback {
public:
    static void OnCodecError(OH_AVCodec *codec, int32_t errorCode, void *userData);
    static void OnCodecFormatChange(OH_AVCodec *codec, OH_AVFormat *format, void *userData);
    static void OnNeedInputBuffer(OH_AVCodec *codec, uint32_t index, OH_AVBuffer *buffer, void *userData);
    static void OnNewOutputBuffer(OH_AVCodec *codec, uint32_t index, OH_AVBuffer *buffer, void *userData);
};

#endif  // AVCODEC_SAMPLE_CALLBACK_H
