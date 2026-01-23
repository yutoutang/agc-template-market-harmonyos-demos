#ifndef MUXER_H
#define MUXER_H

#include "multimedia/player_framework/native_avmuxer.h"
#include "../../common/sample_info.h"
#include "../../common/dfx/error/av_codec_sample_error.h"
#include "../../common/dfx/log/av_codec_sample_log.h"

class Muxer {
public:
    Muxer() = default;
    ~Muxer();

    int32_t Create(int32_t fd);
    int32_t Config(SampleInfo &sampleInfo);
    int32_t Start();
    int32_t WriteSample(OH_AVBuffer *buffer, OH_AVCodecBufferAttr &attr);
    int32_t Stop();
    int32_t Release();

private:
    OH_AVMuxer *muxer_ = nullptr;
    int32_t videoTrackId_ = -1;
};

#endif  // MUXER_H