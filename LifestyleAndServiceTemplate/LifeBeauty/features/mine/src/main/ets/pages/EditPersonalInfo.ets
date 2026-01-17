import { PersonalInfoView } from 'collect_personal_info';
import { CommonConstants } from 'foundation';
import { EditPersonalInfoVM } from '../viewmodels/EditPersonalInfoVM';

@Builder
export function EditPersonalInfoBuilder() {
  EditPersonalInfo()
}

@ComponentV2
struct EditPersonalInfo {
  @Local vm: EditPersonalInfoVM = new EditPersonalInfoVM();

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 12 }) {
          PersonalInfoView({
            list: this.vm.list,
          })
        }
        .padding({
          top: 12,
          left: 16,
          right: 16,
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title('个人信息', { backgroundColor: Color.White })
    .onBackPressed(() => {
      return this.vm.customBack();
    })
  }
}
