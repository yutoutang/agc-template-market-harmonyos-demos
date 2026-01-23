import { AppStorageV2, window } from '@kit.ArkUI';

import {
  TopBar,
  UserInfo,
  MyScrollModifier,
} from 'commonlib'


@ComponentV2
export struct SaveSettingPage {
  @Local bottomHeight: number = 0;
  @Local loginUser: UserInfo = AppStorageV2.connect(UserInfo, () => new UserInfo())!
  @Local scrollModifier: MyScrollModifier = new MyScrollModifier()

  @Local imageStyle: string = AppStorage.get('imageStyle') ?? 'jpeg'
  @Local imageQuality: string[] = ['高', '中', '低']
  @Local imageQualityLevel: number = AppStorage.get('imageQualityLevel') ?? 0
  aboutToAppear(): void {
    try {
      window.getLastWindow(this.getUIContext().getHostContext(), (_err, data) => {
        const avoidAreaBottom = data.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.bottomHeight = avoidAreaBottom.bottomRect.height;
      })
    } catch (e) {
      console.error(`Failed to getLastWindow. error: ${JSON.stringify(e)}`)
    }
  }

  build() {
    NavDestination(){
      Column() {
        TopBar({ title: $r('app.string.saveSetting') })
        Column() {
          Row() {
            Text('图片格式')
              .fontSize(16)
            Row() {
              Text(this.imageStyle)
                .fontSize(16)
                .margin({ right: 13 })
              Image($r('app.media.forward'))
                .width(13)
                .height(13)
            }
            .onClick(() => {
              this.getUIContext().showTextPickerDialog({
                range: ['jpeg', 'png'],
                selected: this.imageStyle === 'jpeg' ? 0 : 1,
                onAccept: (value: TextPickerResult) => {
                  this.imageStyle = value.value as string;
                  AppStorage.setOrCreate<string>('imageStyle', value.value as string)
                  if (value.value === 'png') {
                    this.imageQuality = ['高']
                    this.imageQualityLevel = 0
                    AppStorage.setOrCreate<number>('imageQualityLevel', 0)
                  } else {
                    this.imageQuality = ['高','中','低']
                  }
                },
                canLoop: false
              })
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Divider()
            .margin({ top: 13, bottom: 13 })

          Row() {
            Text('图片质量')
              .fontSize(16)
            Row() {
              Text(this.imageQuality[this.imageQualityLevel])
                .fontSize(16)
                .margin({ right: 13 })
              Image($r('app.media.forward'))
                .width(13)
                .height(13)
            }
            .onClick(() => {
              this.getUIContext().showTextPickerDialog({
                range: this.imageQuality,
                selected: this.imageQualityLevel,
                onAccept: (value: TextPickerResult) => {
                  this.imageQualityLevel = value.index as number;
                  AppStorage.setOrCreate<number>('imageQualityLevel', this.imageQualityLevel)
                },
                canLoop: false
              })
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .alignItems(HorizontalAlign.Start)
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .padding(12)
        .borderRadius(16)
      }
      .width('100%')
      .height('100%')
      .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16'), bottom: $r('app.float.vp_50') })
      .alignItems(HorizontalAlign.Start)
    } .backgroundColor($r('sys.color.background_secondary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true);

  }


}



@Builder
export function SaveSettingPageBuilder() {
  SaveSettingPage()
}
