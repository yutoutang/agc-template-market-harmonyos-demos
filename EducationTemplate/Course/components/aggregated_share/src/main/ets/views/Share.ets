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
import { FirstPosterShareBuilder } from '../buider/FirstPosterShareBuilder'
import { PosterSharePop } from '../buider/PosterShareBuilder'
import { Screenshot } from '../ComponentScreenshot/Screenshot';
import { ShareEventDispatcher } from '../utils/EventDispatcher';
import { WxShareViewModel } from '../viewModel/WxShareViewModel';
import { QqShareViewModel } from '../viewModel/QqShareViewModel';
import { ShareOptions, ShareSheetParams } from '../model/Model';
import { PopViewUtils } from '../utils/PopViewUtils';

@ComponentV2
export struct Share {
  @BuilderParam shareRenderBuilder: () => void;
  @Param shareCodeInfo: ShareOptions = new ShareOptions()
  @Local sharePopShow: boolean = false
  @Local pixmap: image.PixelMap | undefined = undefined
  @Event onClose: () => void = () => {}
  @Event onOpen: () => void = () => {}
  @Local wxShareViewModel: WxShareViewModel = WxShareViewModel.instance
  @Local qqShareViewModel: QqShareViewModel = QqShareViewModel.instance

  aboutToAppear(): void {
    this.qqShareViewModel.initQqShare()
    ShareEventDispatcher.closeCallback = () => {
      this.onClose()
    }
  }

  onPost = (isOpen: boolean, pixmap: image.PixelMap) => {
    this.sharePopShow = isOpen
    this.pixmap = pixmap
  }

  build() {
    Column() {
      if (this.shareRenderBuilder) {
        this.shareRenderBuilder()
      } else {
        Image($r('app.media.share_active')).width(21).height(21).fillColor($r('sys.color.font_primary'))
      }
      PosterSharePop({
        sharePopShow: this.sharePopShow,
        shareCodeInfo:this.shareCodeInfo,
        pixmap:this.pixmap,
        onClose: () => {
          this.sharePopShow = false
          this.onClose()
        },
        popClose: (isClose: boolean) => {
          this.sharePopShow = isClose
        },
      })
      Screenshot({
        shareCodeInfo: this.shareCodeInfo,
      }).position({ left: -2000, bottom: 0 }).visibility(Visibility.Hidden)
    }
    .onClick(() => {
      this.onOpen()
      let params: ShareSheetParams = {
        onPost: this.onPost,
        shareCodeInfo: this.shareCodeInfo,
      }
      PopViewUtils.showSheet<ShareSheetParams>(wrapBuilder(FirstPosterShareBuilder), {
        showClose: true,
        title: {
          title: '分享到',
        },
        backgroundColor: $r('sys.color.background_secondary'),
        detents: [SheetSize.FIT_CONTENT],
      }, params);
    })
  }
}