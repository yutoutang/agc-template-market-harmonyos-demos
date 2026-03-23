import { media } from '@kit.MediaKit';
import { VideoPlayerData } from '../type/Index';

@ObservedV2
export class VideoCardPlayerController {
  pause: () => void = () => {
  }
  play: () => void = () => {
  }
  reset: () => void = () => {
  }
  switchPlayPause: () => void = () => {
  }
  videoUrlChange: (videoData: VideoPlayerData) => void = () => {
  }
  seek: (seekTime: number) => void = () => {
  }
  getAvplayer: () => media.AVPlayer | undefined = () => undefined;
  setMembershipOverlay: (value: boolean) => void = () => {
  };
}