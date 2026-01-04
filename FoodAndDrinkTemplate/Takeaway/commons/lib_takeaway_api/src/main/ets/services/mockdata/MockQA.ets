import { BaseMineCustomerServiceQA } from '../../database/MineCustomerServiceQAType';

export class MockQA {
  static list: BaseMineCustomerServiceQA[] = [
    {
      id: 'takeout_001',
      question: '订单一直未送达怎么办？',
      createTime: 1672531200000,
      title: '订单配送延迟处理',
      image: $r('app.media.mock_qa_2'),
      content: '如果您的订单配送超时，请先查看骑手实时位置。若长时间未更新，可联系骑手或申请客服介入处理，我们将为您优先处理并可能提供补偿。',
      isRichText: false
    },
    {
      id: 'takeout_002',
      question: '如何申请退款？',
      createTime: 1672617600000,
      title: '退款申请流程',
      image: $r('app.media.mock_qa'),
      content: '在订单完成24小时内，通过订单详情页点击"申请退款"，选择退款原因并提交。商家将在30分钟内审核，审核通过后1-7个工作日原路退回。',
      isRichText: false
    },
    {
      id: 'takeout_003',
      question: '餐品洒漏如何处理？',
      createTime: 1672704000000,
      title: '餐品洒漏赔偿标准',
      image: $r('app.media.mock_qa_2'),
      content: '<div style=\'line-height: 1.8; font-size: 60px;\'><h2 style=\'margin-bottom: 25px; font-size: 66px;\'>餐品洒漏赔偿标准</h2><p style=\'color: #666666; font-size: 60px; margin-bottom: 30px;\'>时间：2023-01-03 00:00:00</p><p style=\'margin-bottom: 25px; font-size: 60px;\'>餐品洒漏如何处理？</p><p style=\'margin-bottom: 30px; font-size: 60px;\'>请立即拍照上传至\'订单问题反馈\'，客服将在15分钟内核实情况。确认属实后，我们将根据洒漏程度提供全额或部分退款。</p></div>',
      isRichText: true
    },
    {
      id: 'takeout_004',
      question: '优惠券无法使用怎么办？',
      createTime: 1672790400000,
      title: '优惠券使用规则',
      image: $r('app.media.mock_qa_3'),
      content: '请检查：1.优惠券是否在有效期 2.订单金额是否满足使用门槛 3.商品是否参与活动。若均符合仍无法使用，请联系客服人工处理。',
      isRichText: false
    },
    {
      id: 'takeout_005',
      question: '如何修改配送地址？',
      createTime: 1672876800000,
      title: '地址修改指南',
      image: $r('app.media.mock_qa'),
      content: '在骑手接单前可在订单详情直接修改地址。若已接单，请立即联系骑手协商新地址，系统将重新计算配送费和时长。',
      isRichText: false
    },
    {
      id: 'takeout_006',
      question: '会员权益有哪些？',
      createTime: 1672963200000,
      title: '会员特权说明',
      image: $r('app.media.mock_qa_3'),
      content: '会员享：1.每月6张无门槛红包 2.专属客服通道 3.配送费减免 4.生日双倍积分 5.优先出餐权等超10项特权。',
      isRichText: false
    },
    {
      id: 'takeout_007',
      question: '骑手联系不上怎么办？',
      createTime: 1673049600000,
      title: '骑手失联处理方案',
      image: $r('app.media.mock_qa'),
      content: '系统将自动触发骑手异常预警，您可通过在线客服申请人工介入。客服会尝试多渠道联系骑手，同时为您准备备选解决方案。',
      isRichText: false
    },
    {
      id: 'takeout_008',
      question: '取消订单后钱款怎么返还？',
      createTime: 1673136000000,
      title: '订单退款',
      image: $r('app.media.mock_qa_2'),
      content: '订单取消后，系统将在24小时内将款项原路退回至您的支付账户，使用的优惠券也会同时返还，请您耐心等待。',
      isRichText: false
    },
    {
      id: 'takeout_009',
      question: '餐品与描述不符',
      createTime: 1673222400000,
      title: '商品差异投诉',
      image: $r('app.media.mock_qa'),
      content: '请提供餐品实拍照片和订单截图，客服会与商家核实。确认属实后，最高可获订单金额3倍赔偿，同时记录商家信用档案。',
      isRichText: false
    },
    {
      id: 'takeout_010',
      question: '无法修改昵称/头像',
      createTime: 1673308800000,
      title: '无法修改昵称/头像',
      image: $r('app.media.mock_qa'),
      content: '你好，可能是以下原因导致无法修改昵称或头像:\n' +
        '1、“用户资料审核中，不可修改”，你之前修改的资料正在审核中，请耐心等待，我们将尽快完成审核:\n' +
        '2、“该昵称已存在”，目前不支持昵称重名，请更换其他合适昵称;\n' +
        '3、“头像无法更换”，请更换较小的图片重新上传;\n' +
        '4、“无错误提示”，请打开消息推送设置，再尝试修复。\n' +
        '如仍无法解决，请点击「我的」的「意见反馈」，提供发生问题的界面截屏，我们会尽快处理。',
      isRichText: false
    }
  ];
}