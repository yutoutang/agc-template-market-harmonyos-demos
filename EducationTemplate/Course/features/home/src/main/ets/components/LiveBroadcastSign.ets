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

@ComponentV2
export struct LiveBroadcastSign {
  build() {
    Row() {
      Image($r('app.media.home_waveform_living'))
        .width($r('app.float.vp_12'))
        .height($r('app.float.vp_12'))
        .margin({ left: $r('app.float.vp_4'), right: $r('app.float.vp_2') })
      Text($r('app.string.live_broadcast_sign'))
        .fontSize($r('sys.float.Caption_M'))
        .fontWeight(FontWeight.Regular)
        .fontColor($r('sys.color.font_on_primary'))
    }
    .backgroundColor($r('sys.color.warning'))
    .width($r('app.float.vp_52'))
    .height($r('app.float.vp_16'))
    .borderRadius({
      topLeft: $r('app.float.vp_6'),
      topRight: $r('app.float.vp_2'),
      bottomLeft: $r('app.float.vp_2'),
      bottomRight: $r('app.float.vp_6')
    })
  }
}
 