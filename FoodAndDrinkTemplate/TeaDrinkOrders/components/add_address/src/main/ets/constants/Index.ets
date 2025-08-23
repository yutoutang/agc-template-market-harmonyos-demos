export class Constants {
  static readonly FULL_SIZE = '100%'
  static readonly BORDER_WIDTH = 16
  static readonly TELEPHONE_LENGTH = 11
}

// 地址标签
export enum AddressTagEnum {
  DEFAULT = 1,
  HOME,
  COMPANY,
  SCHOOL,
}

// 地址标签
export const ADDRESS_TAG_MAP: Record<number, ResourceStr> = {
  // 常用
  1: $r('app.string.address_default'),
  // 家
  2: $r('app.string.address_home'),
  // 公司
  3: $r('app.string.address_company'),
  // 学校
  4: $r('app.string.address_school'),
}