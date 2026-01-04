import { BaseViewModel } from 'lib_common';
import { MemberGrade } from 'lib_takeaway_api/src/main/ets/database/AuthorType';
import { PrivilegeItem } from '../types/Types';

@ObservedV2
export class MineMemberCenterViewModel extends BaseViewModel {
  @Trace privilegeList: PrivilegeItem[] = [
    new PrivilegeItem({
      label: '生日礼包',
      iconGrey: $r('app.media.birthday_gift_package_grey'),
      iconLight: $r('app.media.birthday_gift_package_light'),
      lockStatus: true
    },
    ),
    new PrivilegeItem({
      label: '专属折扣',
      iconGrey: $r('app.media.exclusive_discount_grey'),
      iconLight: $r('app.media.exclusive_discount_light'),
      lockStatus: true
    }),
    new PrivilegeItem({
      label: '配送优惠',
      iconGrey: $r('app.media.delivery_grey'),
      iconLight: $r('app.media.delivery_light'),
      lockStatus: true
    }),
    new PrivilegeItem({
      label: '专属客服',
      iconGrey: $r('app.media.dedicated_customer_service_grey'),
      iconLight: $r('app.media.dedicated_customer_service_light'),
      lockStatus: true
    }),
    new PrivilegeItem({
      label: '旅行特权',
      iconGrey: $r('app.media.travel_privileges'),
      iconLight: $r('app.media.travel_privileges'),
      lockStatus: true
    }),
    new PrivilegeItem({
      label: '专属卡面',
      iconGrey: $r('app.media.exclusive_card_face'),
      iconLight: $r('app.media.exclusive_card_face'),
      lockStatus: true
    }),
  ];

  @Computed
  get userIcon() {
    return this.userInfoModel.authorIcon || $r('app.media.ic_user_default');
  }

  getMemberGradeBackGroundColor(grade: string): string | Resource {
    if (grade === MemberGrade.LV1) {
      return '#FF6B6B6B'
    } else if (grade === MemberGrade.LV2) {
      return '#FFB17015'
    }
    return $r('app.color.app_theme');
  }

  getCurrentMemberGradeText(grade: string): string {
    if (grade === MemberGrade.LV1) {
      return 'lv.1 白银会员'
    } else if (grade === MemberGrade.LV2) {
      return 'lv.2 黄金会员'
    } else if (grade === MemberGrade.LV3) {
      return 'lv.3 铂金会员'
    }
    return 'lv.1 白银会员'
  }

  getNextMemberGradeText(grade: string): string {
    if (grade === MemberGrade.LV1) {
      return 'lv.2 黄金会员'
    } else if (grade === MemberGrade.LV2) {
      return 'lv.3 铂金会员'
    }
    return ''
  }

  changeMemberGradePermission(grade: string) {
    if (grade === MemberGrade.LV1) {
      for (let i = 0; i < this.privilegeList.length; i++) {
        this.privilegeList[i].lockStatus = true;
      }
    } else if (grade === MemberGrade.LV2) {
      for (let i = 0; i < 4; i++) {
        this.privilegeList[i].lockStatus = false;
      }
    }
  }
}