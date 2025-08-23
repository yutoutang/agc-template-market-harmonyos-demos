import { Contacts, TicketOwner } from './ResponseTypes';


export interface BaseSuccessResponse<T = ESObject> {
  code: number;
  msg?: string;
  data: T;
}


export interface OrderListRequest {
  orderClass: string,
  userId: number
}

export interface CancelOrderRequest {
  orderNo: string,
  userId: number,
  cancelTime: string
}

export interface OrderDetailRequest {
  orderNo: string,
  userId: number,
}

// 订单参观人信息
interface OrderVisitor {
  personId: string,
  name: string,
}

export interface OrderFreeRequest {
  visitTime: string,
  orderTime: string,
  visitor: number,
  visitors: OrderVisitor[],
  contactPhone: string,
}


// 订单信息
export interface PrepayBuyTicketRequest {
  visitTime: string,
  orderAmount?: number,
  ticketOwner: TicketOwner[]
  contactPhone: string,
  performanceName: string,
  performanceId: string,
  orderNo?:string
}


export interface GetBannerImgRequest{
  pageType:number
}


// 获取讲解余票请求
export interface ExplainTicketRequest{
  day:string,
  explain:string
}

export interface OrderExplainRequest{
  name:string,
  timeSegment:string,
  day:string,
  visitors:Contacts[]
}



// 提交讲解服务订单
export interface PreExplainOrderBody{
  time:number,
  timeSegment:string,
  totalPrice:number,
  visitors:Contacts[],
  title:string,
  img:string,
  explainType:string,
  price:number,
  language:string
}

// 提交活动订单
export interface PreActiveOrderBody{
  totalPrice:number,
  visitors:Contacts[],
  contactName:string,
  contactPhone:string,
  title:string,
  activeId:string,
  activeTime:string
}

export enum OrderType{
  TICKET_ORDER = '1',
  ACTIVE_ORDER = '2',
  EXPLAIN_ORDER = '3'
}


// 待支付订单重新支付
export interface RepayOrderBody{
  orderNo:string,
  orderType:OrderType
}

