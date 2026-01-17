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

  // 预约门店
  storeId: string;
}

/**
 * 门店基础模型
 */
export interface StoreInfo {
  // 门店ID
  id: string;

  // 店铺名称
  storeName: string;

  // 坐标
  coords: string;

  // 地址
  address: string;

  // 联系电话
  mobile: string;

  // 离当前地点的距离
  distance?: string;
}