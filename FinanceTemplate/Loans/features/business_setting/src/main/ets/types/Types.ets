import { RouterMap } from 'lib_common';

export interface ISelectOption {
  id: number;
  label: string;
}

export interface ISettingItem {
  icon?: ResourceStr;
  label: ResourceStr;
  subLabel?: ResourceStr;
  routerName?: RouterMap;
  routerParams?: Object;
  typeSwitch?: boolean;
  typeSelect?: boolean;
  switchV?: boolean;
  selectV?: number;
  selectOptions?: ISelectOption[];
  selectTitle?: string;
  extraLabel?: ResourceStr;
  onClick?: (param?: Object) => void;
  onSelect?: (param?: Object) => void;
}
export interface MineGridItem {
  icon: ResourceStr;
  label: ResourceStr;
  routerName: RouterMap ;
}
export enum TabType {
  /**
   * 常见问题
   */
  Question = 'question',
  /**
   * 借款相关
   */
  Loan = 'loan',
  /**
   * 防骗指南
   */
  AntiFraud = 'anti_fraud',

}

export interface TabInfo {
  id: TabType
  text: string
  selected: boolean
}


export interface QuestionInfo {
  id: number;
  text: string;
  desc: string;

}

@ObservedV2
export class FraudReportInfo {
  id: number;
  title: string;
  @Trace isSelect: boolean;
  constructor(id: number, title: string, isSelect: boolean) {
    this.id = id;
    this.title = title;
    this.isSelect = isSelect;
  }
}

export const fraudReportList: FraudReportInfo[] = [
  new FraudReportInfo(0, '短信诈骗', false),
  new FraudReportInfo(1, '电话诈骗', false),
  new FraudReportInfo(2, '假客服', false),
  new FraudReportInfo(3, '其他', false)
]
export const questionList: QuestionInfo[] = [
  {
    id: 1,
    text: '可以延期还款吗',
    desc: '目前还款日之后可以延缓2-3天还款，延缓期间不影响您的信用，但是会影响您后续的贷款额度评估，还款日当天最迟不要超过23点还款成功不算逾期。',
  },
  {
    id: 2,
    text: '转账成功了，账单没有更新怎么办',
    desc: '不可以',
  },
  {
    id: 3,
    text: '如何提前还款',
    desc: '不可以',
  },
  {
    id: 4,
    text: '如何修改还款日',
    desc: '不可以修改还款日',
  },
  {
    id: 5,
    text: '还款利率会变化吗',
    desc: '暂时不可以',
  },
  {
    id: 6,
    text: '最多能借多少钱',
    desc: '根据审核结果，不同产品不同额度。',
  },
  {
    id: 7,
    text: '如何计算借款利息',
    desc: '可咨询你的顾问或者在线客服',
  },
  {
    id: 8,
    text: '发现疑似诈骗怎么办',
    desc: '举报',
  },
  {
    id: 9,
    text: '官方安全操作建议',
    desc: '详细请联系在线客服',
  },

]
export const loanList: QuestionInfo[] = [
  {
    id: 1,
    text: '可以延期还款吗',
    desc: '不可以',
  },
  {
    id: 2,
    text: '转账成功了，账单没有更新怎么办',
    desc: '详细请联系在线客服',
  },
  {
    id: 3,
    text: '如何提前还款',
    desc: '详细请联系在线客服',
  },
  {
    id: 4,
    text: '如何修改还款日',
    desc: '详细请联系在线客服咨询如何修改还款日',
  },
  {
    id: 5,
    text: '还款利率会变化吗',
    desc: '当前期内不会',
  },
  {
    id: 6,
    text: '最多能借多少钱',
    desc: '不同产品不同额度。',
  },
  {
    id: 7,
    text: '如何计算借款利息',
    desc: '详细请联系在线客服借款利息',
  },
  {
    id: 8,
    text: '发现疑似诈骗怎么办',
    desc: '去诈骗举报页面举报',
  },
  {
    id: 9,
    text: '官方安全操作建议',
    desc: '详细请联系在线客服关于操作建议的回复',
  },

]
export const AntiFraudList: QuestionInfo[] = [
  {
    id: 1,
    text: '可以延期还款吗',
    desc: '不可以延期还款',
  },
  {
    id: 2,
    text: '还款成功了，账单没有更新怎么办',
    desc: '咨询客服或你的顾问',
  },
  {
    id: 3,
    text: '如何提前还款',
    desc: '暂不支持',
  },
  {
    id: 4,
    text: '如何修改还款日',
    desc: '暂不可以',
  },
  {
    id: 5,
    text: '还款利率会变化吗',
    desc: '已经成功审批并在还款中的不会变化',
  },
  {
    id: 6,
    text: '最多能借多少钱',
    desc: '根据个人申请评估而定',
  },
  {
    id: 7,
    text: '如何计算借款利息',
    desc: '可联系客服或工作人员',
  },
  {
    id: 8,
    text: '发现疑似诈骗怎么办',
    desc: '去举报',
  },
  {
    id: 9,
    text: '官方安全操作建议',
    desc: '可联系客服',
  },

]
export const tabInfoList: TabInfo[] = [
  {
    text: '常见问题',
    id: TabType.Question,
    selected: true,
  },
  {
    text: '借款相关',
    id: TabType.Loan,
    selected: false,
  },
  {
    text: '防骗指南',
    id: TabType.AntiFraud,
    selected: false,
  },
]

/**
 * 设置ListItem类型
 */
@ObservedV2
export class SettingItem implements ISettingItem {
  @Trace icon?: ResourceStr = '';
  @Trace label: ResourceStr = '';
  @Trace subLabel?: ResourceStr = '';
  @Trace routerName?: RouterMap;
  @Trace routerParams?: Object;
  @Trace typeSwitch?: boolean = false;
  @Trace typeSelect?: boolean = false;
  @Trace switchV?: boolean;
  @Trace selectV?: number;
  @Trace selectOptions?: ISelectOption[];
  @Trace selectTitle?: string;
  @Trace extraLabel?: ResourceStr;
  @Trace onClick?: (param?: Object) => void;
  @Trace onSelect?: (param?: Object) => void;

  constructor(item?: ISettingItem) {
    if (!item) {
      return;
    }
    this.icon = item.icon;
    this.label = item.label;
    this.subLabel = item.subLabel;
    this.routerName = item.routerName;
    this.routerParams = item.routerParams;
    this.typeSwitch = item.typeSwitch;
    this.typeSelect = item.typeSelect;
    this.switchV = item.switchV;
    this.selectV = item.selectV;
    this.selectOptions = item.selectOptions;
    this.selectTitle = item.selectTitle;
    this.extraLabel = item.extraLabel;
    this.onClick = item.onClick;
    this.onSelect = item.onSelect;
  }
}