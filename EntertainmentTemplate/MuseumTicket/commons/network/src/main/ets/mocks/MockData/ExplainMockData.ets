import { util } from '@kit.ArkTS';
import {FormatUtil} from 'commonlib'
import { CancelOrderRequest, ExplainTicketRequest, PreExplainOrderBody } from '../../types/RequestTypes';
import { Contacts, ExplainItem, ExplainOrder, ExplainTicketInfo } from '../../types/ResponseTypes';
import { getFormattedResp } from '../Utils';
import { CLOUD_STORAGE_URL } from '../Constants';

const ticketList1: ExplainTicketInfo[] = [{
  timeSegment: '10:00-12:00',
  name: '历史文物讲解',
  price: 120,
  remaining: 0,
  language: '中文',
  device: '耳机',
  headsetPrice: 80,
}, {
  timeSegment: '13:00-15:00',
  name: '历史文物讲解',
  price: 120,
  remaining: 0,
  language: '中文',
  device: '耳机',
  headsetPrice: 80,
}, {
  timeSegment: '15:30-17:30',
  name: '历史文物讲解',
  price: 100,
  remaining: 0,
  language: '中文',
  device: '耳机',
  headsetPrice: 80,
}];


const ticketList2: ExplainTicketInfo[] = [{
  timeSegment: '10:00-12:00',
  name: '历史文物讲解',
  price: 120,
  remaining: 100,
  language: '中文',
  device: '耳机',
  headsetPrice: 80,
}, {
  timeSegment: '13:00-15:00',
  name: '历史文物讲解',
  price: 120,
  remaining: 160,
  language: '中文',
  device: '耳机',
  headsetPrice: 80,
}, {
  timeSegment: '15:30-17:30',
  name: '历史文物讲解',
  price: 100,
  remaining: 200,
  language: '中文',
  device: '耳机',
  headsetPrice: 80,
}];


const visitor: Contacts = {
  personID: '1',
  cardType: '身份证',
  phone: '12011111111',
  cardID: '110293190102291111',
  name: '张三',
};

// 获取未来的时间
const today = new Date();
const tomorrow = new Date(today);
tomorrow.setDate(today.getDate() + 1);


const order1: ExplainOrder = {
  orderNo: '1',
  orderStr: '',
  title: '中国古代-成人场',
  time: tomorrow.getTime(),
  timeSegment: '15:30-17:30',
  orderTime:'2025年05月7日 15:30:03',
  visitors: [
    visitor,
  ],
  totalPrice: 180,
  status: '1',
  price:100,
  img:CLOUD_STORAGE_URL + 'explain_banner1.png?token=a7476929-46f8-4c9c-b3b4-6ba60002d5e2',
  language:'中文',
  explainType:'历史文物讲解'
};

const order2: ExplainOrder = {
  orderNo: '2',
  orderStr: '',
  title: '中国古代-成人场',
  time: tomorrow.getTime(),
  timeSegment: '15:30-17:30',
  orderTime:'2025年05月7日 15:30:03',
  visitors: [
    visitor,
  ],
  totalPrice: 180,
  status: '2',
  price:100,
  img:CLOUD_STORAGE_URL + 'explain_banner1.png?token=a7476929-46f8-4c9c-b3b4-6ba60002d5e2',
  language:'中文',
  explainType:'历史文物讲解'
};


const order3: ExplainOrder = {
  orderNo: '3',
  orderStr: '',
  title: '中国古代-成人场',
  time: new Date('2025-07-01').getTime(),
  timeSegment: '15:30-17:30',
  orderTime:'2025年05月7日 15:30:03',
  visitors: [
    visitor,
  ],
  totalPrice: 180,
  status: '3',
  price:100,
  img:CLOUD_STORAGE_URL + 'explain_banner1.png?token=a7476929-46f8-4c9c-b3b4-6ba60002d5e2',
  language:'中文',
  explainType:'历史文物讲解'
};


const order4: ExplainOrder = {
  orderNo: '4',
  orderStr: '',
  title: '中国古代-成人场',
  time: new Date('2025-07-01').getTime(),
  timeSegment: '15:30-17:30',
  orderTime:'2025年05月7日 15:30:03',
  visitors: [
    visitor,
  ],
  totalPrice: 180,
  status: '4',
  price:100,
  img:CLOUD_STORAGE_URL + 'explain_banner1.png?token=a7476929-46f8-4c9c-b3b4-6ba60002d5e2',
  language:'中文',
  explainType:'历史文物讲解'
};

export class ExplainDatasetMock {
  private static EXPLAIN_LIST: ExplainItem[] =
    [{
      img: CLOUD_STORAGE_URL + 'explain_banner1.png?token=a7476929-46f8-4c9c-b3b4-6ba60002d5e2',
      title: '古代中国-成人场',
      label: '120分钟 / 历史 / 成人',
    },
      {
        img: CLOUD_STORAGE_URL + 'explain_banner2.png?token=f7d0d831-20e7-4a2c-b7f1-1a67a1a95762',
        title: '天坛之美-成人场',
        label: '120分钟 / 历史 / 成人',
      },
      {
        img: CLOUD_STORAGE_URL + 'explain_banner3.png?token=76b1f376-3f5f-4dda-9c9c-d6e637d4f40e',
        title: '千年茶韵-成人场',
        label: '120分钟 / 人文 / 成人',
      },
      {
        img: CLOUD_STORAGE_URL + 'explain_banner4.png?token=223bd763-53bb-44b7-b0e2-d24a9d268a07',
        title: '野性自然-成人场',
        label: '120分钟 / 人文 / 成人',
      }];
  private static EXPLAIN_ORDERS: ExplainOrder[] = [
    order1,
    order2,
    order3,
    order4,
  ];

  public static getExplain() {
    return getFormattedResp(ExplainDatasetMock.EXPLAIN_LIST);
  }

  public static getExplainTicket(data: ExplainTicketRequest) {
    const date: Date = new Date();
    const selectDate: Date = new Date(data.day);
    if (date.getMonth() === selectDate.getMonth() && date.getDate() === selectDate.getDate()) {
      return getFormattedResp(ticketList1);
    } else {
      return getFormattedResp(ticketList2);
    }
  }

  // 获取讲解服务订单
  public static getExplainOrders() {
    return getFormattedResp(ExplainDatasetMock.EXPLAIN_ORDERS);
  }


  // 讲解服务下单预支付
  public static preExplainOrder(data: PreExplainOrderBody) {
    const orderTime:string=FormatUtil.formatFullDate(new Date(),true)
    const order: ExplainOrder = {
      orderNo: util.generateRandomUUID(false),
      orderStr: '',
      title: data.title,
      time: data.time,
      timeSegment: data.timeSegment,
      visitors: data.visitors,
      orderTime:orderTime,
      totalPrice: data.totalPrice,
      status: '2',
      img:data.img,
      explainType:data.explainType,
      price:data.price,
      language:data.language
    };
    ExplainDatasetMock.EXPLAIN_ORDERS.push(order);
    return getFormattedResp(order);
  }

  //  取消订单
  public static cancelExplainOrder(data: CancelOrderRequest) {
    ExplainDatasetMock.EXPLAIN_ORDERS = ExplainDatasetMock.EXPLAIN_ORDERS.map((item) => {
      if (item.orderNo === data.orderNo) {
        item.status = '4';
      }
      return item;
    });
    return getFormattedResp(null);
  }

  public static repayOrder(orderNo:string) {
    ExplainDatasetMock.EXPLAIN_ORDERS = ExplainDatasetMock.EXPLAIN_ORDERS.map((item) => {
      if (item.orderNo === orderNo) {
        item.status = '2';
      }
      return item;
    });
    const res:ExplainOrder = ExplainDatasetMock.EXPLAIN_ORDERS.find((item)=>item.orderNo===orderNo) as ExplainOrder
    return getFormattedResp(res)
  }
}