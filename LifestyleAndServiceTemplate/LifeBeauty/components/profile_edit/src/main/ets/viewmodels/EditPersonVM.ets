import { PersonalInfo } from '../types/PersonalInfo';

@ObservedV2
export class EditPersonVM {
  @Trace title: ResourceStr = '编辑个人信息';
  @Trace btnLabel: ResourceStr = '确认';
  @Trace themeColor: ResourceColor = Color.Blue;
  @Trace isNeedAgreePrivacy: boolean = false;
  @Trace sheetHeight: SheetSize | Length = SheetSize.MEDIUM;
  @Trace confirm: (value: PersonalInfo) => void = () => {};
  @Trace close: () => void = () => {};
  @Trace sheetStack: NavPathStack = new NavPathStack();
}

@ObservedV2
export class EditModel {
  @Trace currentBreakpoint: string = 'sm';
}