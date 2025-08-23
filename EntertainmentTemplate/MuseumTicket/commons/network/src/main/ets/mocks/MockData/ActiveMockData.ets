import { util } from '@kit.ArkTS';
import { FormatUtil } from 'commonlib';
import { CLOUD_STORAGE_URL } from '../Constants';
import { CancelOrderRequest, PreActiveOrderBody } from '../../types/RequestTypes';
import { ActiveInfo, ActiveOrder, Contacts } from '../../types/ResponseTypes';
import { getFormattedResp } from '../Utils';

// 获取昨天和明天的时间
const today = new Date();
const tomorrow = new Date(today);
tomorrow.setDate(today.getDate() + 1);


const activeTime1: string = `${FormatUtil.dateAsISOCN(tomorrow)} 15:30-17:30`;
const activeTime2: string = '2025年05月07日 15:30-17:30';
const orderTime: number = new Date('2025:05:07 10:30:03').getTime();
// mock参观人
const visitor: Contacts = {
  personID: '1',
  cardType: '身份证',
  phone: '12011111111',
  cardID: '110293190102291111',
  name: '张三',
};

export class ActiveDataSetMock {
  static ACTIVE_LIST: ActiveInfo[] = [
    {
      activeId: '1',
      title: '现代设计文化一览',
      subtitle: '身临其境感受近现代以来设计文化的变化',
      time: activeTime1,
      compere: '张晋',
      type: '1',
      resume: '现代设计文化研究者，设计学研究领域',
      fitAge: '18-40',
      remain: 999,
      price: 0,
      cover: CLOUD_STORAGE_URL + 'active_cover1.png?token=a7080fc0-16c4-4b3c-ad23-a39c324685b8',
      deposit: 20,
      detail: '文化情调是文化设计中最为感性直观的要素，因为任何情调总是体现于一定的形式' +
        '，而形式又最能直观地将此类产品与他类产品区别开来，引起消费者的注意。甚至许多消费' +
        '者之所以购买此类产品而不购买他类产品，很大程度上是基于情调考虑。这一类在民用产品服装、' +
        '家具等销售中体现尤为突出。比如中国消费者之中爱牛仔裤以及一些带“洋味”的产品，有相当' +
        '一部分的产品起一个“洋名”，或在产品及其包装上打出“MADE IN CHINA\'，的英文字样，用意也在于此。',
      address:'博物馆东区2楼1大厅'
    },
    {
      activeId: '2',
      title: '感受琉璃的美',
      subtitle: '观天下-琉璃之美特配展览活动',
      time: activeTime2,
      type: '3',
      resume: '观天下艺术品展览研究指导人',
      compere: '于小宝',
      fitAge: '不限',
      remain: 0,
      price: 0,
      deposit: 20,
      cover: CLOUD_STORAGE_URL + 'active_cover2.png?token=ae1a2d55-2416-4d0d-b307-7abfa653357c',
      detail: '琉璃是时光淬炼的诗。熔金般的浆液在窑火中舒展，如蝶破茧，凝成半透明的魂魄。' +
        '它藏着光的密语——或湛蓝如深海，或绯红似朝霞，每一道纹理都是火焰与泥土的私语。古人谓' +
        '之“五色石”，以千度高温赋予其永生。匠人以心为模，稍有不慎便碎作星尘，故每一件琉璃都是' +
        '孤品，盛满偶然与永恒的对峙。捧在掌心，轻若无物，却映得出山河岁月。它是凝固的彩虹，是焚身以火的浪漫。',
      address:'博物馆东区2楼1大厅'
    },
  ];
  static ACTIVE_ORDERS: ActiveOrder[] = [
    {
      orderNo: '1',
      orderStr: '',
      activeId: '1',
      status: '1',
      title: '现代设计文化一览',
      activeTime: activeTime1,
      orderTime: orderTime,
      totalPrice: 20,
      visitors: [visitor],
      contactName: '张三',
      contactPhone: visitor.phone,
    },
    {
      orderNo: '2',
      orderStr: '',
      activeId: '1',
      status: '2',
      title: '现代设计文化一览',
      activeTime: activeTime1,
      orderTime: orderTime,
      totalPrice: 20,
      visitors: [visitor],
      contactName: '张三',
      contactPhone: visitor.phone,
    },
    {
      orderNo: '3',
      orderStr: '',
      activeId: '2',
      status: '3',
      title: '感受琉璃的美',
      activeTime: activeTime2,
      orderTime: orderTime,
      totalPrice: 20,
      visitors: [visitor],
      contactName: '张三',
      contactPhone: visitor.phone,
    },
    {
      orderNo: '4',
      orderStr: '',
      activeId: '2',
      status: '4',
      title: '感受琉璃的美',
      activeTime: activeTime2,
      orderTime: orderTime,
      totalPrice: 20,
      visitors: [visitor],
      contactName: '张三',
      contactPhone: visitor.phone,
    },
  ];

  public static getActiveInfo() {
    return getFormattedResp(ActiveDataSetMock.ACTIVE_LIST);
  }

  public static getActiveInOrders() {
    return getFormattedResp(ActiveDataSetMock.ACTIVE_ORDERS);
  }

  public static preActiveOrder(data: PreActiveOrderBody) {
    const order: ActiveOrder = {
      orderNo: util.generateRandomUUID(false),
      orderStr: '',
      activeId: data.activeId,
      status: '2',
      title: data.title,
      orderTime: new Date().getTime(),
      totalPrice: data.totalPrice,
      visitors: data.visitors,
      contactName: data.contactName,
      contactPhone: data.contactPhone,
      activeTime: data.activeTime,
    };
    ActiveDataSetMock.ACTIVE_ORDERS.unshift(order);
    return getFormattedResp(order);
  }


  public static cancelActiveOrder(data: CancelOrderRequest) {
    ActiveDataSetMock.ACTIVE_ORDERS = ActiveDataSetMock.ACTIVE_ORDERS.map((item) => {
      if (item.orderNo === data.orderNo) {
        item.status = '4';
      }
      return item;
    });
    return getFormattedResp(null);
  }

  public static repayOrder(orderNo:string) {
    ActiveDataSetMock.ACTIVE_ORDERS = ActiveDataSetMock.ACTIVE_ORDERS.map((item) => {
      if (item.orderNo === orderNo) {
        item.status = '2';
      }
      return item;
    });
    const res = ActiveDataSetMock.ACTIVE_ORDERS.find((item)=>item.orderNo === orderNo) as ActiveOrder
    return getFormattedResp(res)
  }

}