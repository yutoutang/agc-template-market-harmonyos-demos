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

import { image } from '@kit.ImageKit'
import { display } from '@kit.ArkUI'
import { PopupBaseController, ShareOptions } from '../model/Model'
import { SecondPosterShare } from './SecondPosterShareBuilder'

const popupDuration = 200
const hideDuration = 220


@ComponentV2
export struct PosterSharePopContent {
  @Require @Param qrCodeInfo: ShareOptions
  @Local transX: string | number = ''
  @Local transY: string | number = ''
  @Local screenWidth: number = 0
  @Local screenHeight: number = 0
  @Event popClose: (isClose: boolean) => void = () => {
  }
  /**
   * 截图
   */
  @Param @Require pixmap: image.PixelMap
  /**
   * 底部偏移
   */
  @Param offsetY: number = 0
  /**
   * 封面
   */
  @Param coverUrl: string = ''
  /**
   * 自定义内容
   */
  @BuilderParam contentBuilder: CustomBuilder
  @Param baseController: PopupBaseController = new PopupBaseController()
  @Event close: () => void = () => {
  }

  aboutToAppear(): void {
    this.baseController.hide = (): void => this.init()
    this.init()
  }

  init() {
    display.getAllDisplays((err, data) => {
      this.screenWidth = px2vp(data[0].width)
      this.screenHeight = px2vp(data[0].height)
    })
    this.transY = '100%'
  }

  trans() {
    this.transY = 0
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          Image(this.pixmap)
            .width(270)
            .height(this.coverUrl ? 370 : 270)
            .margin({ top: 30 })
          Blank()
            .width('100%')
            .height(30)
          Row() {
            Column() {
              SecondPosterShare({
                pixmap: this.pixmap,
                qrCodeInfo: this.qrCodeInfo,
                coverUrl: this.coverUrl,
                onCancel: () => {
                  this.close()
                },
                popClose: (isClose: boolean) => {
                  this.popClose(isClose)
                }
              })
            }
            .width('100%')
            .height(300)
            .backgroundColor($r('sys.color.background_primary'))
            .alignItems(HorizontalAlign.Start)
            .borderRadius(24)
            .animation({ duration: popupDuration, curve: Curve.EaseInOut })
            .onAppear(() => {
              setTimeout(() => {
                this.trans()
              }, 100)
            })
          }
        }
        .justifyContent(FlexAlign.End)
        .clip(true)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
  }
}

@ComponentV2
export struct PosterSharePop {
  @Require @Param shareCodeInfo: ShareOptions
  /**
   * 截图
   */
  @Param @Require pixmap: image.PixelMap
  /**
   * 弹框展示状态
   */
  @Param @Require sharePopShow: boolean
  /**
   * 底部偏移
   */
  @Param offsetY: number = 0
  /**
   * 蒙层颜色
   */
  @Param maskColor: ResourceColor = '0x33000000'
  /**
   * 自定义内容
   */
  @BuilderParam contentBuilder: CustomBuilder
  /**
   * 弹框打开回调
   */
  @Event onOpen: () => void = () => {
  }
  /**
   * 弹框关闭回调
   */
  @Event onClose: () => void = () => {
  }
  @Event $sharePopShow: (visible: boolean) => void = () => {
  }
  @Event popClose: (isClose: boolean) => void = () => {
  }
  private baseController: PopupBaseController = new PopupBaseController()
  private promptAction = this.getUIContext().getPromptAction()
  private dialogId: number = 0

  @Monitor('sharePopShow')
  visibleChange() {
    if (this.sharePopShow) {
      this.open()
    } else {
      this.baseController.hide()
      setTimeout(() => {
        this.promptAction.closeCustomDialog(this.dialogId)
      }, hideDuration)
    }
  }

  @Builder
  defaultContentBuilder() {
    PosterSharePopContent({
      offsetY: this.offsetY,
      coverUrl: this.shareCodeInfo.coverUrl,
      qrCodeInfo: this.shareCodeInfo,
      pixmap: this.pixmap,
      contentBuilder: this.contentBuilder,
      baseController: this.baseController,
      close: (): void => this.close(),
      popClose: (isClose: boolean) => {
        this.popClose(isClose)
      }
    })
  }

  async open() {
    this.dialogId = await this.promptAction.openCustomDialog({
      builder: () => {
        this.defaultContentBuilder()
      },
      width: '100%',
      height: '100%',
      backgroundBlurStyle: BlurStyle.NONE,
      cornerRadius: 0,
      alignment: DialogAlignment.Bottom,
      maskColor: this.maskColor,
      offset: { dx: 0, dy: 100 },
      onDidAppear: () => {
        this.onOpen()
      },
      onDidDisappear: () => {
        this.onClose()
      },
    })
  }

  // 关闭弹框
  close() {
    this.onClose()
  }

  build() {
  }
}