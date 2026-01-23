#include "Player.h"
#include "../../common/dfx/log/av_codec_sample_log.h"
#include "dfx/error/av_codec_sample_error.h"

#undef LOG_TAG
#define LOG_TAG "player"

namespace {
using namespace std::chrono_literals;
}

Player::~Player()
{
    Player::StartRelease();
}

int32_t Player::Init(SampleInfo &sampleInfo)
{
    std::lock_guard<std::mutex> lock(mutex_);
    CHECK_AND_RETURN_RET_LOG(!isStarted_, AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(demuxer_ == nullptr && videoDecoder_ == nullptr, AVCODEC_SAMPLE_ERR_ERROR,
                             "Already started.");

    sampleInfo_ = sampleInfo;

    videoDecoder_ = std::make_unique<VideoDecoder>();
    demuxer_ = std::make_unique<Demuxer>();

    int32_t ret = demuxer_->Create(sampleInfo_);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create demuxer failed");
    ret = videoDecoder_->Create(sampleInfo_.codecMime);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create video decoder failed");

    decContext_ = new CodecUserData;
//     sampleInfo_.window = NativeXComponentSample::PluginManager::GetInstance()->pluginWindow_;
    ret = videoDecoder_->Config(sampleInfo_, decContext_);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Decoder config failed");

    isReleased_ = false;
    AVCODEC_SAMPLE_LOGI("Succeed");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Player::Start()
{
    std::lock_guard<std::mutex> lock(mutex_);
    CHECK_AND_RETURN_RET_LOG(!isStarted_, AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(decContext_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(demuxer_ != nullptr && videoDecoder_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR,
                             "Already started.");

    int32_t ret = videoDecoder_->Start();
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Decoder start failed");

    isStarted_ = true;
    decInputThread_ = std::make_unique<std::thread>(&Player::DecInputThread, this);
    decOutputThread_ = std::make_unique<std::thread>(&Player::DecOutputThread, this);
    if (decInputThread_ == nullptr || decOutputThread_ == nullptr) {
        AVCODEC_SAMPLE_LOGE("Create thread failed");
        StartRelease();
        return AVCODEC_SAMPLE_ERR_ERROR;
    }

    AVCODEC_SAMPLE_LOGI("Succeed");
    doneCond_.notify_all();
    return AVCODEC_SAMPLE_ERR_OK;
}

void Player::StartRelease()
{
    if (!isReleased_) {
        isReleased_ = true;
        Release();
    }
}

void Player::Release()
{
    std::lock_guard<std::mutex> lock(mutex_);
    isStarted_ = false;
    if (decInputThread_ && decInputThread_->joinable()) {
        decInputThread_->detach();
        decInputThread_.reset();
    }
    if (decOutputThread_ && decOutputThread_->joinable()) {
        decOutputThread_->detach();
        decOutputThread_.reset();
    }
    if (demuxer_ != nullptr) {
        demuxer_->Release();
        demuxer_.reset();
    }
    if (videoDecoder_ != nullptr) {
        videoDecoder_->Release();
        videoDecoder_.reset();
    }
    if (decContext_ != nullptr) {
        delete decContext_;
        decContext_ = nullptr;
    }

    doneCond_.notify_all();
    // 触发回调
    if (sampleInfo_.PlayDoneCallback != nullptr) {
        sampleInfo_.PlayDoneCallback(sampleInfo_.playDoneCallbackData);
    }

    AVCODEC_SAMPLE_LOGI("Succeed");
}

void Player::DecInputThread()
{
    while (true) {
        CHECK_AND_BREAK_LOG(isStarted_, "Decoder input thread out");
        std::unique_lock<std::mutex> lock(decContext_->inputMutex_);
        bool condRet = decContext_->inputCond_.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !decContext_->inputBufferInfoQueue_.empty(); });
        CHECK_AND_BREAK_LOG(isStarted_, "Work done, thread out");
        CHECK_AND_CONTINUE_LOG(!decContext_->inputBufferInfoQueue_.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = decContext_->inputBufferInfoQueue_.front();
        decContext_->inputBufferInfoQueue_.pop();
        decContext_->inputFrameCount_++;
        lock.unlock();

        demuxer_->ReadSample(reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer), bufferInfo.attr);

        int32_t ret = videoDecoder_->PushInputData(bufferInfo);
        CHECK_AND_BREAK_LOG(ret == AVCODEC_SAMPLE_ERR_OK, "Push data failed, thread out");

        CHECK_AND_BREAK_LOG(!(bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS), "Catch EOS, thread out");
    }
    StartRelease();
}

void Player::DecOutputThread()
{
    sampleInfo_.frameInterval = MICROSECOND / sampleInfo_.frameRate;
    while (true) {
        thread_local auto lastPushTime = std::chrono::system_clock::now();
        CHECK_AND_BREAK_LOG(isStarted_, "Decoder output thread out");
        std::unique_lock<std::mutex> lock(decContext_->outputMutex_);
        bool condRet = decContext_->outputCond_.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !decContext_->outputBufferInfoQueue_.empty(); });
        CHECK_AND_BREAK_LOG(isStarted_, "Decoder output thread out");
        CHECK_AND_CONTINUE_LOG(!decContext_->outputBufferInfoQueue_.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = decContext_->outputBufferInfoQueue_.front();
        decContext_->outputBufferInfoQueue_.pop();
        CHECK_AND_BREAK_LOG(!(bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS), "Catch EOS, thread out");
        decContext_->outputFrameCount_++;
        AVCODEC_SAMPLE_LOGW("Out buffer count: %{public}u, size: %{public}d, flag: %{public}u, pts: %{public}" PRId64,
                            decContext_->outputFrameCount_, bufferInfo.attr.size, bufferInfo.attr.flags,
                            bufferInfo.attr.pts);
        lock.unlock();

        int32_t ret = videoDecoder_->FreeOutputData(bufferInfo.bufferIndex, true);
        CHECK_AND_BREAK_LOG(ret == AVCODEC_SAMPLE_ERR_OK, "Decoder output thread out");

        std::this_thread::sleep_until(lastPushTime + std::chrono::microseconds(sampleInfo_.frameInterval));
        lastPushTime = std::chrono::system_clock::now();
    }
    StartRelease();
}
