import { OrderActionMap, OrderButtonStyleMap, OrderStatusMap, OrderTabsMap, } from './Enums';

/**
 * 订单类型
 */
export interface OrderType {
  type: OrderTabsMap;
  label: string;
  statusInfo: OrderStatusInfo[];
}

/**
 * 订单状态
 */
export interface OrderStatusInfo {
  status: OrderStatusMap;
  action: OrderAction[];
}

/**
 * 订单操作
 */
export interface OrderAction {
  style: OrderButtonStyleMap;
  fountColor: string | Resource;
  borderColor: string | Resource;
  backgroundColor: string | Resource;
  actionType: OrderActionMap;
  label: string;
  enableHide?: boolean;
}

/**
 * 订单操作入参
 */
export interface OrderActionReq {
  orderNo: string;
  storeId: string;
  callback?: () => void;
  data?: object;
}

export class MyButtonModifier implements AttributeModifier<ButtonAttribute> {
  buttonStyle: OrderButtonStyleMap = OrderButtonStyleMap.FULFILL;
  size: ControlSize = ControlSize.NORMAL;
  fountColor: Resource | string = $r('sys.color.black');
  borderColor: Resource | string = $r('sys.color.black');
  backgroundColor: Resource | string = $r('sys.color.black');

  constructor(
    buttonStyle: OrderButtonStyleMap = OrderButtonStyleMap.FULFILL,
    size: ControlSize = ControlSize.NORMAL,
    fountColor: Resource | string = $r('sys.color.black'),
    borderColor: Resource | string = $r('sys.color.black'),
    backgroundColor: Resource | string = $r('sys.color.black'),
  ) {
    this.buttonStyle = buttonStyle;
    this.size = size;
    this.fountColor = fountColor;
    this.borderColor = borderColor;
    this.backgroundColor = backgroundColor;
  }

  applyNormalAttribute(instance: ButtonAttribute): void {
    instance
      .fontSize(
        this.size === ControlSize.NORMAL ?
        $r('app.float.font_size_14') :
        $r('app.float.font_size_12'),
      )
      .height(this.size === ControlSize.NORMAL ? 40 : 28)
      .padding({
        left: $r('app.float.space_m'),
        right: $r('app.float.space_m'),
        top: $r('app.float.space_xs'),
        bottom: $r('app.float.space_xs'),
      })
      .constraintSize({ minWidth: this.size === ControlSize.NORMAL ? 96 : 64 });

    if (this.buttonStyle === OrderButtonStyleMap.FULFILL) {
      // 支持业务逻辑的编写
      instance.backgroundColor(this.backgroundColor);
    } else {
      instance
        .backgroundColor(this.backgroundColor)
        .borderWidth(1);
      if (this.buttonStyle === OrderButtonStyleMap.OUTLINE) {
        instance
          .borderColor(this.borderColor)
          .fontColor(this.fountColor);
      } else if (this.buttonStyle === OrderButtonStyleMap.GREY) {
        instance
          .borderColor(this.borderColor)
          .fontColor(this.fountColor);
      }
    }
  }
}
