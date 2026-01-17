import { PersonalInfo } from '../types/PersonalInfo';
import { EditModel, EditPersonVM } from '../viewmodels/EditPersonVM';
import { AppStorageV2, KeyboardAvoidMode } from '@kit.ArkUI';

@ComponentV2
export struct EditPersonalInfo {
  @Param title: ResourceStr = '编辑个人信息';
  @Param btnLabel: ResourceStr = '确认';
  @Param themeColor: ResourceColor = $r('sys.color.brand');
  @Param isNeedAgreePrivacy: boolean = false;
  @Param currentBreakpoint: string = 'sm';
  @Event confirm: (value: PersonalInfo) => void = () => {};
  @Event close: () => void = () => {};

  @Local vm: EditPersonVM = new EditPersonVM();
  @Local editModel: EditModel = AppStorageV2.connect(EditModel, () => new EditModel())!;

  @Monitor('currentBreakpoint')
  onChangeBreakpoint() {
    this.editModel.currentBreakpoint = this.currentBreakpoint;
  }

  aboutToAppear(): void {
    this.vm.btnLabel = this.btnLabel;
    this.vm.themeColor = this.themeColor;
    this.vm.isNeedAgreePrivacy = this.isNeedAgreePrivacy;
    this.vm.confirm = this.confirm;
    this.vm.close = this.close;
    this.vm.title = this.title;
    this.editModel.currentBreakpoint = this.currentBreakpoint;
    this.vm.sheetStack.pushPathByName('EditPersonalInfoCore', this.vm);

    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.NONE)
  }

  aboutToDisappear(): void {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET)
  }

  build() {
    Navigation(this.vm.sheetStack) {
    }
    .hideTitleBar(true)
    .hideNavBar(true)
  }
}