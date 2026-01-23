#include "include/muxer.h"

#undef LOG_TAG
#define LOG_TAG "Muxer"

Muxer::~Muxer()
{
    Release();
}

int32_t Muxer::Create(int32_t fd)
{
    muxer_ = OH_AVMuxer_Create(fd, AV_OUTPUT_FORMAT_MPEG_4);
    CHECK_AND_RETURN_RET_LOG(muxer_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Muxer create failed, fd: %{public}d", fd);
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Muxer::Config(SampleInfo &sampleInfo)
{
    CHECK_AND_RETURN_RET_LOG(muxer_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Muxer is null");

    OH_AVFormat *formatVideo = OH_AVFormat_CreateVideoFormat(sampleInfo.codecMime.data(),
        sampleInfo.videoWidth, sampleInfo.videoHeight);
    CHECK_AND_RETURN_RET_LOG(formatVideo != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Create video format failed");

    OH_AVFormat_SetDoubleValue(formatVideo, OH_MD_KEY_FRAME_RATE, sampleInfo.frameRate);
    OH_AVFormat_SetIntValue(formatVideo, OH_MD_KEY_WIDTH, sampleInfo.videoWidth);
    OH_AVFormat_SetIntValue(formatVideo, OH_MD_KEY_HEIGHT, sampleInfo.videoHeight);
    OH_AVFormat_SetStringValue(formatVideo, OH_MD_KEY_CODEC_MIME, sampleInfo.codecMime.data());
    if (sampleInfo.isHDRVivid) {
        OH_AVFormat_SetIntValue(formatVideo, OH_MD_KEY_VIDEO_IS_HDR_VIVID, 1);
        OH_AVFormat_SetIntValue(formatVideo, OH_MD_KEY_RANGE_FLAG, 1);
        OH_AVFormat_SetIntValue(formatVideo, OH_MD_KEY_COLOR_PRIMARIES, OH_ColorPrimary::COLOR_PRIMARY_BT2020);
        OH_AVFormat_SetIntValue(formatVideo, OH_MD_KEY_TRANSFER_CHARACTERISTICS,
                                OH_TransferCharacteristic::TRANSFER_CHARACTERISTIC_PQ);
        OH_AVFormat_SetIntValue(formatVideo, OH_MD_KEY_MATRIX_COEFFICIENTS,
                                OH_MatrixCoefficient::MATRIX_COEFFICIENT_BT2020_CL);
    }

    int32_t ret = OH_AVMuxer_AddTrack(muxer_, &videoTrackId_, formatVideo);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "AddTrack failed");
    OH_AVFormat_Destroy(formatVideo);
    OH_AVMuxer_SetRotation(muxer_, 0);
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Muxer::Start()
{
    CHECK_AND_RETURN_RET_LOG(muxer_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Muxer is null");

    int ret = OH_AVMuxer_Start(muxer_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Start failed, ret: %{public}d", ret);
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Muxer::WriteSample(OH_AVBuffer *buffer, OH_AVCodecBufferAttr &attr)
{
    CHECK_AND_RETURN_RET_LOG(muxer_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Muxer is null");
    CHECK_AND_RETURN_RET_LOG(buffer != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Get a empty buffer");

    int32_t ret = OH_AVBuffer_SetBufferAttr(buffer, &attr);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "SetBufferAttr failed");

    ret = OH_AVMuxer_WriteSampleBuffer(muxer_, videoTrackId_, buffer);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Write sample failed");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Muxer::Stop()
{
    CHECK_AND_RETURN_RET_LOG(muxer_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Muxer is null");

    int32_t ret = OH_AVMuxer_Stop(muxer_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Muxer stop failed");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Muxer::Release()
{
    if (muxer_ != nullptr) {
        OH_AVMuxer_Destroy(muxer_);
        muxer_ = nullptr;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

