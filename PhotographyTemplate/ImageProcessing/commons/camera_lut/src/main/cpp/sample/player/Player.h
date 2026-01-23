#ifndef VIDEO_CODEC_PLAYER_H
#define VIDEO_CODEC_PLAYER_H

#include <mutex>
#include <memory>
#include <atomic>
#include <thread>
#include "../../capbilities/include/video_decoder.h"
#include "demuxer.h"
#include "sample_info.h"

class Player {
public:
    Player(){};
    ~Player();

    static Player &GetInstance()
    {
        static Player player;
        return player;
    }

    int32_t Init(SampleInfo &sampleInfo);
    int32_t Start();
    void StartRelease();

private:
    void DecInputThread();
    void DecOutputThread();
    void Release();

    std::unique_ptr<VideoDecoder> videoDecoder_ = nullptr;
    std::unique_ptr<Demuxer> demuxer_ = nullptr;

    std::mutex mutex_;
    std::atomic<bool> isStarted_{ false };
    std::atomic<bool> isReleased_{ false };
    std::unique_ptr<std::thread> decInputThread_ = nullptr;
    std::unique_ptr<std::thread> decOutputThread_ = nullptr;
    std::condition_variable doneCond_;
    SampleInfo sampleInfo_;
    CodecUserData *decContext_ = nullptr;
    static constexpr int64_t MICROSECOND = 1000000;
};

#endif  // VIDEO_CODEC_PLAYER_H