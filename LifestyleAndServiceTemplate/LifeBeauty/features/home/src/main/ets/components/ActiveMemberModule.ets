import { activeMemberCard, ActiveMemberRequest, queryUserInfo } from 'foundation';
import { EditPersonalInfo, PersonalInfo } from 'profile_edit'

@ComponentV2
export struct ActiveMember {
  @Local showSheet: boolean = false;

  build() {
    Row() {
      Image($r('app.media.ic_member')).width(28).height(24)
      Text('成为会员，尊享专属特权')
        .fontSize(14)
        .fontWeight(500)
        .fontColor($r('app.color.common_member'))
        .margin({ left: 15 })
      Blank()

      Button() {
        Text('立即开卡').fontSize($r('sys.float.Body_M')).fontWeight(500)
      }
      .padding({
        top: 4,
        bottom: 4,
        left: 8,
        right: 8,
      })
      .backgroundColor($r('app.color.common_member'))
      .onClick(() => {
        this.showSheet = true;
      })
      .bindSheet($$this.showSheet, this.fillInfoSheet(), {
        showClose: false,
        backgroundColor: $r('sys.color.background_secondary'),
        height: 560,
      })
    }
    .padding(16)
    .borderRadius(8)
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
      this.getUIContext().getPromptAction().showToast({ message: '会员卡开通成功' });
    })
  }

  @Builder
  fillInfoSheet() {
    Column() {
      EditPersonalInfo({
        btnLabel: '同意并加入会员',
        themeColor: $r('app.color.common_theme_color'),
        isNeedAgreePrivacy: true,
        confirm: (value: PersonalInfo) => {
          this.onSubmit(value);
        },
        close: () => {
          this.showSheet = false;
        },
      })
    }
  }
}