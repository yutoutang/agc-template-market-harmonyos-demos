import { AppStorageV2, display, window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { ToastDialog } from '@hw-agconnect/ui-toast';
import { activeMemberCard, ActiveMemberRequest, BreakpointModel, queryUserInfo, WindowUtil } from 'foundation';
import { EditPersonalInfo, PersonalInfo } from 'profile_edit'

@ComponentV2
export struct ActiveMember {
  @Param isMember: boolean = false;
  @Local showSheet: boolean = false;
  @Local keyboardHeight: number = 0;
  @Local sheetHeight: number = 600;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  private windowClass: window.Window | undefined = undefined
  private keyboardCallback = (data: number) => {
    this.keyboardHeight = this.getUIContext().px2vp(data);
  }

  @Computed
  get btnLabel() {
    return this.isMember ? '已入会' : '0元入会';
  }

  aboutToAppear(): void {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.windowClass = context.windowStage.getMainWindowSync();
    this.getSheetHeight()
    this.registerKeyboardListener()
  }

  aboutToDisappear(): void {
    this.unRegisterKeyboardListener()
  }

  registerKeyboardListener(): void {
    this.windowClass?.on('keyboardHeightChange', this.keyboardCallback);
  }

  unRegisterKeyboardListener(): void {
    this.windowClass?.off('keyboardHeightChange', this.keyboardCallback);
  }

  async getSheetHeight() {
    const displayInfo = display.getDefaultDisplaySync();
    const displayHeight = this.getUIContext().px2vp(displayInfo.height);
    const topPadding = await WindowUtil.getTopPadding();
    this.sheetHeight = displayHeight - topPadding - 56;
  }

  build() {
    Row() {
      Image($r('app.media.ic_member')).width(32).height(32)
      Text('免费入会，即享优惠')
        .fontSize(14)
        .fontWeight(500)
        .fontColor($r('app.color.common_member'))
        .margin({ left: 12 })
      Blank()

      Button() {
        Text(this.btnLabel).fontSize($r('sys.float.Body_M')).fontWeight(500)
      }
      .id('fixFocus')
      .padding({
        top: 4,
        bottom: 4,
        left: 8,
        right: 8,
      })
      .backgroundColor($r('app.color.common_member'))
      .onClick(() => {
        if (this.isMember) {
          return;
        }
        this.showSheet = true;
      })
      .bindSheet($$this.showSheet, this.fillInfoSheet(), {
        showClose: false,
        preferType: SheetType.CENTER,
        keyboardAvoidMode: SheetKeyboardAvoidMode.NONE,
        backgroundColor: $r('sys.color.background_secondary'),
        height: this.sheetHeight,
        onWillDismiss: (dismissSheetAction: DismissSheetAction) => {
          focusControl.requestFocus('fixFocus')
          if (!this.keyboardHeight) {
            dismissSheetAction.dismiss();
          }
        }
      })
    }
    .padding({left: 12, right: 12, top: 16, bottom: 16})
    .borderRadius(14)
    .backgroundColor('#1F1F20')
    .width('100%')
  }

  onSubmit(value: PersonalInfo) {
    const data: ActiveMemberRequest = {
      name: value.name,
      gender: value.gender,
      mobile: value.mobile,
      birth: value.birth || 0,
    };
    activeMemberCard(data).then(() => {
      this.showSheet = false;
      queryUserInfo();
      ToastDialog.showToast({ message: '会员卡开通成功' });
    })
  }

  @Builder
  fillInfoSheet() {
    Column() {
      EditPersonalInfo({
        title: '编辑个人信息',
        btnLabel: '同意并加入会员',
        themeColor: $r('app.color.common_theme_color'),
        isNeedAgreePrivacy: true,
        currentBreakpoint: this.breakPointModel.currentBreakpoint as string,
        confirm: (value: PersonalInfo) => {
          this.onSubmit(value);
        },
        close: () => {
          this.showSheet = false;
        },
      })
    }
    .height('100%')
  }
}