import { RouterMap, RouterUtils } from 'lib_common';
import { GuidePageVM } from '../viewmodels/GuidePageVM';
import { CommonGuidePage } from '../components/CommonGuidePage';

@Builder
export function GuidePageTargetBuilder() {
  GuidePage()
}

@ComponentV2
struct GuidePage {
  vm: GuidePageVM = new GuidePageVM();
  @Local targetWeight: string = ''

  inputBodyData() {
    if (Number.parseFloat(this.targetWeight) < 30 || Number.parseFloat(this.targetWeight) > 300) {
      this.getUIContext().getPromptAction().showToast({ message: '目标体重需要在30-300kg之间' });
      return
    }
    this.vm.saveTargetWeight(this.targetWeight); // 调用ViewModel保存数据
    RouterUtils.pushPathByName(RouterMap.GUIDE_PAGE_Purpose)
  }

  @Builder
  contentBuilder() {
    Column() {
      Text('目标体重')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .margin({
          top: 40,
          bottom: 12,
        })
      Stack({ alignContent: Alignment.End }) {
        TextInput({
          placeholder: '请在此输入您的目标体重',
          text: this.targetWeight // 绑定状态变量
        })
          .type(InputType.Number)
          .onChange((value: string) => { // 监听输入变化
            this.targetWeight = value.replace(/[^0-9]/g, '') // 过滤非数字字符
          })
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
        Text('(kg)')
          .fontColor('#666')
          .margin({ top: 4, right: 16 })
      }
      .margin({
        bottom: 24,
      })
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .margin({ left: 16, right: 16 })
  }

  build() {
    CommonGuidePage({
      guideTitle: '您的目标体重？',
      guideDesc: '信息仅用于制定更好的训练计划，我们将会严格加密！',
      isShowNextButton: true,
      customBuilderParam: () => this.contentBuilder(),
      onNextButtonClick: (): void => this.inputBodyData(),
      onSkipButtonClick: this.vm.skipBtnClick
    })
  }
}
