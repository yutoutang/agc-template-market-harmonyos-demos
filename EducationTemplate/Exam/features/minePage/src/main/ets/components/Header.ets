/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { RouterModule } from 'router_module';

@ComponentV2
export struct Header {
  @Param title: string = ''
  @Param rightImageRes: Resource | undefined = undefined
  @Event rightOnClick: () => void = () => {
  }

  build() {
    Row() {
      Image($r('app.media.ic_backward')).size({ width: 40, height: 40 })
        .margin({ left: 16, right: '8vp' })
        .onClick(() => {
          RouterModule.pop()
        })
      Text(this.title).size({ width: 136, height: 27 })
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      Blank()
      if (this.rightImageRes) {
        Image(this.rightImageRes).size({ width: 40, height: 40 })
          .margin({ right: 16 })
          .onClick(this.rightOnClick)
      }
    }
    .justifyContent(FlexAlign.Start)
    .backgroundColor($r('sys.color.background_primary'))
    .size({ width: '100%', height: 56 })
  }
}