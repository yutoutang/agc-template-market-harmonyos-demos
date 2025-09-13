/*
 *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

import { RouterModule } from '../utils/RouterModule';

@ComponentV2
export struct TopBar {
  @Param title: ResourceStr = '';
  @Event onClickBack: () => void = () => {
    RouterModule.pop()
  }

  build() {
    Row() {
      Image($r('app.media.chevron_backward'))
        .width($r('app.float.vp_40'))
        .height($r('app.float.vp_40'))
        .onClick(() => {
          this.onClickBack()
        })
      Text(this.title)
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: $r('app.float.vp_8') })
    }
    .height($r('app.float.vp_56'))
    .alignItems(VerticalAlign.Center)
  }
}

@ComponentV2
export struct EditButton {
  @Param isEdit: boolean = false;
  @Event onClickEdit: () => void = () => {
  }

  build() {
    Text(this.isEdit ? $r('app.string.cancel') : $r('app.string.edit'))
      .fontSize($r('sys.float.Body_L'))
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_primary'))
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius(20)
      .width($r('app.float.vp_64'))
      .height($r('app.float.vp_40'))
      .textAlign(TextAlign.Center)
      .onClick(() => {
        this.onClickEdit()
      })
  }
}
 