import { BrightnessUtil, UserInfo, UserState } from 'common';
import { PersistenceV2 } from '@kit.ArkUI';

/**
 * click set brightness
 */
const SET_BRIGHTNESS_CLICK: number = -1;
/**
 * slide set brightness
 */
const SET_BRIGHTNESS_SLIDE: number = 1;

@ComponentV2
export struct CodeMockPage {
  @Local userState: UserState = PersistenceV2.connect(UserState, () => new UserState())!;
  @Param title: string = ''

  aboutToAppear(): void {
    /*
     * 医保码页面调节亮度
     * */
    BrightnessUtil.setBrightness(SET_BRIGHTNESS_SLIDE)
  }

  aboutToDisappear(): void {
    BrightnessUtil.setBrightness(SET_BRIGHTNESS_CLICK)
  }

  build() {
    NavDestination() {
      Column({ space: 10 }) {
        Column() {
          Stack() {
            QRCode(JSON.stringify(this.userState.userInfo))
              .width(200)
              .height(200)
            Image($r('app.media.ic_start_icon'))
              .width(24)
              .height(24)
          }.margin({ top: '30%' })

          Text($r('app.string.mock_title'))
            .margin({ top: 20 })
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
        }
        .backgroundColor($r('sys.color.background_primary'))
        .width('100%')
        .height('100%')
      }
      .backgroundColor($r('sys.color.background_primary'))
      .padding({ left: 16, right: 16 })
    }
    .title(this.title)
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
  }
}