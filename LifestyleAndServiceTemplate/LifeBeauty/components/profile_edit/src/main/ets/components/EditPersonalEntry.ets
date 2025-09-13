import { PersonalInfo } from '../types/PersonalInfo';
import { EditPersonVM } from '../viewmodels/EditPersonVM';

@ComponentV2
export struct EditPersonalInfo {
  @Param btnLabel: ResourceStr = '确认';
  @Param themeColor: ResourceColor = $r('sys.color.brand');
  @Param isNeedAgreePrivacy: boolean = false;
  @Event confirm: (value: PersonalInfo) => void = () => {};
  @Event close: () => void = () => {};

  @Local vm: EditPersonVM = new EditPersonVM();

  aboutToAppear(): void {
    this.vm.btnLabel = this.btnLabel;
    this.vm.themeColor = this.themeColor;
    this.vm.isNeedAgreePrivacy = this.isNeedAgreePrivacy;
    this.vm.confirm = this.confirm;
    this.vm.close = this.close;
    this.vm.sheetStack.pushPathByName('EditPersonalInfoCore', this.vm);
  }

  build() {
    Navigation(this.vm.sheetStack) {
    }
    .hideTitleBar(true)
    .hideNavBar(true)
  }
}