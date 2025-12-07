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

import { MoreItem } from '../models/Type';

@ComponentV2
export struct FullScreenMore {
  @Param moreItemEvent: (item: string) => void = () => {
  };
  // 是否展示举报
  @Local isShowReport: boolean = false;
  moreItemList: MoreItem[] = [
    {
      label: '分享',
      icon: $r('app.media.icon_share'),
      itemId: '01',
    },
    {
      label: '弹幕设置',
      icon: $r('app.media.icon_smal_window_playback'),
      itemId: '02',
    },
    {
      label: '画中画',
      icon: $r('app.media.icon_smal_window_playback'),
      itemId: '03',
    },
    {
      label: '清晰度',
      icon: $r('app.media.icon_hd_plus_rectangle'),
      itemId: '04',
    },
    {
      label: '举报',
      icon: $r('app.media.icon_exclamationmark_triangle'),
      itemId: '05',
    }
  ];

  @Builder
  moreItemBuilder(item: MoreItem) {
    Column() {
      Image(item.icon)
        .width(32)
        .height(32)
        .margin({ bottom: 2, top: 4 });
      Text(item.label)
        .fontSize(12)
        .fontColor('#fff')
        .fontWeight(500)
        .textAlign(TextAlign.Center)
        .margin({ bottom: 4 });
    }
    .width(82)
    .height(58)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.moreItemEvent(item.label);
    });
  }

  @Builder
  shareItemBuilder(item: MoreItem) {
    Column() {
      Image(item.icon)
        .width(32)
        .height(32)
        .margin({ bottom: 2, top: 4 });
      Text(item.label)
        .fontSize(12)
        .fontColor('#fff')
        .fontWeight(500)
        .textAlign(TextAlign.Center)
        .margin({ bottom: 4 });
    }
    .width(82)
    .height(58)
    .justifyContent(FlexAlign.Center);
  }

  build() {
    Column() {
      Text('更多')
        .fontColor(Color.White)
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 10 });
      Column() {
        Flex({
          justifyContent: FlexAlign.Start,
          wrap: FlexWrap.Wrap,
          direction: FlexDirection.Row,
        }) {
          ForEach(this.moreItemList, (item: MoreItem) => {
            this.moreItemBuilder(item);
          }, (item: MoreItem) => JSON.stringify(item));
        };
      }
      .layoutWeight(1);
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 12, right: 12 });
  }
}