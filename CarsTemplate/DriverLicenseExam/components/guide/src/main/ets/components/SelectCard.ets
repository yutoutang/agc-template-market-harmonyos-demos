import { LICENSE_TYPE } from '../model/model'
import { GuideService } from '../model/GuideService'

const GROUP = 'radioGroup';

@ComponentV2
export struct SelectCard {
  guideService: GuideService = GuideService.instance;
  @Param value: LICENSE_TYPE = 0;
  @Param contentWidth: number = 0;
  @Builder
  contentSlot() {}
  @BuilderParam
  contentBuilder:() => void = this.contentSlot;

  hasSelect():boolean {
    return this.guideService.getGuideData().licenseType === this.value;
  }

  build() {
    RelativeContainer() {
      this.contentBuilder()

      if (this.hasSelect()) {
        Radio({ value: String(this.value), group: GROUP }).checked(this.hasSelect())
          .radioStyle({
            checkedBackgroundColor: $r('sys.color.comp_background_emphasize')
          })
          .height(20)
          .width(20)
          .onChange((isChecked: boolean) => {
            console.log('Radio1 status is ' + isChecked)
          })
          .alignRules({
            top: {'anchor':'__container__', 'align': VerticalAlign.Top},
            right:  {'anchor':'__container__', 'align': HorizontalAlign.End}
          })
          .offset({
            x: -2,
            y: 2,
          })
      }

    }
    .backgroundColor(Color.White)
    .borderRadius(20)
    .border({
      width: 2,
      color: this.hasSelect()?'#64BB5C':'#fff'
    })
    .height(102)
    .width(this.contentWidth || undefined)
    .layoutWeight(this.contentWidth?undefined:1)
  }
}