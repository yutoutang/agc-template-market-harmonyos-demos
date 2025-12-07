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
import { ChatViewVM } from '../viewModels/ChatViewVM';
import { FullScreenDanMu } from './FullScreenDanMu';
import { FullScreenMore } from './FullScreenMore';
import { FullScreenReport } from './FullScreenReport';
import { FullScreenResolution } from './FullScreenResolution';
import { FullScreenShare } from './FullScreenShare';

@ComponentV2
export struct MoreSetControl {
  // 分辨率切换事件
  @Param resolutionEvent: (resolution: string) => void = () => {
  };
  // 画中画事件
  @Param pipWindowEvent: () => void = () => {
  };
  // 分享事件
  @Param shareEvent: () => void = () => {
  };
  // 举报事件
  @Param reportEvent: (reasons: string[], reason: string) => void = () => {
  };
  // 是否展示更多
  @Local isShowMore: boolean = true;
  // 是否展示分享
  @Local isShowShare: boolean = false;
  // 是否展示清晰度
  @Local isShowResolution: boolean = false;
  // 是否展示弹幕
  @Local isShowDam: boolean = false;
  // 是否展示举报
  @Local isShowReport: boolean = false;
  @Local reportPixmap: image.PixelMap | undefined = undefined;
  @Local vm: ChatViewVM = ChatViewVM.instance;

  @Builder
  moreBuild() {
    FullScreenMore({
      moreItemEvent: (item: string) => {
        this.moreItemEvent(item);
      }
    })
      .visibility(this.isShowMore ? Visibility.Visible : Visibility.Hidden);
  }

  @Builder
  shareBuild() {
    FullScreenShare({
      backClick: () => {
        this.isShowMore = true;
        this.isShowShare = false;
      },
      shareItemEvent: (item: string) => {
        this.shareItemEvent(item);
      }
    })
      .visibility(this.isShowShare ? Visibility.Visible : Visibility.Hidden);
  }

  @Builder
  resolutionBuild() {
    FullScreenResolution({
      backClick: () => {
        this.isShowMore = true;
        this.isShowResolution = false;
      },
      resolutionEvent: (resolution: string) => {
        this.resolutionEvent(resolution);
      }
    })
      .visibility(this.isShowResolution ? Visibility.Visible : Visibility.Hidden);
  }

  @Builder
  danMuBuild() {
    FullScreenDanMu({
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
      },
      backClick: () => {
        this.isShowMore = true;
        this.isShowDam = false;
      },
    })
      .visibility(this.isShowDam ? Visibility.Visible : Visibility.Hidden);
  }

  @Builder
  reportBuild() {
    FullScreenReport({
      reportPixmap: this.reportPixmap,
      backClick: () => {
        this.isShowMore = true;
        this.isShowReport = false;
      },
      onReport: (reasons: string[], reason: string) => {
        this.reportEvent(reasons, reason);
      }
    })
      .visibility(this.isShowReport ? Visibility.Visible : Visibility.Hidden);
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        this.moreBuild();
        this.shareBuild();
        this.danMuBuild();
        this.resolutionBuild();
        this.reportBuild();
      }
      .width(368)
      .height('100%')
      .backgroundColor($r('sys.color.mask_secondary'))
      .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
      .opacity(0.9)
      .zIndex(1)
      .onClick(() => {
      });
    }
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.End)
    .width('100%')
    .height('100%');
  }

  moreItemEvent(item: string) {
    this.isShowMore = false;
    if (item === '分享') {
      this.shareEvent();
    } else if (item === '弹幕设置') {
      this.isShowDam = true;
    } else if (item === '画中画') {
      this.pipWindowEvent();
    } else if (item === '清晰度') {
      this.isShowResolution = true;
    } else if (item === '举报') {
      this.getUIContext().getComponentSnapshot().get('XComponent001', (error: Error, pixmap: image.PixelMap) => {
        if (error) {
          return;
        }
        this.reportPixmap = pixmap;
        this.isShowReport = true;
      });
    } else {
    }
  }

  shareItemEvent(item: string) {
    if (item === '微信') {
    } else if (item === '朋友圈') {
    } else if (item === 'QQ') {
    } else if (item === '生成海报') {
    } else if (item === '复制链接') {
    } else if (item === '系统分享') {
    } else {
    }
    this.getUIContext().getPromptAction().showToast({ message: `暂不支持${item}` });
  }
}