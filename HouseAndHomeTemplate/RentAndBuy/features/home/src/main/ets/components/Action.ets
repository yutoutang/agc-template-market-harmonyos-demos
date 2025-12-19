import { common } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { Constant, CustomServiceDialog, EventEmitName, SystemUtils, UserInfo, CommonUtils } from 'foundation';

@ComponentV2
export struct Action {
  @Local isShow: boolean = false;
  @Local userInfo: UserInfo = AppStorageV2.connect(UserInfo, 'UserInfo', () => new UserInfo())!;
  @Param @Require isFavorite: number;
  @Param @Require allowFollow: boolean;
  @Param phone: string = '';
  @Event changeFavorite: () => void = () => {
  };
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
    this.context.eventHub.on(EventEmitName.MAKE_CALL, (phone: string) => {
      SystemUtils.consult(phone);
    });
    this.context.eventHub.on(EventEmitName.CANCEL_CALL, () => {
      this.isShow = false;
    });
  }

  aboutToDisappear(): void {
    this.context.eventHub.off(EventEmitName.MAKE_CALL);
    this.context.eventHub.off(EventEmitName.CANCEL_CALL);
  }

  build() {
    Row({ space: 16 }) {
      if (this.allowFollow) {
        Column({ space: 4 }) {
          Image($r('app.media.starred'))
            .size({ width: 16, height: 16 })
            .fillColor(this.isFavorite === 1 ? $r('sys.color.ohos_id_color_badge_red') : $r('sys.color.white'));
          Text('关注').fontSize(10).opacity(0.9).fontColor($r('sys.color.black'));
        }.onClick(() => {
          this.userInfo.uid ? this.changeFavorite() : CommonUtils.login();
        });
      }

      Row({ space: 2 }) {
        Image($r('app.media.call')).size({ width: 16, height: 16 }).fillColor($r('sys.color.white'));
        Text('电话咨询').fontSize(12).fontColor($r('sys.color.white'));
      }
      .backgroundColor('#64BB5C')
      .padding(8)
      .borderRadius(8)
      .onClick(() => {
        this.isShow = true;
      })
      .bindSheet($$this.isShow, CustomServiceDialog(this.phone, this.getUIContext().getHostContext()!),
        { title: { title: '预约看房' }, height: 280, preferType: SheetType.CENTER });
    }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.Start);
  }
}