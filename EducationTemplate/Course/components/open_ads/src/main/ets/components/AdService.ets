/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AdType, platformType } from '../common/Constant';
import { CustomAdService } from './CustomAdService';
import { HwAdService } from './HwAdService';

@ComponentV2
export struct AdService {
  // 广告平台
  @Param @Require platform: platformType = platformType.HUAWEI_AD;
  // 广告类型
  @Param adType?: AdType = AdType.AD_PICTURE
  // 通用广告位Id
  @Param @Require adId?: string = '';
  // 应用Id（三方广告平台必传）
  @Param appId?: string = '';
  // 应用名称（三方广告平台必传）
  @Param appName?: string = '';
  @Param videoSrc?: ResourceStr =
    'https://consumer.huawei.com/content/dam/huawei-cbg-site/cn/mkt/plp/new-phones/video/pocket-series.mp4'
  @Param previewUri?: ResourceStr = $r('app.media.course_ic_preview')
  @Param imageUrl?: ResourceStr = $r('app.media.course_ic_preview')
  // 广告关闭的回调
  @Param @Require closeCallBack: () => void = () => {
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