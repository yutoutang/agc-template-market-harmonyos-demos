import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants, UserInfoModel, WindowModel } from 'lib_common';

@Builder
export function CommonTextInputBuilder(value: string, placeholder: string, maxLength: number,
  confirmValue: (value: string) => void) {
  CommonTextInput({
    value: value,
    placeholder: placeholder,
    confirmValue: confirmValue,
    maxLength: maxLength
  })
}

@ComponentV2
export struct CommonTextInput {
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local userInfoModel: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  // 值
  @Param value: string = '';
  @Param placeholder: string = '备注';
  @Param maxLength: number = 70
  @Local inputValue: string = this.value ? this.value : '';
  @Event
  confirmValue: (value: string) => void = () => {
    // do nothing.
  }

  build() {
    Column() {
      Column() {
        TextArea({ text: $$this.inputValue, placeholder: this.placeholder })
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
          .backgroundColor($r('sys.color.comp_background_tertiary'))
          .placeholderColor($r('sys.color.font_tertiary'))
          .placeholderFont({ size: 16 })
          .maxLength(this.maxLength)
          .showCounter(true)
          .height(156)
          .margin({ top: 12 })
        Column() {
          Button('确定')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor($r('app.color.app_theme'))
            .width('100%')
            .onClick(() => {
              this.inputValue = this.inputValue.trim();
              this.confirmValue(this.inputValue);
            })
        }

      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .padding({
      left: CommonConstants.PADDING_PAGE,
      right: CommonConstants.PADDING_PAGE,
      bottom: this.windowModel.windowBottomPadding
    })
  }
}
