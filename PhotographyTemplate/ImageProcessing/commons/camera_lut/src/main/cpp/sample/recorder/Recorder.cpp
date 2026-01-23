#include "Recorder.h"
#include "../../common/dfx/log/av_codec_sample_log.h"
#include "dfx/error/av_codec_sample_error.h"

#undef LOG_TAG
#define LOG_TAG "recorder"

namespace {
using namespace std::chrono_literals;
}

Recorder::~Recorder()
{
    StartRelease();
}

int32_t Recorder::Init(SampleInfo &sampleInfo)
{
    std::lock_guard<std::mutex> lock(mutex_);
    CHECK_AND_RETURN_RET_LOG(!isStarted_, AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(videoEncoder_ == nullptr && muxer_ == nullptr, AVCODEC_SAMPLE_ERR_ERROR,
                             "Already started.");

    sampleInfo_ = sampleInfo;

    videoEncoder_ = std::make_unique<VideoEncoder>();
    muxer_ = std::make_unique<Muxer>();

    int32_t ret = videoEncoder_->Create(sampleInfo_.codecMime);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create video encoder failed");
    ret = muxer_->Create(sampleInfo_.outputFd);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create muxer with fd(%{public}d) failed",
                             sampleInfo.outputFd);

    encContext_ = new CodecUserData;
    ret = videoEncoder_->Config(sampleInfo_, encContext_);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Encoder config failed");

    ret = muxer_->Config(sampleInfo_);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Recorder muxer config failed");

    sampleInfo.window = sampleInfo_.window;

    releaseThread_ = nullptr;
    AVCODEC_SAMPLE_LOGI("Succeed");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Recorder::Start()
{
    std::lock_guard<std::mutex> lock(mutex_);
    CHECK_AND_RETURN_RET_LOG(!isStarted_, AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(encContext_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(videoEncoder_ != nullptr && muxer_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR,
                             "Already started.");

    int32_t ret = muxer_->Start();
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Muxer start failed");
    ret = videoEncoder_->Start();
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Encoder start failed");

    isStarted_ = true;
    encOutputThread_ = std::make_unique<std::thread>(&Recorder::EncOutputThread, this);
    if (encOutputThread_ == nullptr) {
        AVCODEC_SAMPLE_LOGE("Create thread failed");
        StartRelease();
        return AVCODEC_SAMPLE_ERR_ERROR;
    }

    AVCODEC_SAMPLE_LOGI("Succeed");
    return AVCODEC_SAMPLE_ERR_OK;
}

void Recorder::EncOutputThread()
{
    while (true) {
        CHECK_AND_BREAK_LOG(isStarted_, "Work done, thread out");
        std::unique_lock<std::mutex> lock(encContext_->outputMutex_);
        bool condRet = encContext_->outputCond_.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !encContext_->outputBufferInfoQueue_.empty(); });
        CHECK_AND_BREAK_LOG(isStarted_, "Work done, thread out");
        CHECK_AND_CONTINUE_LOG(!encContext_->outputBufferInfoQueue_.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = encContext_->outputBufferInfoQueue_.front();
        encContext_->outputBufferInfoQueue_.pop();
        CHECK_AND_BREAK_LOG(!(bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS), "Catch EOS, thread out");
        encContext_->outputFrameCount_++;
        AVCODEC_SAMPLE_LOGD("Out buffer count: %{public}u, size: %{public}d, flag: %{public}u, pts: %{public}" PRId64,
                            encContext_->outputFrameCount_, bufferInfo.attr.size, bufferInfo.attr.flags,
                            bufferInfo.attr.pts);
        lock.unlock();

        bufferInfo.attr.pts = (bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_CODEC_DATA) ?
                                  -1 :
                                  (encContext_->outputFrameCount_ * 1000'000 /
                                   sampleInfo_.frameRate);  // 1000'000: second to micro second

        AVCODEC_SAMPLE_LOGD("Out buffer count: %{public}u, size: %{public}d, flag: %{public}u, pts: %{public}" PRId64,
                            encContext_->outputFrameCount_, bufferInfo.attr.size, bufferInfo.attr.flags,
                            bufferInfo.attr.pts);

        muxer_->WriteSample(reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer), bufferInfo.attr);
        int32_t ret = videoEncoder_->FreeOutputData(bufferInfo.bufferIndex);
        CHECK_AND_BREAK_LOG(ret == AVCODEC_SAMPLE_ERR_OK, "Encoder output thread out");
    }
    AVCODEC_SAMPLE_LOGI("Exit, frame count: %{public}u", encContext_->inputFrameCount_);
    StartRelease();
}

void Recorder::StartRelease()
{
    if (releaseThread_ == nullptr) {
        AVCODEC_SAMPLE_LOGI("Start release CodecTest");
        releaseThread_ = std::make_unique<std::thread>(&Recorder::Release, this);
    }
}

void Recorder::Release()
{
    std::lock_guard<std::mutex> lock(mutex_);
    isStarted_ = false;
    if (encOutputThread_ && encOutputThread_->joinable()) {
        encOutputThread_->join();
        encOutputThread_.reset();
    }
    if (muxer_ != nullptr) {
        muxer_->Release();
        muxer_.reset();
        AVCODEC_SAMPLE_LOGI("Muxer release successful");
    }
    if (videoEncoder_ != nullptr) {
        videoEncoder_->Stop();
        videoEncoder_->Release();
        videoEncoder_.reset();
        AVCODEC_SAMPLE_LOGI("Video encoder release successful");
    }
    if (encContext_ != nullptr) {
        delete encContext_;
        encContext_ = nullptr;
    }
    doneCond_.notify_all();
    AVCODEC_SAMPLE_LOGI("Succeed");
}

int32_t Recorder::WaitForDone()
{
    AVCODEC_SAMPLE_LOGI("Wait called");
    std::unique_lock<std::mutex> lock(mutex_);
    doneCond_.wait(lock);
    if (releaseThread_ && releaseThread_->joinable()) {
        releaseThread_->join();
        releaseThread_.reset();
    }
    AVCODEC_SAMPLE_LOGI("Done");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Recorder::Stop()
{
    if (!isStarted_) {
        return AVCODEC_SAMPLE_ERR_OK;
    }

    int32_t ret = videoEncoder_->NotifyEndOfStream();
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Encoder notifyEndOfStream failed");
    StartRelease();
    return WaitForDone();
}