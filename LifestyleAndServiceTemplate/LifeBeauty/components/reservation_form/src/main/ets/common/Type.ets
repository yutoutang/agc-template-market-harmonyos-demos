/**
 * 创建预约
 */
export interface IFormData {
  // 联系人姓名
  name: string;

  // 联系人手机号
  phone: string;

  // 预约时间，时间戳类型
  reserveTime: number;

  // 预约备注
  remarks: string;

  // 预约人数
  numbers: string;
}