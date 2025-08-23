import { RouterMap } from 'commonlib';
import { MenuItem } from '../types/Index';


const TAG = '[MyBookVM]';

@ObservedV2
export class MyBookVM {
  @Trace menuList: MenuItem[] = [
    {
      label: '门票订单',
      routerUrl: RouterMap.TICKET_ORDERS,
    },
    {
      label: '活动订单',
      routerUrl: RouterMap.ACTIVE_ORDERS,
    },
    {
      label: '讲解订单',
      routerUrl: RouterMap.EXPLAIN_ORDERS,
    },
  ];
  private static _instance: MyBookVM;

  public static get instance() {
    if (!MyBookVM._instance) {
      MyBookVM._instance = new MyBookVM();
    }
    return MyBookVM._instance;
  }
}