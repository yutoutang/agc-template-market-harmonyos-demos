import { BreakpointModel, BreakpointNameEnum, CommonConstants, RouterMap, RouterUtils } from 'lib_common';
import { CommonGuidePage } from '../components/CommonGuidePage';
import { GuidePageVM } from '../viewmodels/GuidePageVM';
import { AppStorageV2 } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

@Builder
export function GuidePageBodyBuilder() {
  GuidePage()
}

@ComponentV2
struct GuidePage {
  vm: GuidePageVM = new GuidePageVM();
  @Local clickedStates: boolean[] = [false, false, false, false, false, false];
  @Local body: string[] = []
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  onNextButtonClick() {
    this.vm.saveBody(this.getUIContext().getHostContext() as common.UIAbilityContext, this.body); // 调用ViewModel保存数据
    RouterUtils.pushPathByName(RouterMap.GUIDE_PAGE_Injury)
  }

  @Computed
  get rightMargin() {
    if ([BreakpointNameEnum.SM].includes(this.breakPointModel.currentBreakpoint)) {
      return 14;
    }
    return 80;
  }

  @Builder
  contentBuilder() {
    Column() {
      Row() {
        Image($r('app.media.body'))
          .width(189)
          .draggable(false)
          .margin({ right: this.rightMargin })
        Column() {
          Button('全身')
            .width(120)
            .height(40)
            .fontSize($r('sys.float.Body_L'))
            .fontColor(this.clickedStates[0] ? $r('sys.color.font_on_primary') : 'rgba(0, 0, 0, 0.9)')
            .borderRadius(20)
            .backgroundColor(this.clickedStates[0] ? $r('app.color.app_theme') : $r('sys.color.comp_background_tertiary'))
            .onClick(() => {
              this.clickedStates[0] = !this.clickedStates[0]
              if (this.body.includes('全身')) {
                const index = this.body.findIndex(item => item === '全身');
                this.body.splice(index, 1);
              } else {
                this.body.push('全身');
              }
            })
            .margin({ bottom: CommonConstants.PADDING_M })
          Button('手臂')
            .width(120)
            .height(40)
            .fontSize($r('sys.float.Body_L'))
            .fontColor(this.clickedStates[1] ? $r('sys.color.font_on_primary') : 'rgba(0, 0, 0, 0.9)')
            .borderRadius(20)
            .backgroundColor(this.clickedStates[1] ? $r('app.color.app_theme') : $r('sys.color.comp_background_tertiary'))
            .onClick(() => {
              this.clickedStates[1] = !this.clickedStates[1]
              if (this.body.includes('手臂')) {
                const index = this.body.findIndex(item => item === '手臂');
                this.body.splice(index, 1);
              } else {
                this.body.push('手臂');
              }
            })
            .margin({ bottom: CommonConstants.PADDING_M })
          Button('胸肌')
            .width(120)
            .height(40)
            .fontSize($r('sys.float.Body_L'))
            .fontColor(this.clickedStates[2] ? $r('sys.color.font_on_primary') : 'rgba(0, 0, 0, 0.9)')
            .borderRadius(20)
            .backgroundColor(this.clickedStates[2] ? $r('app.color.app_theme') : $r('sys.color.comp_background_tertiary'))
            .onClick(() => {
              this.clickedStates[2] = !this.clickedStates[2]
              if (this.body.includes('胸肌')) {
                const index = this.body.findIndex(item => item === '胸肌');
                this.body.splice(index, 1);
              } else {
                this.body.push('胸肌');
              }
            })
            .margin({ bottom: CommonConstants.PADDING_M })
          Button('腹部')
            .width(120)
            .height(40)
            .fontSize($r('sys.float.Body_L'))
            .fontColor(this.clickedStates[3] ? $r('sys.color.font_on_primary') : 'rgba(0, 0, 0, 0.9)')
            .borderRadius(20)
            .backgroundColor(this.clickedStates[3] ? $r('app.color.app_theme') : $r('sys.color.comp_background_tertiary'))
            .onClick(() => {
              this.clickedStates[3] = !this.clickedStates[3]
              if (this.body.includes('腹部')) {
                const index = this.body.findIndex(item => item === '腹部');
                this.body.splice(index, 1);
              } else {
                this.body.push('腹部');
              }
            })
            .margin({ bottom: CommonConstants.PADDING_M })
          Button('背部')
            .width(120)
            .height(40)
            .fontSize($r('sys.float.Body_L'))
            .fontColor(this.clickedStates[4] ? $r('sys.color.font_on_primary') : 'rgba(0, 0, 0, 0.9)')
            .borderRadius(20)
            .backgroundColor(this.clickedStates[4] ? $r('app.color.app_theme') : $r('sys.color.comp_background_tertiary'))
            .onClick(() => {
              this.clickedStates[4] = !this.clickedStates[4]
              if (this.body.includes('背部')) {
                const index = this.body.findIndex(item => item === '背部');
                this.body.splice(index, 1);
              } else {
                this.body.push('背部');
              }
            })
            .margin({ bottom: CommonConstants.PADDING_M })
          Button('腿部')
            .width(120)
            .height(40)
            .fontSize($r('sys.float.Body_L'))
            .fontColor(this.clickedStates[5] ? $r('sys.color.font_on_primary') : 'rgba(0, 0, 0, 0.9)')
            .borderRadius(20)
            .backgroundColor(this.clickedStates[5] ? $r('app.color.app_theme') : $r('sys.color.comp_background_tertiary'))
            .onClick(() => {
              this.clickedStates[5] = !this.clickedStates[5]
              if (this.body.includes('腿部')) {
                const index = this.body.findIndex(item => item === '腿部');
                this.body.splice(index, 1);
              } else {
                this.body.push('腿部');
              }
            })
            .margin({ bottom: CommonConstants.PADDING_M })
        }
        .width(120)
        .height(300)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin({ top: 40 })
  }
  build() {
    CommonGuidePage({
      guideTitle: '您想锻炼的部位？',
      guideDesc: '选择目标部位，获得更精确的课程推荐！',
      isShowNextButton: true,
      customBuilderParam: () => this.contentBuilder(),
      onNextButtonClick: (): void => this.onNextButtonClick(),
      onSkipButtonClick: this.vm.skipBtnClick
    })
  }
}
