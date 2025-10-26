export class AVPlayerListener {
  onPlaying?: () => void;
  onPaused?: () => void;
  onDurationChanged?: (duration: number) => void;
  onBufferedTimeChanged?: (buffered: number) => void;
  onTimeUpdate?: (time: number) => void;
  onEnded?: () => void;
  onError?: () => void;
  onVideoSizeChanged?: (width: number, height: number) => void;
  onDestroyed?: () => void;
}