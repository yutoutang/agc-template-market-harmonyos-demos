import { RouterMap, RouterUtils } from 'lib_common';
import { CommonGuidePage } from '../components/CommonGuidePage';
import { GuidePageVM } from '../viewmodels/GuidePageVM';
import { common } from '@kit.AbilityKit';

@Builder
export function GuidePageGenderBuilder() {
  GuidePage()
}

@ComponentV2
struct GuidePage {
  vm: GuidePageVM = new GuidePageVM();
  @Local gender: string = '';
  @Local selectedValue: string = '' // 记录选中值

  async aboutToAppear() {
    this.selectedValue = ''
    this.gender = ''
  }

  async aboutToDisappear() {
    this.selectedValue = ''
    this.gender = ''
  }

  onNextButtonClick() {
    const selectedGender = this.gender;
    this.vm.saveGender(this.getUIContext().getHostContext() as common.UIAbilityContext, selectedGender);
    RouterUtils.pushPathByName(RouterMap.GUIDE_PAGE_Age)
  }

  @Builder
  skipBuilder() {
    Text('跳过')
      .width(104)
      .height(40)
      .borderRadius(20)
      .fontColor($r('sys.color.font_secondary'))
      .textAlign(TextAlign.Center)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => this.vm.skipBtnClick())
  }

  @Builder
  contentBuilder() {
    Row() {
      // 第一列
      Column() {
        Image($r('app.media.ImMan'))
          .width(128)
          .margin({ left:12, bottom: 24 })
          .visibility(this.selectedValue === 'man' ? Visibility.Visible : Visibility.Hidden)

        Image($r('app.media.man'))
          .margin({ bottom: 18 })
          .size({ width: 153, height: 190 })
          .borderRadius(32)

        Radio({
          group: 'genderGroup',
          value: 'man'
        })
          .radioStyle({
            checkedBackgroundColor: $r('app.color.app_theme')
          })
          .checked(this.selectedValue === 'man')
          .onClick(() => {
            this.selectedValue = 'man'
            this.gender = '男';
          })
      }
      .margin({ right: 10 })

      // 第二列
      Column() {
        Image($r('app.media.ImWoman'))
          .width(128)
          .margin({ right:12, bottom: 24 })
          .visibility(this.selectedValue === 'woman' ? Visibility.Visible : Visibility.Hidden)

        Image($r('app.media.woman'))
          .margin({ bottom: 18 })
          .size({ width: 153, height: 190 })
          .borderRadius(32)

        Radio({
          group: 'genderGroup',
          value: 'woman'
        })
          .radioStyle({
            checkedBackgroundColor: $r('app.color.app_theme')
          })
          .checked(this.selectedValue === 'woman')
          .onClick(() => {
            this.selectedValue = 'woman'
            this.gender = '女';
          })
      }
    }
    .width('100%')
    .margin({ top: 24 })
    .justifyContent(FlexAlign.Center)
  }
  build() {
    CommonGuidePage({
      isShowSubTitle: false,
      guideTitle: '您的性别？',
      guideDesc: '信息仅用于制定更好的训练计划，我们将会严格加密！',
      isShowNextButton: true,
      customBuilderParam: () => this.contentBuilder(),
      onNextButtonClick: (): void => this.onNextButtonClick(),
      onSkipButtonClick: this.vm.skipBtnClick
    })
  }
}
