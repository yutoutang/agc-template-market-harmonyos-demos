/*
 *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  Licensed under the Apache License, Version 2.0 (the 'License');
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an 'AS IS' BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */
import { NumberUtil } from 'commonlib';

@ComponentV2
export struct LiveNumberOverlay {
  @Param liveNumber: number = 0;

  build() {
    Row() {
      Row() {
        Image($r('app.media.learn_number_icon'))
          .width($r('app.float.vp_12'))
          .height($r('app.float.vp_12'))
          .margin({ right: $r('app.float.vp_3') })
        Text(NumberUtil.getCountFormat(this.liveNumber))
          .height($r('app.float.vp_10'))
          .fontSize($r('sys.float.Caption_S'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_on_primary'))
          .textAlign(TextAlign.Center)
      }

    }
    .width('100%')
    .height($r('app.float.vp_20'))
    .backgroundColor($r('sys.color.mask_tertiary'))
    .justifyContent(FlexAlign.End)
    .padding({ right: $r('app.float.vp_4') })
  }
}
 