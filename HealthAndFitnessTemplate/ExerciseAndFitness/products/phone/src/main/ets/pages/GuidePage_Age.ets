import { CommonConstants, RouterMap, RouterUtils } from 'lib_common';
import { CommonGuidePage } from '../components/CommonGuidePage';
import { GuidePageVM } from '../viewmodels/GuidePageVM';
import { common } from '@kit.AbilityKit';

@Builder
export function GuidePageAgeBuilder() {
  GuidePage()
}

@ComponentV2
struct GuidePage {
  vm: GuidePageVM = new GuidePageVM();
  private ageOptions: number[] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,
    26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,
    51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,
    76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99];  // 年龄选项数组
  private agePicker: string[] = this.ageOptions.map(item => item.toString());
  selectedIndex: number = 17;  // 默认选中项索引

  onNextButtonClick() {
    const selectedAge = this.agePicker[this.selectedIndex];
    this.vm.saveAge(this.getUIContext().getHostContext() as common.UIAbilityContext, selectedAge); // 调用ViewModel保存数据
    RouterUtils.pushPathByName(RouterMap.GUIDE_PAGE_Data)
  }

  @Builder
  contentBuilder() {
    TextPicker({ range: this.agePicker, selected: this.selectedIndex })
      .canLoop(false)  // 禁用循环滚动
      .height(200)     // 设置选择器高度.textStyle({ color: Color.Black, font: { size: 20, weight: FontWeight.Normal } })
      .textStyle({ color: Color.Black, font: { size: 16, weight: FontWeight.Normal } })
      .selectedTextStyle({ color: $r('app.color.app_theme'), font: { size: 18, weight: FontWeight.Bolder } })
      .onChange((value: string | string[], index: number | number[]) => {
        this.selectedIndex = index as number
      })
      .margin({ left: 129, right: 129, top: 70 })
      .padding({
        left: CommonConstants.PADDING_PAGE,
        right: CommonConstants.PADDING_PAGE
      })
  }

  build() {
    CommonGuidePage({
      guideTitle: '您的年龄？',
      guideDesc: '信息仅用于制定更好的训练计划，我们将会严格加密！',
      isShowNextButton: true,
      customBuilderParam: () => this.contentBuilder(),
      onNextButtonClick: (): void => this.onNextButtonClick(),
      onSkipButtonClick: this.vm.skipBtnClick
    })
  }
}
