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

import { image } from '@kit.ImageKit';
import { display } from '@kit.ArkUI';
import { ReportItem } from '../models/Type';

@ComponentV2
export struct FullScreenReport {
  @Param @Require reportPixmap: image.PixelMap;
  @Param backClick: () => void = () => {
  };
  @Param onReport: (reasons: string[], reason: string) => void = () => {
  };
  @Local commentLength: number = 0;
  @Local curFoldHeight: number = 200;
  @Local isEditing: boolean = false;
  @Local reasonList: Array<ReportItem> = [
    new ReportItem('色情低俗', false), new ReportItem('违法违规', false), new ReportItem('血腥暴力', false),
    new ReportItem('危险行为', false), new ReportItem('垃圾广告', false), new ReportItem('未成年人相关', false)
  ];
  private reasons: Array<string> = [];
  private reason: string = '';
  // 当前屏幕折叠态（仅折叠屏设备下有效）
  curFoldStatus: display.FoldStatus = display.FoldStatus.FOLD_STATUS_UNKNOWN;

  setCurFoldHeight() {
    this.curFoldHeight = 300;
  }

  regDisplayListener(): void {
    display.on('foldStatusChange', async (curFoldStatus: display.FoldStatus) => {
      // 同一个状态重复触发不做处理
      if (this.curFoldStatus === curFoldStatus) {
        return;
      }
      this.curFoldStatus = curFoldStatus;
      this.setCurFoldHeight();
    });
  }

  aboutToAppear(): void {
    if (display.isFoldable()) {
      this.regDisplayListener();
    }
    this.curFoldStatus = display.getFoldStatus();
    this.setCurFoldHeight();
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.icon_chevron_backward_dark'))
          .width(40)
          .aspectRatio(1)
          .margin({ right: 8 })
          .onClick(() => {
            this.backClick();
          });
        Text('举报').fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White);
      }.margin({ top: 20, bottom: 10 });

      Scroll() {
        Column() {
          Row() {
            Image(this.reportPixmap).width(176).height(100);
          }
          .width('100%')
          .height(100)
          .margin({ top: 8 })
          .justifyContent(FlexAlign.Center);

          Grid() {
            ForEach(
              this.reasonList,
              (item: ReportItem, index: number) => {
                GridItem() {
                  Text(item.reason)
                    .width(104)
                    .height(28)
                    .backgroundColor(!item.isSelected ? $r('sys.color.comp_background_tertiary') :
                      $r('sys.color.multi_color_01'))
                    .fontColor('#fff')
                    .fontWeight(FontWeight.Medium)
                    .fontSize($r('sys.float.Body_M'))
                    .textAlign(TextAlign.Center)
                    .borderRadius(14)
                    .margin({ top: 6, bottom: 6 })
                    .onClick(() => {
                      if (!item.isSelected) {
                        this.reasons.push(item.reason);
                      } else {
                        this.reasons.splice(this.reasons.indexOf(item.reason), 1);
                      }
                      this.reasonList[index].isSelected = !this.reasonList[index].isSelected;
                    });
                };
              }, (item: ReportItem, index) => JSON.stringify(item) + index);
          }
          .width('100%')
          .height(84)
          .rowsTemplate('1fr 1fr')
          .columnsTemplate('1fr 1fr 1fr')
          .rowsGap(4)
          .columnsGap(8)
          .margin({ top: 16 });

          Stack({ alignContent: Alignment.BottomEnd }) {
            TextArea({ placeholder: '请输入详细举报内容，便于平台鉴定违规情况（非必选）' })
              .width('100%')
              .height(72)
              .fontSize(12)
              .fontWeight(400)
              .lineHeight(16)
              .maxLength(30)
              .placeholderColor($r('sys.color.font_tertiary'))
              .placeholderFont({ size: 12 })
              .backgroundColor($r('sys.color.comp_background_primary'))
              .borderRadius(4)
              .padding(8)
              .onEditChange((isEditing: boolean) => {
                this.isEditing = isEditing;
              })
              .onChange((v) => {
                this.reason = v;
                this.commentLength = v.length;
              });

            Text(`${this.commentLength}/30`)
              .fontSize($r('sys.float.Caption_L'))
              .fontColor($r('sys.color.font_tertiary'))
              .fontWeight(FontWeight.Regular)
              .margin({ bottom: 8, right: 8 });
          }
          .width('100%')
          .height(72)
          .margin({ top: 4, bottom: this.curFoldHeight === 300 ? 0 : (this.isEditing ? 75 : 0) });
        }
        .height(this.curFoldHeight);
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off);

      Button('提交')
        .width('100%')
        .height(40)
        .borderRadius(20)
        .backgroundColor($r('sys.color.multi_color_01'))
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .margin({ top: 16, bottom: 16 })
        .onClick(() => {
          if (this.reasons.length === 0) {
            this.getUIContext().getPromptAction().showToast({ message: '请选择举报原因后提交' });
            return;
          }
          this.reasonList.forEach((item: ReportItem) => {
            item.isSelected = false;
          });
          this.onReport(this.reasons, this.reason);
          this.backClick();
        });

    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 24, right: 24 });
  }
}