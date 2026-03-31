import { User } from '@ohos_agcit/children_education_datasource';
import { AvoidArea, BreakpointType, CommonConstants, GlobalInfoModel } from '@ohos_agcit/children_education_utils';
import { CommonServices } from '../components/CommonServices';
import { LoginState } from '../components/LoginState';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct MinePage {
  @Consumer(CommonConstants.USER_INFO) user: User = new User();
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('我的')
          .fontSize(24)
          .fontFamily('鸿蒙黑体')
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.black'));
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(36);
      Scroll() {
        Column({space:12}) {
          LoginState();

          CommonServices();
        }
      }

    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .padding({
      top: this.getUIContext().px2vp(this.avoidArea.topRectHeight),
      left: new BreakpointType<number>({
        sm: 16,
        md: 24,
        lg: 32,
      }).getValue(this.globalInfo.currentBreakpoint),
      right: new BreakpointType<number>({
        sm: 16,
        md: 24,
        lg: 32,
      }).getValue(this.globalInfo.currentBreakpoint),
      bottom:52

    })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}