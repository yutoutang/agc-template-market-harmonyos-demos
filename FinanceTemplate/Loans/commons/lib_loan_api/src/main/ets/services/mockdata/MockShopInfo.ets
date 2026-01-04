import { ShopInfoType } from '../../database/ShopInfoType';

export class MockShopInfo {
  static shopInfoData: ShopInfoType = {
    bannerIcon: $r('app.media.learn_more_banner'),
    interduceStart: '我们的贷款平台，致力于为用户提供 安全、便捷、透明 的金融服务。',
    interduceEnd: '无论是日常消费周转，还是紧急资金需求，平台都能为您提供值得信赖的贷款服务。',
    features: [
      {
        featureTitle: '合规可靠',
        featureDesc: '平台已通过多项金融监管合规认证，合作机构正规可查，保障用户资金安全。'
      },
      {
        featureTitle: '额度灵活',
        featureDesc: '提供多种贷款产品，支持小额周转与大额资金需求，额度可分可合，更贴近实际使用场景。'
      },
      {
        featureTitle: '流程高效',
        featureDesc: '全流程线上操作，身份证+人脸识别即可申请，最快当天放款，真正做到“急用钱，快到账'
      },
      {
        featureTitle: '信息透明',
        featureDesc: '利率、费用公开透明，无隐藏条款，用户可提前查看还款计划，安心借还。'
      },
      {
        featureTitle: '隐私保障',
        featureDesc: '采用银行级数据加密与风控系统，严格保护用户个人信息不被泄露。'
      }
    ]
  }
}