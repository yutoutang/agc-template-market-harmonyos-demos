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

import { display } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import { fileSelect } from '../util/FileSelect';
import { FeedbackModel } from '../viewModel/FeedbackRecordModel';

@ComponentV2
export struct Feedback {
  //传入问题描述的最大字数
  @Param maxLength: number = 100
  //传入问题截图需要的最大数量
  @Param maxCount: number = 3
  //监听电话号码输入的长度
  @Local phoneLength: number = 0
  // 监听问题描述输入的长度
  @Local descLength: number = 0
  //获取选择图片后的url数组
  @Local imageUris: Array<string> = [];
  @Local uploadPictureUris: Array<string> = [];
  @Local feedbackData: FeedbackModel = new FeedbackModel();
  @Local phoneError: string = ''
  @Local imageSize: number = 104
  @Local foldStatus: number = display.getFoldStatus()
  @Event submitClick: (feedbackData: FeedbackModel) => void = () => {
    this.getUIContext().getPromptAction().showToast({ message: '仅演示，可自行实现业务功能', duration: 2000 });
  };

  regDisplayListener(): void {
    display.on('foldStatusChange', async (curFoldStatus: display.FoldStatus) => {
      // 同一个状态重复触发不做处理
      if (this.foldStatus === curFoldStatus) {
        return;
      }
      this.foldStatus = curFoldStatus;
      this.setCurFoldImageSize()
    })
  }

  setCurFoldImageSize() {
    if (this.foldStatus === display.FoldStatus.FOLD_STATUS_FOLDED) {
      this.imageSize = 100
    } else {
      this.imageSize = 104
    }
  }

  aboutToAppear(): void {
    this.regDisplayListener()
    this.setCurFoldImageSize()
  }

  build() {
    Column() {
      // 问题描述
      this.problemDescBuilder()
      // 上传图片
      this.uploadPicturesBuilder()
      // 联系方式
      this.phoneNumberBuilder()
      Blank()
      // 提交按钮
      this.submitButtonBuilder()
    }
    .width('100%')
    .height($r('app.float.vp_680'))
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16'),
      top: $r('app.float.vp_8'),
      bottom: $r('app.float.vp_8')
    })
  }

  // 提交按钮
  @Builder
  submitButtonBuilder() {
    Button($r('app.string.submit_feedback'))
      .borderRadius(20)
      .fontColor($r('sys.color.font_on_primary'))
      .backgroundColor($r('sys.color.multi_color_01'))
      .opacity(this.descLength > 0 && !this.phoneError ? 1 : 0.4)
      .fontSize($r('sys.float.Body_L'))
      .fontWeight(FontWeight.Medium)
      .width('100%')
      .height($r('app.float.vp_40'))
      .align(Alignment.Center)
      .onClick(async () => {
        if (this.descLength > 0 && !this.phoneError) {
          this.feedbackData.id = util.generateRandomUUID(true)
          //获取当前时间
          this.feedbackData.time = new Date().getTime()
          this.submitClick(this.feedbackData)
        }
      })
  }

  // 问题描述
  @Builder
  problemDescBuilder() {
    TextArea({ placeholder: $r('app.string.problem_desc_placeholder') })
      .placeholderColor($r('sys.color.font_tertiary'))
      .placeholderFont({ size: $r('sys.float.Body_L'), weight: 'regular' })
      .height($r('app.float.vp_151'))
      .maxLength(this.maxLength)
      .showCounter(true)
      .backgroundColor($r('sys.color.comp_background_primary'))
      .fontColor($r('sys.color.font_primary'))
      .fontSize($r('sys.float.Body_L'))
      .onChange((value: string) => {
        this.feedbackData.description = value;
        this.descLength = value.length;
      })
  }

  // 上传图片
  @Builder
  uploadPicturesBuilder() {
    Column() {
      Row() {
        Text($r('app.string.upload_pictures'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
      }
      .margin({ bottom: $r('app.float.vp_8') })

      Grid() {
        GridItem() {
          Row() {
            Image($r('app.media.ic_public_plus'))
              .width($r('app.float.vp_25'))
              .height($r('app.float.vp_25'))
          }
          .width(this.imageSize)
          .height(this.imageSize)
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius(16)
          .onClick(() => {
            if (this.imageUris.length < this.maxCount) {
              this.selectImage()
            } else {
              this.getUIContext().getPromptAction().showToast({
                message: `最多上传${this.maxCount}张`,
                duration: 2000
              });
            }
          })
        }

        ForEach(this.imageUris, (item: string, index: number) => {
          GridItem() {
            Stack({ alignContent: Alignment.TopEnd }) {
              Image(item ? item : $r('app.media.upload_picture'))
                .width(this.imageSize)
                .height(this.imageSize)
                .borderRadius(16)
              Image($r('app.media.ic_public_close_circle'))
                .width($r('app.float.vp_22'))
                .height($r('app.float.vp_22'))
                .margin({ right: $r('app.float.vp_9'), top: $r('app.float.vp_9') })
                .onClick(() => {
                  this.imageUris.splice(index, 1)
                })
            }
          }
        }, (item: string, index: number) => item + index)
      }
      .columnsTemplate(`repeat(auto-stretch, ${this.imageSize})`)
      .rowsGap($r('app.float.vp_8'))
      .scrollBar(BarState.Off)
      .height(this.foldStatus !== 1 && this.imageUris.length > 2 ? this.imageSize * 2 + 8 : this.imageSize)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ top: $r('app.float.vp_24'), bottom: $r('app.float.vp_24') })
  }

  // 联系方式
  @Builder
  phoneNumberBuilder() {
    Column() {
      Row() {
        Text($r('app.string.contact_info'))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
      }
      .margin({ bottom: $r('app.float.vp_8') })

      TextInput({ placeholder: $r('app.string.contact_info_placeholder') })
        .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
        .placeholderColor($r('sys.color.font_tertiary'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_L'))
        .showError(this.phoneError)
        .height($r('app.float.vp_48'))
        .type(InputType.PhoneNumber)
        .maxLength(11)
        .onChange((value: string) => {
          this.phoneLength = value.length
          this.feedbackData.phoneNumber = value
        })
        .onBlur(() => {
          if (this.phoneLength === 11 || this.phoneLength === 0) {
            this.phoneError = '';
          } else {
            this.phoneError = '请输入11位正确的电话号码';
          }
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // 选择图像
  async selectImage() {
    let uris = await fileSelect(this.uploadPictureUris, this.maxCount - this.feedbackData.uploadPictureUris.length)
    this.imageUris.push(...uris)
    this.feedbackData.uploadPictureUris = this.imageUris
  }
}