import { RouterMap, RouterUtils } from 'lib_common';
import { GuidePageVM } from '../viewmodels/GuidePageVM';
import { CommonGuidePage } from '../components/CommonGuidePage';
import { common } from '@kit.AbilityKit';

@Builder
export function GuidePageDataBuilder() {
  GuidePage()
}

@ComponentV2
struct GuidePage {
  vm: GuidePageVM = new GuidePageVM();
  @Local dataHeight: string = '';
  @Local dataWeight: string = '';

  inputBodyData() {
    if (Number.parseFloat(this.dataWeight) < 30 || Number.parseFloat(this.dataWeight) > 300) {
      this.getUIContext().getPromptAction().showToast({ message: '体重需要在30-300kg之间' });
      return
    }
    if (Number.parseFloat(this.dataHeight) < 100 || Number.parseFloat(this.dataHeight) > 250) {
      this.getUIContext().getPromptAction().showToast({ message: '身高需要在100-250cm之间' });
      return
    }
    this.vm.saveWeight(this.getUIContext().getHostContext() as common.UIAbilityContext, this.dataWeight);
    this.vm.saveHeight(this.getUIContext().getHostContext() as common.UIAbilityContext, this.dataHeight);
    RouterUtils.pushPathByName(RouterMap.GUIDE_PAGE_Target)
  }

  @Builder
  contentBuilder() {
    Column() {
      Text('您的身高')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .margin({
          bottom: 12,
        })
      Stack({ alignContent: Alignment.End }) {
        TextInput({
          placeholder: '请在此输入您的身高',
          text: this.dataHeight, // 绑定状态变量
        })
          .type(InputType.Number)
          .onChange((value: string) => { // 监听输入变化
            this.dataHeight = value.replace(/[^0-9]/g, '') // 过滤非数字字符
          })
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
        Text('(cm)')
          .fontColor('#666')
          .margin({ top: 4, right: 16 })
      }
      .margin({
        bottom: 24,
      })
      Text('您的体重')
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .margin({
          bottom: 12,
        })
      Stack({ alignContent: Alignment.End }) {
        TextInput({
          placeholder: '请在此输入您的体重',
          text: this.dataWeight // 绑定状态变量
        })
          .type(InputType.Number)
          .onChange((value: string) => { // 监听输入变化
            this.dataWeight = value.replace(/[^0-9]/g, '') // 过滤非数字字符
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
    .margin({ left: 16, right: 16, top: 40 })
  }

  build() {
    CommonGuidePage({
      guideTitle: '您的身体基本数据？',
      guideDesc: '信息仅用于制定更好的训练计划，我们将会严格加密！',
      isShowNextButton: true,
      customBuilderParam: () => this.contentBuilder(),
      onNextButtonClick: (): void => this.inputBodyData(),
      onSkipButtonClick: this.vm.skipBtnClick
    })
  }
}
