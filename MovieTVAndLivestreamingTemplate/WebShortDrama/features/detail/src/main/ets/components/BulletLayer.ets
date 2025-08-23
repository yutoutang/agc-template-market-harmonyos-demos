import { BulletView } from './BulletView';
import { BulletVM } from '../viewmodels/BulletVM';

@ComponentV2
export struct BulletLayer {

  @Param @Require bulletVM: BulletVM

  aboutToAppear(): void {
    this.bulletVM.startBullet()
  }

  aboutToDisappear(): void {
    this.bulletVM.closeBullet()
  }

  build() {
    // 视频上方弹幕
    BulletView({ bulletComments: this.bulletVM.bulletComments, xTrans: this.bulletVM.xTrans })
  }
}