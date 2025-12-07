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

import { LengthMetrics, window } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { SetItem } from '../models/Type';
import { ChatViewVM } from '../viewModels/ChatViewVM';
import { DanMuSheet } from './DanMuSheet';
import { ReportSheet } from './ReportSheet';
import { ResolutionSheet } from './ResolutionSheet';
import { emitter } from '@kit.BasicServicesKit';

@ComponentV2
export struct MoreSheet {
  @Param moreSetEvent: (item: string) => void = () => {
  };
  @Local isShowResolutionSheet: boolean = false;
  @Local isShowReportSheet: boolean = false;
  @Local isShowDanMu: boolean = false;
  @Local vm: ChatViewVM = ChatViewVM.instance;
  @Local keyboardHeight: number = 0;
  private reportPixmap: image.PixelMap | undefined = undefined;
  private settingItemList: SetItem[] = [
    {
      label: '弹幕设置',
      icon: $r('app.media.bullet_setting'),
      itemId: '01',
    },
    {
      label: '画中画',
      icon: $r('app.media.icon_smal_window_playback_light'),
      itemId: '02',
    },
    {
      label: '清晰度',
      icon: $r('app.media.hd_plus_rectangle'),
      itemId: '03',
    },
    {
      label: '清屏',
      icon: $r('app.media.clear_screen'),
      itemId: '04',
    },
    {
      label: '举报',
      icon: $r('app.media.exclamationmark_triangle'),
      itemId: '05',
    }
  ];

  @Builder
  resolutionBuilder() {
    ResolutionSheet({
      defaultResolution: '1080P 蓝光',
      onChangeResolution: (selectResolution: string) => {
        this.getUIContext().getPromptAction().showToast({ message: `已切换${selectResolution}` });
      }
    })
      .width('90%')
      .height(350);
  }

  @Builder
  reportBuilder() {
    ReportSheet({
      reportPixmap: this.reportPixmap,
      onReport: (reasons: string[], reason: string) => {
        this.isShowReportSheet = false;
        this.getUIContext().getPromptAction().showToast({ message: '举报成功' });
      }
    })
      .width('90%')
      .height(500);
  }

  @Builder
  danMuBuilder() {
    DanMuSheet({
      rowsNum: this.vm.rowsNum,
      notOpacity: this.vm.notOpacity,
      danMuSpeed: this.vm.danMuSpeed,
      danMuSize: this.vm.danMuSize,
      setRowsNum: (set: number) => {
        this.vm.rowsNum = set;
        this.vm.setRowsNum(set);
      },
      setNotOpacity: (set: number) => {
        this.vm.notOpacity = set;
        this.vm.setNotOpacity(set);
      },
      setDanMuSpeed: (set: string) => {
        this.vm.danMuSpeed = set;
        this.vm.setDanMuSpeed(set);
      },
      setDanMuSize: (set: string) => {
        this.vm.danMuSize = set;
        this.vm.setDanMuSize(set);
      }
    })
      .width('90%')
      .height(350);
  }

  build() {
    Column() {
      Text('更多')
        .height(40)
        .width('100%')
        .fontSize($r('sys.float.Title_S'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
        .margin({ top: 12 });
      Flex({
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.Start,
        wrap: FlexWrap.Wrap,
        space: { main: LengthMetrics.px(10), cross: LengthMetrics.px(50) }
      }) {
        ForEach(this.settingItemList, (item: SetItem) => {
          Column() {
            Image(item.icon)
              .width(30)
              .height(30)
              .margin({ bottom: 2, top: 4 });
            Text(item.label)
              .fontSize($r('sys.float.Caption_L'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.Center)
              .margin({ bottom: 4 });
          }
          .width(82)
          .height(60)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.itemEvent(item);
          });
        }, (item: SetItem) => JSON.stringify(item));
      }
      .layoutWeight(1);

      Row()
        .bindSheet(this.isShowResolutionSheet, this.resolutionBuilder(), {
          // 半模态高度
          height: 350,
          dragBar: true, // 是否显示控制条
          backgroundColor: Color.White,
          showClose: true, // 是否显示关闭图标
          preferType: SheetType.CENTER,
          shouldDismiss: ((sheetDismiss: SheetDismiss) => {
            sheetDismiss.dismiss();
            this.isShowResolutionSheet = false;
          })
        });
      Row()
        .bindSheet(this.isShowReportSheet, this.reportBuilder(), {
          // 半模态高度
          height: 600 + this.keyboardHeight,
          dragBar: true, // 是否显示控制条
          backgroundColor: Color.White,
          showClose: true, // 是否显示关闭图标
          preferType: SheetType.CENTER,
          shouldDismiss: ((sheetDismiss: SheetDismiss) => {
            sheetDismiss.dismiss();
            this.isShowReportSheet = false;
          })
        });
      Row()
        .bindSheet(this.isShowDanMu, this.danMuBuilder(), {
          // 半模态高度
          height: 350,
          dragBar: true, // 是否显示控制条
          backgroundColor: Color.White,
          showClose: true, // 是否显示关闭图标
          preferType: SheetType.CENTER,
          shouldDismiss: ((sheetDismiss: SheetDismiss) => {
            sheetDismiss.dismiss();
            this.isShowDanMu = false;
          })
        });
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.font_on_primary'));
  }

  aboutToAppear(): void {
    window.getLastWindow(getContext(this)).then((currentWindow: window.Window) => {
      currentWindow.on('avoidAreaChange', data => {
        if (data.type === window.AvoidAreaType.TYPE_KEYBOARD) {
          if (data.area.bottomRect.height === 0) {
            this.keyboardHeight = 0;
          } else {
            this.keyboardHeight = 100;
          }
          emitter.emit('keyboardHeight', { data: { keyboardHeight: this.keyboardHeight } });
        }
      });
    });
  }

  itemEvent(item: SetItem) {
    if (item.label === '清晰度') {
      this.isShowResolutionSheet = true;
    } else if (item.label === '弹幕设置') {
      this.isShowDanMu = true;
    } else if (item.label === '清屏') {
      this.vm.onCleanScreen();
    } else if (item.label === '举报') {
      this.getUIContext()
        .getComponentSnapshot()
        .get('XComponent001', (error: Error, pixmap: image.PixelMap) => {
          if (error) {
            return;
          }
          this.reportPixmap = pixmap;
          this.isShowReportSheet = true;
        });
    } else {
    }
    this.moreSetEvent(item.label);
  }
}