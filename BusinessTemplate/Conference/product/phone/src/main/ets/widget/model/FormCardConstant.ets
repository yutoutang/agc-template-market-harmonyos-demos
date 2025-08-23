export const ENTRY_ABILITY = 'EntryAbility';

export enum FormCarAction {
  CALL = 'call',
  ROUTER = 'router'
}

export enum FormCardName {
  WIDGET_2X2 = 'widget',
  TICKET_2X2 = 'ticketWidget',
}

export enum RouterType {
  COUNTDOWN = '1', // 倒计时
  TICKET = '2', // 门票
  AGENDA = '3', // 议程
  WATER = '4', //  水印
  AGENDADETAIL = '5' //  议程详情
}

export enum CallMethod {
  REQUEST_UPDATE_CARD = 'requestUpdatePlayCard',
  PLAY_BY_ACTION = 'playByAction',
  COLLECT_ACTION = 'collectAction',
}

export enum CollectAction {
  COLLECTED = '1',
  UNCOLLECTED = '0'
}