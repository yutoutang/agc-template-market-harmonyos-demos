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

import { NewsQrCode, ShareOptions } from '../model/Model'

@ComponentV2
export struct Screenshot {
  @Require @Param shareCodeInfo: ShareOptions

  handleQrCode() {
    let code: NewsQrCode = {
      articleId: this.shareCodeInfo?.id,
    }
    return JSON.stringify(code)
  }

  build() {
    Column() {
      Column() {
        Column() {
          Image($r('app.media.course_icon')).height(143).width('100%')
            .visibility(this.shareCodeInfo.coverUrl ? Visibility.Visible : Visibility.None)
        }

        Column() {
          Text(this.shareCodeInfo.title)
            .fontWeight(FontWeight.Medium)
            .fontSize(14)
            .maxLines(2)
            .fontColor($r('sys.color.font_primary'))
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 12 })
          Row({ space: 8 }) {
            Text('主讲人  ' + this.shareCodeInfo.lecturer)
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
          }
          .margin({ top: '20%', bottom: 16 })
          .width('100%')
          .justifyContent(FlexAlign.Start)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 8, right: 8 })
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .backgroundColor($r('sys.color.background_secondary'))
      .borderRadius(8)

      Row({ space: 8 }) {
        QRCode(this.handleQrCode()).width(64).height(64)
        Text('长按二维码查看详情')
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
      }
      .width('100%')
      .margin({ top: 12 })
      .justifyContent(FlexAlign.Start)
    }
    .id(this.shareCodeInfo.id)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(8)
    .width(270)
    .height(this.shareCodeInfo.coverUrl ? 370 : 270)
    .padding(16)
  }
}