import { PersonalInfo } from '../models/PersonalInfo';
import { hilog } from '@kit.PerformanceAnalysisKit';

@ObservedV2
export class EditPersonVM {
  @Trace btnLabel: ResourceStr = '确认';
  @Trace themeColor: ResourceColor = Color.Blue;
  @Trace sheetHeight: SheetSize | Length = SheetSize.MEDIUM;
  @Trace confirm: (value: PersonalInfo) => void = () => {
    hilog.info(0x0000, 'testTag', '%{public}s', 'it begin');
  };
  @Trace close: () => void = () => {
    hilog.info(0x0000, 'testTag', '%{public}s', 'it begin');
  };
  @Trace sheetStack: NavPathStack = new NavPathStack();
}

@ObservedV2
export class BmiStore {
  @Trace bmiValue: number = -1
  @Trace physicalState: string = ''
  @Trace healthAnalysis: string = '';
  @Trace healthTips: string = '';

  getPersistenceName(): string {
    return 'SearchHistory';
  }

  toJson(): string {
    return JSON.stringify({
      bmiValue: this.bmiValue,
      physicalState: this.physicalState,
      healthAnalysis: this.healthAnalysis,
      healthTips: this.healthTips
    });
  }

  fromJson(json: string): void {
    const obj = JSON.parse(json) as Partial<BmiStore>;
    this.bmiValue = obj.bmiValue ?? 0;
    this.physicalState = obj.physicalState ?? '';
    this.healthAnalysis = obj.healthAnalysis ?? '';
    this.healthTips = obj.healthTips ?? '';
  }
}

@ObservedV2
export class UserInfo {
  @Trace weight: string = '';
  @Trace userheight: string = '';
  @Trace gender: string = '';
  @Trace birth: number = 0;

  getPersistenceName(): string {
    return 'SearchHistory';
  }

  toJson(): string {
    return JSON.stringify({
      weight: this.weight,
      userheight: this.userheight,
      gender: this.gender,
      birth: this.birth
    });
  }

  fromJson(json: string): void {
    const obj = JSON.parse(json) as Partial<UserInfo>;
    this.weight = obj.weight ?? '';
    this.userheight = obj.userheight ?? '0';
    this.gender = obj.gender ?? '';
    this.birth = obj.birth ?? 0;
  }
}