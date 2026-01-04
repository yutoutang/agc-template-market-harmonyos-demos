import { TimeUtils, UserInfoModel } from 'lib_common';
import { IMineMsgItem, MineMsgMenuType } from '../params/response/MessageResponse';
import { OrderInfo } from '../params/response/OrderResponse';
import { AsyncClass } from '../utils/AsyncUtils';
import { MockMessage } from './mockdata/MockMessage';

/**
 * 消息接口
 */
@AsyncClass
export class MessageService {
  /**
   * 查询所有系统消息
   * @returns
   */
  public async queryAllSystemInfoList() {

    return MockMessage.allMessageList;
  }

  public async getUnReadMessageNum() {
    const num = MockMessage.allMessageList.filter(item => !item.isNewMessage).length
    return num;
  }

  public addOrderMessage(order: OrderInfo, userInfoModel: UserInfoModel) {
    let maxId: number = 0;
    MockMessage.allMessageList.forEach(item => {
      maxId = Math.max(maxId, item.id)
    })
    let content = '购买的商品订单已支付成功，请及时查看'
    if (order.status === 0) {
      // 待付款订单
      content = '购买的商品订单已下单成功，请及时支付'
    }
    let message: IMineMsgItem = {
      id: maxId + 1,
      type: MineMsgMenuType.Order,
      title: '订单通知',
      content: `亲爱的用户您好~您与${TimeUtils.formatDate(order.orderTime, 'YYYY.MM.DD HH:mm:ss')}${content}`,
      createTime: order.orderTime,
      isNewMessage: false
    }
    MockMessage.allMessageList.unshift(message)
    //未读消息+1
    userInfoModel.unReadMsgNum = userInfoModel.unReadMsgNum + 1
  }
}

const instance = new MessageService();

export { instance as MessageServiceApi }