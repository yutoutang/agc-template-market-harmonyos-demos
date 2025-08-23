export interface MineOperationItem {
  icon?: ResourceStr;
  label: string;
  url: string;
  type: MineOperationType;
}

export enum MineOperationType {
  MY_ORDERS,
  USER_INFO,
  SETTINGS,
}
