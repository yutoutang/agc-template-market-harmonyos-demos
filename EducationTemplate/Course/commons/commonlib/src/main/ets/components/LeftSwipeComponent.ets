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
import { DeleteDialog } from './DeleteDialog';


@ComponentV2
export struct LeftSwipeComponent {
  @Consumer() swipeIndex: number = 0;
  @Require @Param index: number;
  // 弹框内容
  @Param dialogContent: string = '';
  // 确认左滑删除
  @Event confirmLeftSwipeDelete: (index: number) => void = () => {
  };
  // 删除弹框
  deleteDialogController: CustomDialogController = new CustomDialogController({
    builder: DeleteDialog({
      content: this.dialogContent,
      confirmDelete: () => {
        this.confirmLeftSwipeDelete(this.index)
      }
    }),
  });

  build() {
    Row() {
      Image($r('app.media.icon_delete_red'))
        .height($r('app.float.vp_40'))
        .width($r('app.float.vp_40'))
        .margin({ left: $r('app.float.vp_12') })
        .onClick(() => {
          this.swipeIndex = this.index
          this.deleteDialogController.open()
        })
    }
    .padding($r('app.float.vp_4'))
    .justifyContent(FlexAlign.SpaceEvenly)
    .height('100%')
  }
}
 