#ifndef VIDEO_CODEC_SAMPLE_RECODER_H
#define VIDEO_CODEC_SAMPLE_RECODER_H

#include <mutex>
#include <memory>
#include <atomic>
#include <thread>
#include "../../capbilities/include/video_encoder.h"
#include "../../capbilities/include/muxer.h"
#include "../../common/sample_info.h"

class Recorder {
public:
    Recorder(){};
    ~Recorder();

    static Recorder &GetInstance()
    {
        static Recorder recorder;
        return recorder;
    }

    int32_t Init(SampleInfo &sampleInfo);
    int32_t Start();
    int32_t Stop();

private:
    void EncOutputThread();
    void Release();
    void StartRelease();
    int32_t WaitForDone();

    std::unique_ptr<VideoEncoder> videoEncoder_ = nullptr;
    std::unique_ptr<Muxer> muxer_ = nullptr;

    std::mutex mutex_;
    std::atomic<bool> isStarted_{ false };
    std::unique_ptr<std::thread> encOutputThread_ = nullptr;
    std::unique_ptr<std::thread> releaseThread_ = nullptr;
    std::condition_variable doneCond_;
    SampleInfo sampleInfo_;
    CodecUserData *encContext_ = nullptr;
};

#endif  // VIDEO_CODEC_SAMPLE_RECODER_H
