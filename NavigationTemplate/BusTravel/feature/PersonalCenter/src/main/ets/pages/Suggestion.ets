import fs from '@ohos.file.fs';
import { BusinessError } from '@kit.BasicServicesKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { image } from '@kit.ImageKit';
import { promptAction } from '@kit.ArkUI';
import { Logger, RouteEntryVM } from 'common'
import { audio } from '@kit.AudioKit'

@Builder
export function SuggestionBuilder() {
  Suggestion()
}

@ComponentV2
export struct Suggestion {
  vm: RouteEntryVM = RouteEntryVM.instance;
  @Local pixelMap: Array<image.PixelMap> = []
  @Local text: string = ''
  @Local contactInfo: string = ''
  controller: TextAreaController = new TextAreaController()

  selectPhoto() {
    try {
      let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 4 - this.pixelMap.length;
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      photoPicker.select(photoSelectOptions,
        (err: BusinessError, photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
          if (err) {
            Logger.error(`PhotoViewPicker.select failed with err: ${err.code}, ${err.message}`);
            return;
          }
          Logger.info('PhotoViewPicker.select successfully, PhotoSelectResult uri: ' +
          JSON.stringify(photoSelectResult));
          const photoURLs = photoSelectResult.photoUris; // 图片Uris的数组
          photoURLs.forEach((url) => {
            this.getPixelMap(url)
          })
        });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(`PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
    }
  }

  async getPixelMap(url: string) {
    let file: fs.File = fs.openSync(url, fs.OpenMode.READ_ONLY);
    try {
      this.pixelMap?.push(await image.createImageSource(file.fd).createPixelMap())
    } catch (error) {
      Logger.error('Error:', error);
    } finally {
      if (file) {
        fs.closeSync(await file);
      }
    }
  }

  testRcpMultiPartUpload() {
    this.selectPhoto();
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Row() {
            Polyline({ width: 11, height: 19 })
              .points([[11, 0], [0, 9.5], [11, 19]])
              .fillOpacity(0)
              .stroke('#19191999')
              .strokeWidth('1px')
              .onClick(() => {
                this.vm.pop()
              })
              .margin({ left: '18vp' })

            Text('意见建议')
              .fontSize(20)
              .fontColor('#191919')
              .textAlign(TextAlign.Center)

            Row()
              .width(11)
              .height(19)
              .margin({ right: '18vp' })
          }
          .width('100%')
          .height('60vp')
          .padding({ left: '24.5vp' })
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.SpaceBetween)

          this.buildDescribe()
          Button('提交')
            .width('100%')
            .height(35)
            .backgroundColor($r('app.color.system_color_green'))
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_on_primary'))
            .onClick(() => {
              if (this.text) {
                promptAction.showToast({
                  message: '您已提交成功',
                  duration: 1500,
                  bottom: '80vp',
                });
                this.vm.pop();
              } else {
                promptAction.showToast({
                  message: '请填写问题描述',
                  duration: 1500,
                  bottom: '80vp',
                });
              }
            })
            .margin({ top: 30 })
        }
        .padding({
          left: 20,
          right: 20
        })
        .width('100%')
        .height('100%')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .scrollBarWidth('0vp')
      .backgroundColor('#F1F3F5')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }.hideTitleBar(true)
  }

  @Builder
  buildDescribe() {
    Column() {
      Row() {
        Text('问题描述')
          .fontColor($r('sys.color.ohos_dialog_text_alert'))
        Text(`${this.text.length}/100`)
          .fontColor('#ff1c1c1c')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: '12vp' })

      TextArea({
        text: this.text,
        placeholder: '请输入问题描述',
        controller: this.controller
      })
        .caretColor($r('app.color.system_color_green'))
        .selectedBackgroundColor($r('app.color.system_color_green'))
        .placeholderFont({ size: $r('sys.float.ohos_id_text_size_body3'), weight: 400 })
        .fontSize(12)
        .fontColor('#999999')
        .maxLength(100)
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .onChange((value: string) => {
          this.text = value
        })
        .height('122lpx')
        .width('336lpx')
        .margin({ bottom: '12vp' })

      Row() {
        Text('问题截图（选填）')
          .fontColor($r('sys.color.ohos_dialog_text_alert'))
        Text(`${this.pixelMap.length}/4`)
          .fontColor('#ff1c1c1c')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: '12vp' })

      Flex({
        justifyContent: FlexAlign.Start,
        alignItems: ItemAlign.Start,
        direction: FlexDirection.Column
      }) {
        List({ space: 10 }) {
          ForEach(this.pixelMap, (item: image.PixelMap, index: number) => {
            ListItem() {
              Stack() {
                Image(this.pixelMap[index]).width('80lpx').height('80lpx')
                Row() {
                  Image($r('app.media.ic_public_close')).width(14.6).height(14.6)
                    .margin({ top: 6, right: 6 })
                }
                .alignItems(VerticalAlign.Top)
                .justifyContent(FlexAlign.End)
                .width('80lpx')
                .height('80lpx')
              }
            }
            .onClick(() => {
              this.pixelMap.splice(index, 1)
            })
          }, (item: image.PixelMap) => new Date().toString())
          if (this.pixelMap.length < 4) {
            ListItem() {
              Image($r('app.media.ic_question_plus')).width('80lpx').height('80lpx').borderRadius('8lpx')
            }.onClick(() => {
              this.testRcpMultiPartUpload();
            })
          }
        }.listDirection(Axis.Horizontal)
      }
      .padding('12lpx')
      .width('336lpx')
      .height('104lpx')
      .backgroundColor($r('app.color.background_color_white'))
      .borderRadius(10)
      .margin({ bottom: '12vp' })

      Row() {
        Text('联系方式（选填）')
          .fontColor($r('sys.color.ohos_dialog_text_alert'))
        Text(`${this.contactInfo.length}/11`)
          .fontColor('#ff1c1c1c')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: '12vp' })

      TextInput({ text: this.contactInfo, placeholder: '请填写联系手机' })
        .caretColor($r('app.color.system_color_green'))
        .width('336lpx')
        .maxLength(11)
        .type(InputType.PhoneNumber)
        .onChange((value: string) => {
          this.contactInfo = value
        })
    }
  }
}