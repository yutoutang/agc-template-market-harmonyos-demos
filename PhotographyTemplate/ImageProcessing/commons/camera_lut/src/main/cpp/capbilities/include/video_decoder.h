#ifndef VIDEODECODER_H
#define VIDEODECODER_H

#include "multimedia/player_framework/native_avcodec_videodecoder.h"
#include "multimedia/player_framework/native_avbuffer_info.h"
#include "../../common/sample_info.h"
#include "../../common/sample_callback.h"
#include "dfx/error/av_codec_sample_error.h"
#include "av_codec_sample_log.h"

class VideoDecoder {
public:
    VideoDecoder() = default;
    ~VideoDecoder();

    int32_t Create(const std::string &codecMime);
    int32_t Config(const SampleInfo &sampleInfo, CodecUserData *codecUserData);
    int32_t Start();
    int32_t PushInputData(CodecBufferInfo &info);
    int32_t FreeOutputData(uint32_t bufferIndex, bool render);
    int32_t Release();

private:
    int32_t SetCallback(CodecUserData *codecUserData);
    int32_t Configure(const SampleInfo &sampleInfo);

    bool isAVBufferMode_ = false;
    OH_AVCodec *decoder_;
};
#endif  // VIDEODECODER_H