import { CommonConstants } from 'lib_common';
import { MemberGrade } from 'lib_takeaway_api/src/main/ets/database/AuthorType';
import { PrivilegeItem } from '../types/Types';
import { MineMemberCenterViewModel } from '../viewmodels/MineMemberCenterVM';

@ComponentV2
export struct PrivilegeCard {
  @Param @Require vm: MineMemberCenterViewModel;
  @Param labelSize: number = 15;

  build() {
    Grid() {
      ForEach(this.vm.privilegeList, (v: PrivilegeItem) => {
        GridItem() {
          Column({ space: CommonConstants.SPACE_M }) {
            Image(this.vm.userInfoModel.authorMemberGrade === MemberGrade.LV1 ? v.iconGrey : v.iconLight)
              .draggable(false)
              .width(CommonConstants.FULL_PERCENT)
              .height(CommonConstants.FULL_PERCENT)
              .width(60)
              .height(60)
              .borderRadius(30)

            Column({ space: CommonConstants.SPACE_S }) {
              Text(v.label)
                .fontSize(this.labelSize)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start)
              if (this.vm.userInfoModel.authorMemberGrade === MemberGrade.LV2 &&
                (v.label !== '旅行特权' && v.label !== '专属卡面')) {
                Text('已解锁')
                  .fontSize(11)
                  .fontColor('#10B981')
                  .fontWeight(FontWeight.Normal)
                  .alignSelf(ItemAlign.Center)
              } else {
                Text('待解锁')
                  .fontSize(11)
                  .fontColor($r('sys.color.gray_04'))
                  .fontWeight(FontWeight.Normal)
                  .alignSelf(ItemAlign.Center)
              }

            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

          }
          .padding({
            top: CommonConstants.PADDING_M,
            bottom: CommonConstants.PADDING_M,
            left: CommonConstants.PADDING_S,
            right: CommonConstants.PADDING_S,
          })
          .backgroundColor($r('sys.color.comp_background_primary'))
          .height(140)
          .width(100)
          .borderRadius($r('app.float.large_radius'))

        }

      }, (v: PrivilegeItem) => v.label as string)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .columnsGap(10)
    .rowsGap(10)
    .columnsTemplate('1fr 1fr 1fr') //设置一行多少个元素
    .padding({
      left: CommonConstants.PADDING_XS,
      right: CommonConstants.PADDING_XS,
      top: CommonConstants.PADDING_XS,
      bottom: CommonConstants.PADDING_XS,
    })
    .borderRadius($r('app.float.large_radius'))
    .backgroundColor($r('sys.color.comp_background_gray'))

  }

  @Styles
  normalStyles() {
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  @Styles
  pressedStyles(): void {
    .backgroundColor($r('sys.color.interactive_pressed'))
  }
}
