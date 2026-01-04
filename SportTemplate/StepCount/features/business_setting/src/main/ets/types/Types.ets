import { RouterMap } from 'lib_common';

export interface ISelectOption {
  id: number;
  label: string;
}

export interface ISettingItem {
  icon?: ResourceStr;
  label: ResourceStr;
  labelColor?: ResourceStr;
  subLabel?: ResourceStr;
  routerName?: RouterMap;
  routerParams?: Object;
  typeSwitch?: boolean;
  typeSelect?: boolean;
  typeBindSheet?: boolean;
  switchV?: boolean;
  selectV?: number;
  selectOptions?: ISelectOption[];
  selectTitle?: string;
  extraLabel?: ResourceStr;
  onClick?: (param?: Object) => void;
  onSelect?: (param?: Object) => void;
  bindSheet?: (param?: Object) => void;
  isConfirm?: boolean;
}

/**
 * 设置ListItem类型
 */
@ObservedV2
export class SettingItem implements ISettingItem {
  @Trace icon?: ResourceStr = '';
  @Trace label: ResourceStr = '';
  @Trace labelColor: ResourceStr = $r('sys.color.font_primary')
  @Trace subLabel?: ResourceStr = '';
  @Trace routerName?: RouterMap;
  @Trace routerParams?: Object;
  @Trace typeSwitch?: boolean = false;
  @Trace typeSelect?: boolean = false;
  @Trace typeBindSheet?: boolean = false;
  @Trace switchV?: boolean;
  @Trace selectV?: number;
  @Trace selectOptions?: ISelectOption[];
  @Trace selectTitle?: string;
  @Trace extraLabel?: ResourceStr;
  @Trace onClick?: (param?: Object) => void;
  @Trace onSelect?: (param?: Object) => void;
  @Trace bindSheet?: (param?: Object) => void;
  @Trace isConfirm?: boolean = false;

  constructor(item?: ISettingItem) {
    if (!item) {
      return;
    }
    this.icon = item.icon;
    this.label = item.label;
    if (item.labelColor) {
      this.labelColor = item.labelColor;
    }
    this.subLabel = item.subLabel;
    this.routerName = item.routerName;
    this.routerParams = item.routerParams;
    this.typeSwitch = item.typeSwitch;
    this.typeSelect = item.typeSelect;
    this.typeBindSheet = item.typeBindSheet;
    this.switchV = item.switchV;
    this.selectV = item.selectV;
    this.selectOptions = item.selectOptions;
    this.selectTitle = item.selectTitle;
    this.extraLabel = item.extraLabel;
    this.onClick = item.onClick;
    this.onSelect = item.onSelect;
  }
}