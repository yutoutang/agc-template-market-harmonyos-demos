import { BusinessError } from '@kit.BasicServicesKit';
import { GlobalContextUtils, Logger, RouterMap, RouterUtils } from 'lib_common';
import { MemberSheetUtils, MemberStatusUtil } from 'module_membership';
import { MembershipParam } from './MembershipParam';

const TAG = '[MembershipUtils]';

/**
 * 会员统一管理
 */
export class MembershipUtils {
  private params: MembershipParam = new MembershipParam();

  /**
   * 打开会员半模态弹窗
   */
  public openSheet(): void {
    MemberSheetUtils.open(this.params.getParams(true), GlobalContextUtils.globalUIContext);
  }

  /**
   * 跳转会员页面
   */
  public jumpMembershipPage(): void {
    RouterUtils.pushPathByName(RouterMap.MEMBERSHIP_PAGE, this.params.getParams(false));
  }

  /**
   * 查询是否开通会员
   * @returns
   */
  public queryMembershipStatus(): Promise<boolean> {
    return MemberStatusUtil.queryPurchase(GlobalContextUtils.globalUIAbilityContext).then((res) => {
      const autoRenewPurchasedList = res.renewList;
      const nonAutoRenewPurchasedList = res.nonRenewList;
      // 是否已开通会员
      return autoRenewPurchasedList?.length > 0 || nonAutoRenewPurchasedList?.length > 0;
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to query purchase record. Code is ${err.code}, message is ${err.message}`);
      return false;
    });
  }
}

export const membershipUtils = new MembershipUtils();
