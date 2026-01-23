#ifndef DEMUXER_H
#define DEMUXER_H

#include "multimedia/player_framework/native_avdemuxer.h"
#include "../../common/sample_info.h"
#include "../../common/dfx/error/av_codec_sample_error.h"
#include "../../common/dfx/log/av_codec_sample_log.h"

class Demuxer {
public:
    Demuxer() = default;
    ~Demuxer();
    int32_t Create(SampleInfo &sampleInfo);
    int32_t ReadSample(OH_AVBuffer *buffer, OH_AVCodecBufferAttr &attr);
    int32_t Release();

private:
    int32_t GetVideoTrackInfo(std::shared_ptr<OH_AVFormat> sourceFormat, SampleInfo &info);

    OH_AVSource *source_;
    OH_AVDemuxer *demuxer_;
    int32_t videoTrackId_;
};

#endif  // DEMUXER_H