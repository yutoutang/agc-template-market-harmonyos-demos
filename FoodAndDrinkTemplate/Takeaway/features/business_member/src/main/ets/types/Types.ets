export interface IPrivilegeItem {
  iconGrey?: ResourceStr;
  iconLight?: ResourceStr;
  label: ResourceStr;
  lockStatus?: boolean;
}

/**
 * 设置PrivilegeItem类型
 */
@ObservedV2
export class PrivilegeItem implements IPrivilegeItem {
  @Trace iconGrey?: ResourceStr = '';
  @Trace iconLight?: ResourceStr = '';
  @Trace label: ResourceStr = '';
  @Trace lockStatus?: boolean = true;

  constructor(item?: IPrivilegeItem) {
    if (!item) {
      return;
    }
    this.iconGrey = item.iconGrey;
    this.iconLight = item.iconLight;
    this.label = item.label;
    this.lockStatus = item.lockStatus;
  }
}