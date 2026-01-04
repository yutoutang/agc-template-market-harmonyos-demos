import { AggregatedPaymentPicker, ChannelType } from 'aggregated_payment';

@Builder
export function paymentChannelSheet(price: string, paySuccessEvent: (type: ChannelType) => void,
  payFailEvent: (type: ChannelType) => void) {
  AggregatedPaymentPicker({
    price: price,
    goodsName: '商品信息',
    channelInfo: [{
      channelType: ChannelType.HUAWEI_PAY,
      name: '华为支付',
      icon: $r('app.media.pay_hw'),
      preOrderInfo: '{"app_id":"***","merc_no":"***","prepay_id":"xxx","timestamp":"1680259863114","noncestr":"1487b8a60ed9f9ecc0ba759fbec23f4f","sign":"****","auth_id":"***"}'
    }, {
      channelType: ChannelType.WECHAT_PAY,
      preOrderInfo: {
        partnerId: '****',
        appId: '****',
        packageValue: 'Sign=WXPay',
        prepayId: '****',
        nonceStr: '****',
        timeStamp: '****',
        sign: '****',
        extData: '****'
      },
      appId: '',
      icon: $r('app.media.pay_wx'),
      name: '微信支付',
    }, {
      channelType: ChannelType.ALI_PAY,
      name: '支付宝支付',
      icon: $r('app.media.pay_af'),
      preOrderInfo: '服务端生成',
    }],
    paySuccessEvent: paySuccessEvent,
    payFailEvent: payFailEvent
  })
}
