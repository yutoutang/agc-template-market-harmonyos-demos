#ifndef VIDEOENCODER_H
#define VIDEOENCODER_H

#include "multimedia/player_framework/native_avcodec_videoencoder.h"
#include "multimedia/player_framework/native_avbuffer_info.h"
#include "../../common/sample_info.h"
#include "native_window/external_window.h"
#include "native_window/buffer_handle.h"
#include "../../common/sample_callback.h"
#include "dfx/error/av_codec_sample_error.h"
#include "av_codec_sample_log.h"

class VideoEncoder {
public:
    VideoEncoder() = default;
    ~VideoEncoder();

    int32_t Create(const std::string &codecMime);
    int32_t Config(SampleInfo &sampleInfo, CodecUserData *codecUserData);
    int32_t Start();
    int32_t PushInputData(CodecBufferInfo &info);
    int32_t FreeOutputData(uint32_t bufferIndex);
    int32_t NotifyEndOfStream();
    int32_t Stop();
    int32_t Release();

private:
    int32_t SetCallback(CodecUserData *codecUserData);
    int32_t Configure(const SampleInfo &sampleInfo);
    int32_t GetSurface(SampleInfo &sampleInfo);
    bool isAVBufferMode_ = false;
    OH_AVCodec *encoder_ = nullptr;
};
#endif  // VIDEOENCODER_H