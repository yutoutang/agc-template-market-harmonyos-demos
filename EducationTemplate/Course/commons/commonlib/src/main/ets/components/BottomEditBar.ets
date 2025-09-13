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
export struct BottomEditBar {
  // 选中计数
  @Require @Param selectCount: number;
  // 一键清空弹框内容
  @Require @Param deleteAllDialogContent: string;
  // 删除选中弹框内容
  @Require @Param deleteSelectDialogContent: string;
  // 删除全部
  @Event deleteAllData: () => void = () => {
  };
  // 删除选中
  @Event deleteSelectData: () => void = () => {
  };
  // 删除弹框
  deleteDialogController?: CustomDialogController;

  build() {
    Row() {
      Column() {
        Image($r('app.media.ic_public_eraser'))
          .width($r('app.float.vp_24'))
          .height($r('app.float.vp_24'))
        Text($r('app.string.one_click_clear'))
          .fontSize($r('sys.float.Caption_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
          .margin({ top: $r('app.float.vp_4') })
      }
      .width('50%')
      .onClick(() => {
        // 删除全部
        this.dialogOpen(this.deleteAllDialogContent, true)
      })

      Column() {
        Image(this.selectCount > 0 ? $r('app.media.icon_delete_black') : $r('app.media.icon_delete_grey'))
          .width($r('app.float.vp_24'))
          .height($r('app.float.vp_24'))
        Text($r('app.string.delete'))
          .fontSize($r('sys.float.Caption_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor(this.selectCount > 0 ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary'))
          .margin({ top: $r('app.float.vp_4') })
      }
      .width('50%')
      .onClick(() => {
        // 删除选中
        this.dialogOpen(this.deleteSelectDialogContent)
      })
    }
    .width('100%')
    .height($r('app.float.vp_52'))
  }

  /**
   * 打开弹框
   * @param content
   * @param isDeleteAll
   */
  dialogOpen(content: ResourceStr, isDeleteAll?: boolean) {
    this.deleteDialogController = new CustomDialogController({
      builder: DeleteDialog({
        content: content,
        confirmDelete: () => {
          if (isDeleteAll) {
            this.deleteAllData()
          } else {
            this.deleteSelectData()
          }
        }
      }),
    })
    this.deleteDialogController.open()
  }
}
 