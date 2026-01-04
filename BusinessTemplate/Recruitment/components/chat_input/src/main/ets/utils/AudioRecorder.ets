import { fileIo as fs } from '@kit.CoreFileKit';
import { audio } from '@kit.AudioKit'
import { BusinessError } from '@kit.BasicServicesKit';

const DOMAIN: number = 0x0000

// 音频录制
export class AudioRecorder {
  private startTime: number = 0
  private endTime: number = 0
  private fileSize: number = 0
  private audioCapturer: audio.AudioCapturer | undefined = undefined;
  currentAmplitude: number = 0
  // 录音结束回调
  audioRecorderCallback: (size: number, duration: number) => void

  constructor(audioRecorderCallback: (size: number, duration: number) => void) {
    this.audioRecorderCallback = audioRecorderCallback
  }

  // 开始录制
  startRecorder(path: string) {
    let audioStreamInfo: audio.AudioStreamInfo = {
      samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000, // 采样率
      channels: audio.AudioChannel.CHANNEL_1, // 通道
      sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE, // 采样格式
      encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW // 编码格式
    };
    let audioCapturerInfo: audio.AudioCapturerInfo = {
      source: audio.SourceType.SOURCE_TYPE_MIC,
      capturerFlags: 0
    };
    let audioCapturerOptions: audio.AudioCapturerOptions = {
      streamInfo: audioStreamInfo,
      capturerInfo: audioCapturerInfo
    };
    try {
      audio.createAudioCapturer(audioCapturerOptions, async (err, data) => {
        if (err) {
        } else {
          this.audioCapturer = data;
          let bufferSize: number = 0;

          let file: Promise<fs.File> | undefined = undefined;
          try {
            file = this.onAudioWriteData(path, bufferSize, this.audioCapturer);
          } catch (err) {
          } finally {
            fs.close(await file);
          }
          this.startRecording()
        }
      });
    } catch (error) {
    }
  }

  // 获取振幅
  private getNormalizedAmplitude(buffer: ArrayBuffer): number {
    const int16Array = new Int16Array(buffer);
    let maxVal = 0;
    for (const value of int16Array) {
      maxVal = Math.max(maxVal, Math.abs(value));
    }
    const amplitude = Math.min(maxVal / 32767, 1.0); // 限制最大值为1
    this.currentAmplitude = amplitude
    return amplitude
  }

  onAudioWriteData(path: string, bufferSize: number, audioCapturer: audio.AudioCapturer): Promise<fs.File> {
    return new Promise((resolve) => {
      class Options {
        offset?: number;
        length?: number;
      }

      let file = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      let readDataCallback = (buffer: ArrayBuffer) => {
        let options: Options = {
          offset: bufferSize,
          length: buffer.byteLength
        };
        fs.writeSync(file.fd, buffer, options);
        bufferSize += buffer.byteLength;
        this.fileSize = bufferSize
        this.getNormalizedAmplitude(buffer)
      };
      audioCapturer.on('readData', readDataCallback);
      audioCapturer.on('stateChange', (state: audio.AudioState) => {
        if (state === 4) {
          resolve(file);
        }
      });
    });
  }

  //开始录制
  private startRecording() {
    this.startTime = Date.now()
    this.audioCapturer?.start().then(() => {
    }).catch((err: BusinessError) => {
    });
  }

  // 停止录制
  public stopRecorder() {
    this.endTime = Date.now()
    if (this.audioCapturer) {
      this.audioCapturer.stop().then(() => {
        this.audioCapturer?.release();
        this.audioRecorderCallback(this.fileSize, this.endTime - this.startTime)
      }).catch((err: BusinessError) => {
      });
    }
  }
}