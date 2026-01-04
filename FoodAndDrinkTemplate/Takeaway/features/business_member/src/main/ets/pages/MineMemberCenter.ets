import { CommonConstants } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { MineMemberCenterViewModel } from '../viewmodels/MineMemberCenterVM';
import { CircleShape } from '@kit.ArkUI';
import { PrivilegeCard } from '../components/PrivilegeCard';
import { MemberGrade } from 'lib_takeaway_api/src/main/ets/database/AuthorType';

@Builder
export function MineMemberCenterBuilder() {
  MineMemberCenter()
}

@ComponentV2
struct MineMemberCenter {
  @Local vm: MineMemberCenterViewModel = new MineMemberCenterViewModel();

  build() {
    NavDestination() {
      Column() {
        Column() {
          NavHeaderBar({
            title: '会员中心',
            isSubTitle: true,
            rightPartBuilder: () => {
              this.refreshMemberGradeBuilder()
            }
          })
          Row({ space: CommonConstants.SPACE_L }) {
            Image(this.vm.userIcon)
              .width($r('app.float.user_icon_width'))
              .clipShape(new CircleShape({ width: 48, height: 48 }))
              .draggable(false)
            Text(this.vm.userInfoModel.authorNickName)
              .fontSize(18 * this.vm.settingInfo.fontSizeRatio)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Bold)

            Button(this.vm.userInfoModel.authorMemberGrade)
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_on_primary'))
              .backgroundColor(this.vm.getMemberGradeBackGroundColor(this.vm.userInfoModel.authorMemberGrade))
              .height(28)
          }
          .padding({
            left: CommonConstants.PADDING_XXL,
            right: CommonConstants.PADDING_XXL,
            top: CommonConstants.PADDING_M,
            bottom: CommonConstants.PADDING_M
          })
          .width(CommonConstants.FULL_PERCENT)
        }
        .backgroundImage($r('app.media.member_background'))
        .backgroundImageSize(1)
        .backgroundImageSize(ImageSize.Cover)

        Scroll() {
          Column({ space: CommonConstants.SPACE_S }) {
            //会员权益说明
            Column({ space: CommonConstants.SPACE_L }) {
              Text('会员权益说明')
                .fontSize(15 * this.vm.settingInfo.fontSizeRatio)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Bold)
                .alignSelf(ItemAlign.Start)
              Text('我们的会员体系分为三个等级：白银、黄金、铂金。等级越高，享受的专属权益越丰富。通过购物消费可累计成长值，达到相应的成长值可升级会员等级，享受更多特权。')
                .fontSize(13 * this.vm.settingInfo.fontSizeRatio)
                .letterSpacing(2)//字间距
                .fontColor($r('sys.color.font_secondary'))
                .fontWeight(FontWeight.Regular)

            }
            .borderRadius($r('app.float.large_radius'))
            .padding(CommonConstants.PADDING_M)
            .backgroundColor($r('sys.color.background_primary'))
            .width(CommonConstants.FULL_PERCENT)

            //会员等级
            Column({ space: CommonConstants.SPACE_L }) {
              Row() {
                Text(this.vm.getCurrentMemberGradeText(this.vm.userInfoModel.authorMemberGrade))
                Blank()
                Text(this.vm.getNextMemberGradeText(this.vm.userInfoModel.authorMemberGrade))
                  .fontColor($r('sys.color.font_secondary'))
              }.width(CommonConstants.FULL_PERCENT)

              Progress({ value: this.vm.userInfoModel.authorMemberGradeEXP, total: 100, type: ProgressType.Linear })
                .style({ strokeWidth: '4vp', enableSmoothEffect: true })
                .color($r('sys.color.comp_background_emphasize'))

              Text('升级还需要消费¥1200')
                .fontSize(14 * this.vm.settingInfo.fontSizeRatio)
                .fontColor($r('sys.color.font_secondary'))

            }
            .borderRadius($r('app.float.large_radius'))
            .padding(CommonConstants.PADDING_M)
            .backgroundColor($r('sys.color.background_primary'))
            .width(CommonConstants.FULL_PERCENT)

            //会员权益
            Row() {
              Text('会员特权')
                .fontSize(15 * this.vm.settingInfo.fontSizeRatio)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Bold)

            }.alignSelf(ItemAlign.Start)
            .padding(CommonConstants.PADDING_S)

            //权益卡片
            PrivilegeCard({ vm: this.vm })

          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .width(CommonConstants.FULL_PERCENT)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring)
        .padding({
          left: CommonConstants.PADDING_XL,
          right: CommonConstants.PADDING_XL,
          bottom: CommonConstants.PADDING_XL,
          top: CommonConstants.PADDING_XL
        })
        .backgroundColor($r('sys.color.background_secondary'))

      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('sys.color.background_tertiary'))

    }
    .hideTitleBar(true)
  }

  @Builder
  refreshMemberGradeBuilder() {
    Row() {
      Text('刷新消费额度')
        .fontSize(16)
        .fontWeight(300)
        .fontColor('#E6000000')
        .onClick(() => {
          this.refreshMemberGrade()
        })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
  }

  refreshMemberGrade() {
    this.vm.userInfoModel.authorMemberGrade = MemberGrade.LV2
    this.vm.userInfoModel.authorMemberGradeEXP = 20
    this.vm.changeMemberGradePermission(MemberGrade.LV2)
  }
}