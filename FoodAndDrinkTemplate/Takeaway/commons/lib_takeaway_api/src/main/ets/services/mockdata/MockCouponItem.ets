import { StoreEnum } from '../../constants/Constants';
import { CouponItem, CouponModel, CouponRule } from '../../params/response/GetCouponsResp';

class CommonRules {
  // 满减-低
  static readonly RULE_LOW: CouponRule = {
    amountRuleNo: '1',
    amountRuleDesc: '满减',
    discountMode: '0',
    discountType: '0',
    fullAmount: '35',
    discountAmount: '4',
    discountCoefficient: '',
  }
}

export class MockCouponItem {
  static list: CouponItem[] = [
  // 生效-待使用-活动期间-满减-低
    new CouponModel('1', '优惠券名称', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.FOOD, '',
      '', '', '2', [], [{ key: 0, value: '新用户注册' }], '', '', '1'),
    // 生效-待使用-活动期间-满减-高
    new CouponModel('100', '优惠券名称', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.FOOD, '',
      '', '', '2', [], [{ key: 0, value: '新用户注册' }], '', '', '1'),
    // 生效-待使用-活动期间-立减
    new CouponModel('2', '优惠券名称', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.FOOD,
      '', '', '',
      '2', [], [{ key: 0, value: '新用户注册' }], '', '', '1'),
    // 生效-待使用-活动期间-折扣
    new CouponModel('3', '优惠券名称', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.ALL,
      '', '', '',
      '2', [], [{ key: 0, value: '新用户注册' }], '', '', '1'),
    // 生效-待使用-活动期前-满减
    new CouponModel('4', '优惠券名称', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.SUPERMARKET, '',
      '', '', '2', [], [{ key: 0, value: '新用户注册' }], '', '', '1'),
    // 生效-待使用-活动期前-立减
    new CouponModel('5', '优惠券名称', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.SUPERMARKET, '', '', '',
      '2', [], [{ key: 0, value: '新用户注册' }], '', '', '1'),
    // 生效-待使用-活动期前-折扣
    new CouponModel('6', '优惠券名称', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.SUPERMARKET, '', '', '',
      '2', [], [{ key: 0, value: '新用户注册' }], '', '', '1'),
    // 生效-已使用-满减
    new CouponModel('7', '优惠券名称', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.SUPERMARKET, '',
      '', '', '2', [], [{ key: 0, value: '新用户注册' }], '', '', '1'),
    // 生效-已使用-立减
    new CouponModel('8', '优惠券名称', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.SUPERMARKET, '', '', '',
      '2', [], [{ key: 0, value: '新用户注册' }], '', '', '1'),
    // 生效-已使用-折扣
    new CouponModel('9', '优惠券名称', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.FRUIT,
      '', '',
      '',
      '2', [], [{ key: 0, value: '新用户注册' }], '', '', '1'),
    // 生效-已过期-满减
    new CouponModel('10', '优惠券名称', '0', '2025-1-1', '2035-2-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.FRUIT, '',
      '', '', '2', [], [{ key: 0, value: '新用户注册' }], '', '', '1'),
    // 生效-已过期-立减
    new CouponModel('11', '优惠券名称', '0', '2025-1-1', '2035-2-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.FRUIT,
      '', '',
      '', '2', [], [{ key: 0, value: '新用户注册' }], '', '', '1'),
    // 生效-已过期-折扣
    new CouponModel('12', '优惠券名称', '0', '2025-1-1', '2035-2-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.PHARMACY, '',
      '',
      '', '2', [], [{ key: 0, value: '新用户注册' }], '', '', '1'),
  ];
  //待领取
  static toBeClaimedList: CouponItem[] = [
    new CouponModel('111', '手动领取1', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.FOOD, '',
      '', '', '2', [], [{ key: 0, value: '新用户注册' }], '', '', '0'),
    new CouponModel('112', '手动领取2', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.FOOD, '',
      '', '', '2', [], [{ key: 0, value: '新用户注册' }], '', '', '0'),
    new CouponModel('113', '手动领取3', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.ALL,
      '', '', '',
      '2', [], [{ key: 0, value: '新用户注册' }], '', '', '0'),
    // 生效-待使用-活动期前-满减
    new CouponModel('114', '手动领取4', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.SUPERMARKET, '',
      '', '', '2', [], [{ key: 0, value: '新用户注册' }], '', '', '0'),
    // 生效-待使用-活动期前-立减
    new CouponModel('115', '手动领取5', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.SUPERMARKET, '', '', '',
      '2', [], [{ key: 0, value: '新用户注册' }], '', '', '0'),
    // 生效-待使用-活动期前-折扣
    new CouponModel('116', '手动领取6', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.SUPERMARKET, '', '', '',
      '2', [], [{ key: 0, value: '新用户注册' }], '', '', '0'),
    new CouponModel('119', '手动领取7', '0', '2025-1-1', '2035-1-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.FRUIT,
      '', '',
      '',
      '2', [], [{ key: 0, value: '新用户注册' }], '', '', '0'),
    // 生效-已过期-满减
    new CouponModel('120', '手动领取8', '0', '2025-1-1', '2035-2-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.FRUIT, '',
      '', '', '2', [], [{ key: 0, value: '新用户注册' }], '', '', '0'),
    // 生效-已过期-折扣
    new CouponModel('121', '手动领取8', '0', '2025-1-1', '2035-2-1', '2', CommonRules.RULE_LOW, '-1', '0',
      StoreEnum.PHARMACY, '',
      '',
      '', '2', [], [{ key: 0, value: '新用户注册' }], '', '', '0'),
  ];
}