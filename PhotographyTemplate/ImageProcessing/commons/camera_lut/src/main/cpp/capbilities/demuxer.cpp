#include "include/demuxer.h"

#undef LOG_TAG
#define LOG_TAG "Demuxer"

Demuxer::~Demuxer()
{
    Release();
}

int32_t Demuxer::Create(SampleInfo &info)
{
    source_ = OH_AVSource_CreateWithFD(info.inputFd, info.inputFileOffset, info.inputFileSize);
    CHECK_AND_RETURN_RET_LOG(source_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR,
        "Create demuxer source failed, fd: %{public}d, offset: %{public}" PRId64 ", file size: %{public}" PRId64,
        info.inputFd, info.inputFileOffset, info.inputFileSize);
    demuxer_ = OH_AVDemuxer_CreateWithSource(source_);
    CHECK_AND_RETURN_RET_LOG(demuxer_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Create demuxer failed");

    auto sourceFormat = std::shared_ptr<OH_AVFormat>(OH_AVSource_GetSourceFormat(source_), OH_AVFormat_Destroy);
    CHECK_AND_RETURN_RET_LOG(sourceFormat != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Get source format failed");

    int32_t ret = GetVideoTrackInfo(sourceFormat, info);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Get video track info failed");

    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Demuxer::ReadSample(OH_AVBuffer *buffer, OH_AVCodecBufferAttr &attr)
{
    CHECK_AND_RETURN_RET_LOG(demuxer_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Demuxer is null");
    int32_t ret = OH_AVDemuxer_ReadSampleBuffer(demuxer_, videoTrackId_, buffer);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Read sample failed");
    ret = OH_AVBuffer_GetBufferAttr(buffer, &attr);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "GetBufferAttr failed");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Demuxer::Release()
{
    if (demuxer_ != nullptr) {
        OH_AVDemuxer_Destroy(demuxer_);
        demuxer_ = nullptr;
    }
    if (source_ != nullptr) {
        OH_AVSource_Destroy(source_);
        source_ = nullptr;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Demuxer::GetVideoTrackInfo(std::shared_ptr<OH_AVFormat> sourceFormat, SampleInfo &info)
{
    int32_t trackCount = 0;
    OH_AVFormat_GetIntValue(sourceFormat.get(), OH_MD_KEY_TRACK_COUNT, &trackCount);
    for (int32_t index = 0; index < trackCount; index++) {
        int trackType = -1;
        auto trackFormat =
            std::shared_ptr<OH_AVFormat>(OH_AVSource_GetTrackFormat(source_, index), OH_AVFormat_Destroy);
        OH_AVFormat_GetIntValue(trackFormat.get(), OH_MD_KEY_TRACK_TYPE, &trackType);
        if (trackType == MEDIA_TYPE_VID) {
            OH_AVDemuxer_SelectTrackByID(demuxer_, index);
            OH_AVFormat_GetIntValue(trackFormat.get(), OH_MD_KEY_WIDTH, &info.videoWidth);
            OH_AVFormat_GetIntValue(trackFormat.get(), OH_MD_KEY_HEIGHT, &info.videoHeight);
            OH_AVFormat_GetDoubleValue(trackFormat.get(), OH_MD_KEY_FRAME_RATE, &info.frameRate);
            OH_AVFormat_GetLongValue(trackFormat.get(), OH_MD_KEY_BITRATE, &info.bitrate);
            OH_AVFormat_GetIntValue(trackFormat.get(), OH_MD_KEY_VIDEO_IS_HDR_VIVID, &info.isHDRVivid);
            OH_AVFormat_GetIntValue(trackFormat.get(), OH_MD_KEY_ROTATION, &info.rotation);
            char *codecMime;
            OH_AVFormat_GetStringValue(trackFormat.get(), OH_MD_KEY_CODEC_MIME, const_cast<char const **>(&codecMime));
            info.codecMime = codecMime;
            OH_AVFormat_GetIntValue(trackFormat.get(), OH_MD_KEY_PROFILE, &info.hevcProfile);
            videoTrackId_ = index;

            AVCODEC_SAMPLE_LOGI("====== Demuxer config ======");
            AVCODEC_SAMPLE_LOGI("Mime: %{public}s", codecMime);
            AVCODEC_SAMPLE_LOGI("%{public}d*%{public}d, %{public}.1ffps, %{public}" PRId64 "kbps", info.videoWidth,
                                info.videoHeight, info.frameRate, info.bitrate / 1024);
            AVCODEC_SAMPLE_LOGI("====== Demuxer config ======");
        }
    }

    return AVCODEC_SAMPLE_ERR_OK;
}
