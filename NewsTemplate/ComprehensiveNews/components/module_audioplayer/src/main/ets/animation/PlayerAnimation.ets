import { displaySync } from '@kit.ArkGraphics2D';
import { MediaViewModel } from '../viewmodel/MediaViewModel';

@ObservedV2
export class PlayerAnimation {
  private coverRotatePlay: displaySync.DisplaySync | undefined = undefined;
  @Trace imageRotate: number = 0;
  private mediaService: MediaViewModel = MediaViewModel.getInstance()
  private drawFrame: (value: displaySync.IntervalInfo) => void = (value: displaySync.IntervalInfo) => {
    if (this.imageRotate >= 360) {
      this.imageRotate = 0;
    }
    this.imageRotate += 1;
  };

  constructor() {
    this.animationFun()
  }

  private animationFun() {
    let range: ExpectedFrameRateRange = {
      expected: 30,
      min: 0,
      max: 30,
    };

    this.coverRotatePlay = displaySync.create();
    this.coverRotatePlay.setExpectedFrameRateRange(range);
    this.coverRotatePlay.on('frame', this.drawFrame);
  }

  @Monitor('mediaService.isPlaying')
  playerCoverRotate() {
    if (this.mediaService.isPlaying) {
      this.coverRotatePlay?.start();
    } else {
      this.coverRotatePlay?.stop();
    }
  }
}