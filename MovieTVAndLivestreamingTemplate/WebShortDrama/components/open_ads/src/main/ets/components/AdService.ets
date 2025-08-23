import { adType, platformType } from '../common/Constant';
import { CustomAdService } from './CustomAdService';
import { HwAdService } from './HwAdService';

@ComponentV2
export struct AdService {
  // 广告平台
  @Param @Require platform: platformType = platformType.HUAWEI_AD;
  // 广告类型
  @Param adType?: adType = adType.AD_PICTURE
  // 通用广告位Id
  @Param adId?: string = '';
  // 应用Id（三方广告平台必传）
  @Param appId?: string = '';
  // 应用名称（三方广告平台必传）
  @Param appName?: string = '';
  @Param videoSrc?: ResourceStr = ''
  @Param previewUri?: ResourceStr = $r('app.media.course_ic_preview')
  @Param imageUrl?: ResourceStr = $r('app.media.course_ic_preview')
  // 广告关闭的回调
  @Param closeCallBack: () => void = () => {
  };

  build() {
    Column() {
      if (this.platform === platformType.HUAWEI_AD) {
        HwAdService({
          adId: this.adId,
          closeCallBack: this.closeCallBack,
        });
      } else {
        CustomAdService({
          adType: this.adType,
          videoSrc: this.videoSrc,
          previewUri: this.previewUri,
          imageUrl: this.imageUrl,
          appId: this.appId,
          appName: this.appName,
          closeCallBack: this.closeCallBack,
        })
      }
    }.height('100%').width('100%');
  }
}