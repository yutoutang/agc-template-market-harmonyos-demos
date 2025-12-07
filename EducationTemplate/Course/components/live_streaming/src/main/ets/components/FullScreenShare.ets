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

import { LengthMetrics } from '@kit.ArkUI';
import { MoreItem } from '../models/Type';

@ComponentV2
export struct FullScreenShare {
  @Param backClick: () => void = () => {
  };
  @Param shareItemEvent: (item: string) => void = () => {
  };
  shareItemList: MoreItem[] = [
    {
      label: '微信',
      icon: $r('app.media.wechat'),
      itemId: '01',
    },
    {
      label: '朋友圈',
      icon: $r('app.media.friend_circle'),
      itemId: '02',
    },
    {
      label: 'QQ',
      icon: $r('app.media.qq'),
      itemId: '03',
    },
    {
      label: '生成海报',
      icon: $r('app.media.create_post_white'),
      itemId: '04',
    },
    {
      label: '复制链接',
      icon: $r('app.media.copy_link_white'),
      itemId: '05',
    },
    {
      label: '系统分享',
      icon: $r('app.media.system_share_white'),
      itemId: '06',
    }
  ];

  @Builder
  shareItemBuilder(item: MoreItem) {
    Column() {
      Image(item.icon)
        .width(48)
        .height(48)
        .margin({ bottom: 2, top: 4 });
      Text(item.label)
        .fontSize($r('sys.float.Body_S'))
        .fontColor(Color.White)
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Center)
        .margin({ bottom: 4 });
    }
    .width(68)
    .height(88)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.shareItemEvent(item.label);
    });
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.icon_chevron_backward_dark'))
          .width(40)
          .height(40)
          .margin({ right: 8 })
          .onClick(() => {
            this.backClick();
          });
        Text('分享到')
          .fontSize($r('sys.float.Title_S'))
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold);
      }
      .margin({ top: 20, bottom: 10 });

      Column() {
        Flex({
          direction: FlexDirection.Row,
          justifyContent: FlexAlign.Start,
          wrap: FlexWrap.Wrap,
          space: { main: LengthMetrics.px(30), cross: LengthMetrics.px(50) }
        }) {
          ForEach(this.shareItemList, (item: MoreItem) => {
            this.shareItemBuilder(item);
          }, (item: MoreItem) => JSON.stringify(item));
        };
      }
      .layoutWeight(1);
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 24, right: 24 });
  }
}