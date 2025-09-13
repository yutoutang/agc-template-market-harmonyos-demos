/**
 * 表单模型
 */
@ObservedV2
export class FormItemModel {
  label: ResourceStr = '';
  content: ResourceStr = '';
}

/**
 * 预约状态
 */
export enum AppointState {
  NEW = 10,
  FINISH = 30,
  CANCEL = 40,
  OVER_TIME = 50,
}

export interface IAppointment {
  reserveTime: number
  itemName: string
  contactName: string
  contactPhone: string
  numbers: number
  remarks?: string
  state: number
  setSchedule: number
  setSubscription: number
}

/**
 * 预约信息
 */
@ObservedV2
export class AppointmentInfo implements IAppointment {
  // 预约时间
  @Trace reserveTime: number = 0;
  // 预约的项目名称
  itemName: string = '';
  // 联系人姓名
  contactName: string = '';
  // 联系人电话
  contactPhone: string = '';
  // 预约人数
  numbers: number = 0;
  // 预约备注
  remarks?: string = '';
  // 预约状态
  @Trace state: AppointState = AppointState.NEW;
  // 是否添加到日程
  @Trace setSchedule: number = 0;
  // 是否订阅推送
  @Trace setSubscription: number = 0;

  constructor(item?: IAppointment) {
    this.contactName = item?.contactName || '';
    this.contactPhone = item?.contactPhone || '';
    this.numbers = item?.numbers || 1;
    this.itemName = item?.itemName || '';
    this.reserveTime = item?.reserveTime || 0;
    this.state = item?.state || 10;
    this.remarks = item?.remarks || '';
    this.setSchedule = item?.setSchedule || 0;
    this.setSubscription = item?.setSubscription || 0;
  }
}
