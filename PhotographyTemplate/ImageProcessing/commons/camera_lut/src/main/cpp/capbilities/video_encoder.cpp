#include "include/video_encoder.h"

#undef LOG_TAG
#define LOG_TAG "VideoEncoder"

namespace {
constexpr int GRAPHIC_PIXEL_FMT_RGBA_8888 = 12;
constexpr int LIMIT_LOGD_FREQUENCY = 50;

int32_t ToGraphicPixelFormat(int32_t avPixelFormat, bool isHDRVivid)
{
    //    if (isHDRVivid) {
    //        return GRAPHIC_PIXEL_FMT_YCBCR_P010;
    //    }
    //    switch (avPixelFormat) {
    //    case AV_PIXEL_FORMAT_RGBA:
    //        return GRAPHIC_PIXEL_FMT_RGBA_8888;
    //    case AV_PIXEL_FORMAT_YUVI420:
    //        return GRAPHIC_PIXEL_FMT_YCBCR_420_P;
    //    case AV_PIXEL_FORMAT_NV21:
    //        return GRAPHIC_PIXEL_FMT_YCRCB_420_SP;
    //    default: // NV12 and others
    //        return GRAPHIC_PIXEL_FMT_YCBCR_420_SP;
    //    }
    return 24;
}
}  // namespace

VideoEncoder::~VideoEncoder()
{
    Release();
}

int32_t VideoEncoder::Create(const std::string &codecMime)
{
    encoder_ = OH_VideoEncoder_CreateByMime(codecMime.c_str());
    CHECK_AND_RETURN_RET_LOG(encoder_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Create failed");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t VideoEncoder::Config(SampleInfo &sampleInfo, CodecUserData *codecUserData)
{
    CHECK_AND_RETURN_RET_LOG(encoder_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Encoder is null");
    CHECK_AND_RETURN_RET_LOG(codecUserData != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Invalid param: codecUserData");

    // Configure video encoder
    int32_t ret = Configure(sampleInfo);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Configure failed");

    // GetSurface from video encoder
    ret = GetSurface(sampleInfo);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Get surface failed");

    // SetCallback for video encoder
    ret = SetCallback(codecUserData);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR,
                             "Set callback failed, ret: %{public}d", ret);

    // Prepare video encoder
    ret = OH_VideoEncoder_Prepare(encoder_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Prepare failed, ret: %{public}d", ret);

    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t VideoEncoder::Start()
{
    CHECK_AND_RETURN_RET_LOG(encoder_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Encoder is null");

    int ret = OH_VideoEncoder_Start(encoder_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Start failed, ret: %{public}d", ret);
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t VideoEncoder::PushInputData(CodecBufferInfo &info)
{
    CHECK_AND_RETURN_RET_LOG(encoder_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Decoder is null");

    int32_t ret = OH_AVBuffer_SetBufferAttr(reinterpret_cast<OH_AVBuffer *>(info.buffer), &info.attr);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Set avbuffer attr failed");
    ret = OH_VideoEncoder_PushInputBuffer(encoder_, info.bufferIndex);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Push input data failed");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t VideoEncoder::FreeOutputData(uint32_t bufferIndex)
{
    CHECK_AND_RETURN_RET_LOG(encoder_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Encoder is null");

    int32_t ret = OH_VideoEncoder_FreeOutputBuffer(encoder_, bufferIndex);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Free output data failed, ret: %{public}d",
                             ret);
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t VideoEncoder::NotifyEndOfStream()
{
    CHECK_AND_RETURN_RET_LOG(encoder_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Encoder is null");

    int32_t ret = OH_VideoEncoder_NotifyEndOfStream(encoder_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Notify end of stream failed, ret: %{public}d",
                             ret);
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t VideoEncoder::Stop()
{
    CHECK_AND_RETURN_RET_LOG(encoder_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Encoder is null");

    int ret = OH_VideoEncoder_Flush(encoder_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Flush failed, ret: %{public}d", ret);

    ret = OH_VideoEncoder_Stop(encoder_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Stop failed, ret: %{public}d", ret);
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t VideoEncoder::Release()
{
    if (encoder_ != nullptr) {
        OH_VideoEncoder_Destroy(encoder_);
        encoder_ = nullptr;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t VideoEncoder::SetCallback(CodecUserData *codecUserData)
{
    int32_t ret =
        OH_VideoEncoder_RegisterCallback(encoder_,
                                         { SampleCallback::OnCodecError, SampleCallback::OnCodecFormatChange,
                                           SampleCallback::OnNeedInputBuffer, SampleCallback::OnNewOutputBuffer },
                                         codecUserData);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Set callback failed, ret: %{public}d", ret);

    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t VideoEncoder::Configure(const SampleInfo &sampleInfo)
{
    OH_AVFormat *format = OH_AVFormat_Create();
    CHECK_AND_RETURN_RET_LOG(format != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "AVFormat create failed");

    OH_AVFormat_SetIntValue(format, OH_MD_KEY_WIDTH, sampleInfo.videoWidth);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_HEIGHT, sampleInfo.videoHeight);
    OH_AVFormat_SetDoubleValue(format, OH_MD_KEY_FRAME_RATE, sampleInfo.frameRate);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_PIXEL_FORMAT, sampleInfo.pixelFormat);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_VIDEO_ENCODE_BITRATE_MODE, CBR);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_BITRATE, sampleInfo.bitrate);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_PROFILE, sampleInfo.hevcProfile);
    if (sampleInfo.isHDRVivid) {
        OH_AVFormat_SetIntValue(format, OH_MD_KEY_I_FRAME_INTERVAL, 100);  // 100: I_FRAME_INTERVAL
    }
    AVCODEC_SAMPLE_LOGI("====== VideoEncoder config ======");
    AVCODEC_SAMPLE_LOGI("%{public}d*%{public}d, %{public}.1ffps", sampleInfo.videoWidth, sampleInfo.videoHeight,
                        sampleInfo.frameRate);
    // 1024: ratio of kbps to bps
    AVCODEC_SAMPLE_LOGI("BitRate Mode: %{public}d, BitRate: %{public}" PRId64 "kbps", VBR, sampleInfo.bitrate / 1024);
    AVCODEC_SAMPLE_LOGI("====== VideoEncoder config ======");

    int ret = OH_VideoEncoder_Configure(encoder_, format);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Config failed, ret: %{public}d", ret);
    OH_AVFormat_Destroy(format);
    format = nullptr;
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t VideoEncoder::GetSurface(SampleInfo &sampleInfo)
{
    int32_t ret = OH_VideoEncoder_GetSurface(encoder_, &sampleInfo.window);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK && sampleInfo.window, AVCODEC_SAMPLE_ERR_ERROR,
                             "Get surface failed, ret: %{public}d", ret);
    (void)OH_NativeWindow_NativeWindowHandleOpt(sampleInfo.window, SET_BUFFER_GEOMETRY, sampleInfo.videoWidth,
                                                sampleInfo.videoHeight);
    (void)OH_NativeWindow_NativeWindowHandleOpt(sampleInfo.window, SET_USAGE, 16425);  // 16425: Window usage
    //     (void)OH_NativeWindow_NativeWindowHandleOpt(sampleInfo.window, SET_FORMAT,
    //         ToGraphicPixelFormat(sampleInfo.pixelFormat, sampleInfo.isHDRVivid));
    return AVCODEC_SAMPLE_ERR_OK;
}