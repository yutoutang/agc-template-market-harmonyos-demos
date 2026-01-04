import { TargetCommonConstants, TargetType } from '../constants/TargetCommonConstants';

@ComponentV2
export struct TargetMainPage {
  @Local selectedIndex: number[] = [0, 1]; // 每列都默认选中第二个选项
  @Local textPickerShow: Visibility = Visibility.Visible
  @Local inputValue: string = '';
  @Local errorMessage: Resource = $r('app.string.Distance_remind');
  @Local isValid: boolean = true;
  @Local customTag: TargetType = TargetType.Distance
  @Local customParams: string = TargetCommonConstants.defaultDistance
  @Local units: Map<TargetType, string> = new Map<TargetType, string>([
    [TargetType.Distance, '公里'],
    [TargetType.Duration, '分钟'],
    [TargetType.Heat, '千卡'],
    [TargetType.Pace, '/公里'],
    [TargetType.Steps, '步']
  ]);
  @Param isEveryDay: boolean = true
  @Event changeSheetHeight: (sheetHeight: number) => void
  @Event parameterSet: (target: string, parameter: string) => void
  @Local numValue: number = 0
  @Local customShow: Visibility = Visibility.Visible
  private dailyGoal: TextCascadePickerRangeContent[] = [
    {
      text: '距离目标',
      children: [
        { text: '自定义' },
        { text: '1公里' },
        { text: '2公里' },
        { text: '3公里' },
        { text: '4公里' },
        { text: '5公里' },
        { text: '6公里' },
        { text: '7公里' },
        { text: '8公里' },
        { text: '9公里' },
        { text: '10公里' },
        { text: '11公里' },
        { text: '12公里' },
        { text: '13公里' },
        { text: '14公里' },
        { text: '15公里' },
        { text: '16公里' },
        { text: '17公里' },
        { text: '18公里' },
        { text: '19公里' },
        { text: '20公里' },
        { text: '21公里' },
        { text: '22公里' },
        { text: '23公里' },
        { text: '24公里' },
        { text: '25公里' },
        { text: '26公里' },
        { text: '27公里' },
        { text: '28公里' },
        { text: '29公里' },
        { text: '30公里' }]
    },
    {
      text: '步数目标',
      children: [
        { text: '自定义' },
        { text: '1000步' },
        { text: '2000步' },
        { text: '3000步' },
        { text: '4000步' },
        { text: '5000步' },
        { text: '6000步' },
        { text: '7000步' },
        { text: '8000步' },
        { text: '9000步' },
        { text: '10000步' },
        { text: '11000步' },
        { text: '12000步' },
        { text: '13000步' },
        { text: '14000步' },
        { text: '15000步' },
        { text: '16000步' },
        { text: '17000步' },
        { text: '18000步' },
        { text: '19000步' },
        { text: '20000步' }]
    },
    {
      text: '热量目标',
      children: [
        { text: '自定义' },
        { text: '50千卡' },
        { text: '100千卡' },
        { text: '150千卡' },
        { text: '200千卡' },
        { text: '250千卡' },
        { text: '300千卡' },
        { text: '350千卡' },
        { text: '400千卡' },
        { text: '450千卡' },
        { text: '500千卡' },
        { text: '550千卡' },
        { text: '600千卡' },
        { text: '650千卡' },
        { text: '700千卡' },
        { text: '800千卡' },
        { text: '850千卡' },
        { text: '900千卡' },
        { text: '1000千卡' }]
    }
  ];
  private eachTimeGoal: TextCascadePickerRangeContent[] = [
    {
      text: '距离目标',
      children: [
        { text: '自定义' },
        { text: '1公里' },
        { text: '2公里' },
        { text: '3公里' },
        { text: '4公里' },
        { text: '5公里' },
        { text: '6公里' },
        { text: '7公里' },
        { text: '8公里' },
        { text: '9公里' },
        { text: '10公里' },
        { text: '11公里' },
        { text: '12公里' },
        { text: '13公里' },
        { text: '14公里' },
        { text: '15公里' },
        { text: '16公里' },
        { text: '17公里' },
        { text: '18公里' },
        { text: '19公里' },
        { text: '20公里' },
        { text: '21公里' },
        { text: '22公里' },
        { text: '23公里' },
        { text: '24公里' },
        { text: '25公里' },
        { text: '26公里' },
        { text: '27公里' },
        { text: '28公里' },
        { text: '29公里' },
        { text: '30公里' }]
    },
    {
      text: '时间目标',
      children: [
        { text: '自定义' },
        { text: '10分钟' },
        { text: '20分钟' },
        { text: '30分钟' },
        { text: '40分钟' },
        { text: '50分钟' },
        { text: '60分钟' },
        { text: '70分钟' },
        { text: '80分钟' },
        { text: '90分钟' },
        { text: '100分钟' },
        { text: '10000步' },
        { text: '110分钟' },
        { text: '120分钟' },
        { text: '130分钟' },
        { text: '140分钟' },
        { text: '150分钟' },
        { text: '160分钟' },
        { text: '170分钟' },
        { text: '180分钟' },
        { text: '190分钟' },
        { text: '200分钟' }]
    },
    {
      text: '热量目标',
      children: [
        { text: '自定义' },
        { text: '50千卡' },
        { text: '100千卡' },
        { text: '150千卡' },
        { text: '200千卡' },
        { text: '250千卡' },
        { text: '300千卡' },
        { text: '350千卡' },
        { text: '400千卡' },
        { text: '450千卡' },
        { text: '500千卡' },
        { text: '550千卡' },
        { text: '600千卡' },
        { text: '650千卡' },
        { text: '700千卡' },
        { text: '800千卡' },
        { text: '850千卡' },
        { text: '900千卡' },
        { text: '1000千卡' }]
    },
    {
      text: '配速目标',
      children: [
        { text: '自定义' },
        { text: '3′00′′/公里' },
        { text: '4′00′′/公里' },
        { text: '5′00′′/公里' },
        { text: '6′00′′/公里' },
        { text: '7′00′′/公里' },
        { text: '8′00′′/公里' },
        { text: '9′00′′/公里' },
        { text: '10′00′′/公里' }]
    }
  ];

  // 验证方法
  validateInput(value: string): void {
    if (value === '') {
      this.isValid = false;
      return;
    }
    if (this.customTag === TargetType.Pace) {
      this.omCustomTagPace(value)
      return;
    }

    // 转换为数字
    if (this.customTag === TargetType.Distance) {
      this.numValue = Number(value.replace(/[^\d.]/g, ''));
    } else {
      this.numValue = parseInt(value);
    }
    // 验证是否为有效数字
    if (isNaN(this.numValue)) {
      this.isValid = false;
      return;
    }

    // 验证范围
    if (this.validateRange(value)) {
      return;
    }
    this.customParams = value + this.units.get(this.customTag) ?? ''
    this.isValid = true;
  }

  // 验证范围
  validateRange(value: string): boolean {
    if (this.customTag === TargetType.Distance &&
      (this.numValue < TargetCommonConstants.NUMBER_0x1 || this.numValue > TargetCommonConstants.NUMBER_100) ||
      this.customTag === TargetType.Heat &&
        (this.numValue < TargetCommonConstants.NUMBER_100 || this.numValue > TargetCommonConstants.NUMBER_5000) ||
      this.customTag === TargetType.Steps &&
        (this.numValue < TargetCommonConstants.NUMBER_1000 || this.numValue > TargetCommonConstants.NUMBER_50000) ||
      this.customTag === TargetType.Duration &&
        (this.numValue < TargetCommonConstants.NUMBER_10 || this.numValue > TargetCommonConstants.NUMBER_600)) {
      this.isValid = false;
      return true
    }
    return false
  }

  omCustomTagPace(value: string) {
    let result1: string[] = value.split(/\s+/)
    if (result1.length > 2) {
      this.isValid = false;
      return;
    }
    if (!this.areAllStringsNumbers(result1)) {
      this.isValid = false;
      return;
    }
    if (Number(result1[0]) < 3 || Number(result1[0]) > 40 ||
      result1.length === 2 && (Number(result1[1]) < 0 || Number(result1[1]) > 60)) {
      this.isValid = false;
      return;
    }
    this.customParams =
      result1[0] + '′' + ((result1.length === 2 ? result1[1] : '00') + '″') + this.units.get(this.customTag) ?? ''
    this.isValid = true;
    return
  }

  areAllStringsNumbers(strList: string[]): boolean {
    return strList.every(str => {
      const num = parseInt(str, 10);
      return !isNaN(num) && num.toString() === str.trim();
    });
  }

  build() {
    Column() {
      this.TitleBuild()
      Column() {
        this.TextPickerBuild()
        this.InputBuild()
      }
      .width(TargetCommonConstants.PERCENT_100)
      .justifyContent(FlexAlign.Center)
    }.padding({ left: TargetCommonConstants.NUMBER_16, right: TargetCommonConstants.NUMBER_16 })
  }

  // 标题
  @Builder
  TitleBuild() {
    Text($r('app.string.set_target'))
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .margin({ left: $r('app.float.vp_20'), top: $r('app.float.vp_28') })
      .width(TargetCommonConstants.PERCENT_100)
      .textAlign(TextAlign.Start)
      .visibility(this.textPickerShow)
  }

  // 选择器
  @Builder
  TextPickerBuild() {
    Column() {
      TextPicker({ range: this.isEveryDay ? this.dailyGoal : this.eachTimeGoal, selected: this.selectedIndex })
        .canLoop(false)
        .textStyle({ color: Color.Black, font: { size: TargetCommonConstants.NUMBER_16, weight: FontWeight.Normal } })
        .selectedTextStyle({
          color: Color.Black,
          font: { size: TargetCommonConstants.NUMBER_20, weight: FontWeight.Bolder }
        })
        .width(TargetCommonConstants.PERCENT_90)
        .onChange((value: string | string[], index: number | number[]) => {
          let selectIndex = typeof index === 'number' ? [1, 1] : index
          let selectValue = typeof index === 'string' ? '' : value
          if (this.isEveryDay) {
            this.customTag = [TargetType.Distance, TargetType.Steps, TargetType.Heat][selectIndex[0]]
          } else {
            this.customTag =
              [TargetType.Distance, TargetType.Duration, TargetType.Heat, TargetType.Pace][selectIndex[0]]
          }
          if (selectValue[1] !== TargetCommonConstants.custom) {
            this.customParams = selectValue[1]
          } else {
            if (this.isEveryDay) {
              this.customParams = this.customTag === TargetType.Distance ? TargetCommonConstants.defaultDistance :
                this.customTag === TargetType.Steps ? TargetCommonConstants.defaultSteps :
                  TargetCommonConstants.defaultHeat
            } else {
              this.customParams = this.customTag === TargetType.Distance ? TargetCommonConstants.defaultDistance :
                this.customTag === TargetType.Duration ? TargetCommonConstants.defaultDuration :
                  this.customTag === TargetType.Heat ? TargetCommonConstants.defaultHeat :
                    TargetCommonConstants.defaultPace
            }
          }
          if (selectIndex[0] === this.selectedIndex[0]) {
            this.selectedIndex = [selectIndex[0], selectIndex[1]]
            if (selectIndex[1] === 0) {
              this.textPickerShow = Visibility.None
              this.selectedIndex = [selectIndex[0], 1]
              this.changeSheetHeight(280)
            }
          } else {
            this.selectedIndex = [selectIndex[0], 1]
          }
          if (this.isEveryDay) {
            this.errorMessage = [$r('app.string.Distance_remind'), $r('app.string.Steps_remind'),
              $r('app.string.Heat_remind')][selectIndex[0]]
          } else {
            this.errorMessage = [$r('app.string.Distance_remind'), $r('app.string.Duration_remind'),
              $r('app.string.Heat_remind'), $r('app.string.Pace_remind')][selectIndex[0]]
          }
        })

      Text($r('app.string.save'))
        .width(TargetCommonConstants.PERCENT_80)
        .height($r('app.float.vp_40'))
        .textAlign(TextAlign.Center)
        .fontColor(Color.White)
        .borderRadius(TargetCommonConstants.NUMBER_20)
        .backgroundColor($r('app.color.FC7A17'))
        .margin({ top: TargetCommonConstants.NUMBER_20 })
        .onClick(() => {
          this.parameterSet(this.customTag, this.customParams)
        })
    }
    .visibility(this.textPickerShow)
  }

  // 自定义输入框
  @Builder
  InputBuild() {
    Column() {
      Column() {
        Text(this.customTag)
          .fontSize(TargetCommonConstants.NUMBER_16)
        // 输入框
        TextInput({
          text: this.inputValue,
          placeholder: this.customTag === TargetType.Pace ? TargetCommonConstants.paceHint : ''
        })
          .width(TargetCommonConstants.PERCENT_100)
          .height(TargetCommonConstants.NUMBER_40)
          .backgroundColor(Color.Transparent)// 透明背景
          .border({ width: TargetCommonConstants.NUMBER_0 })// 无边框
          .type((this.customTag !== TargetType.Pace && this.customTag !== TargetType.Distance) ? InputType.Number :
            InputType.Normal)// 数字键盘
          .enterKeyType(EnterKeyType.Done)// 完成按钮
          .maxLength(8)// 最大长度5位
          .margin({ top: TargetCommonConstants.NUMBER_5 })
          .padding(TargetCommonConstants.NUMBER_0)
          .onChange((value: string) => {
            this.inputValue = value
          })

        // 下划线
        Divider()
          .strokeWidth('1px')

        Text(this.errorMessage)
          .fontSize(12)
          .fontColor(this.isValid ? Color.Black : Color.Red)
          .margin({ top: 3 })
          .opacity(0.6)
      }
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(Color.White)
      .padding(20)
      .borderRadius(20)

      Row() {
        Text($r('app.string.Cancel'))
          .textStyle()
          .fontColor($r('app.color.000000'))
          .opacity(0.6)
          .backgroundColor(Color.White)
          .onClick(() => {
            this.inputValue = ''
            this.textPickerShow = Visibility.Visible
            this.isValid = true
            this.changeSheetHeight(350)
          })

        Text($r('app.string.Confirm'))
          .textStyle()
          .backgroundColor($r('app.color.FC7A17'))
          .fontColor(Color.White)
          .onClick(() => {
            this.validateInput(this.inputValue);
            if (this.isValid) {
              this.parameterSet(this.customTag, this.customParams)
            }
            this.inputValue = ''
          })
      }
      .width(TargetCommonConstants.PERCENT_100)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .visibility(this.textPickerShow === Visibility.Visible ? Visibility.None : Visibility.Visible)
    .borderRadius(TargetCommonConstants.NUMBER_20)
    .width(TargetCommonConstants.PERCENT_90)
    .alignItems(HorizontalAlign.Start)
    .margin({ top: TargetCommonConstants.NUMBER_65 })
  }
}

@Extend(Text)
function textStyle() {
  .width(TargetCommonConstants.PERCENT_40)
  .height($r('app.float.vp_40'))
  .textAlign(TextAlign.Center)
  .borderRadius(TargetCommonConstants.NUMBER_20)
  .margin({ top: TargetCommonConstants.NUMBER_20, right: TargetCommonConstants.PERCENT_5 })
}