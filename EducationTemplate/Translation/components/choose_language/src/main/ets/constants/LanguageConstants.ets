// 语言选择相关常量定义

export class VipDialogConstants {
  // 颜色
  static readonly BG_COLOR: string = '#FFF9E6'; // 弹窗背景色
  static readonly BUTTON_BG_COLOR: string = '#8B6914'; // 按钮背景色
  static readonly TEXT_COLOR: string = '#333333'; // 文字颜色
  static readonly MASK_BG_COLOR: string = 'rgba(0, 0, 0, 0.5)'; // 遮罩背景色

  // 尺寸
  static readonly DIALOG_WIDTH: number = 300; // 弹窗宽度
  static readonly DIALOG_BORDER_RADIUS: number = 28; // 弹窗圆角
  static readonly BUTTON_HEIGHT: number = 48; // 按钮高度
  static readonly BUTTON_BORDER_RADIUS: number = 24; // 按钮圆角
  static readonly CLOSE_BUTTON_SIZE: number = 40; // 关闭按钮尺寸
  static readonly VIP_ICON_WIDTH: number = 160; // VIP图标宽度
  static readonly VIP_ICON_HEIGHT: number = 120; // VIP图标高度

  // 间距
  static readonly TEXT_TOP_MARGIN: number = 24; // 文字顶部边距
  static readonly TEXT_BOTTOM_MARGIN: number = 24; // 文字底部边距
  static readonly DIALOG_BOTTOM_PADDING: number = 32; // 弹窗底部内边距
  static readonly DIALOG_HORIZONTAL_PADDING: number = 32; // 弹窗水平内边距
  static readonly VIP_ICON_TOP_MARGIN: number = -60; // VIP图标顶部负边距
  static readonly CLOSE_BUTTON_TOP_MARGIN: number = 380; // 关闭按钮顶部边距

  // 字体
  static readonly TEXT_FONT_SIZE: number = 17; // 提示文字字号
  static readonly BUTTON_FONT_SIZE: number = 16; // 按钮文字字号

  // 文案
  static readonly UPGRADE_TEXT: string = '充值会员，解锁更多语言！';
  static readonly UNLOCK_BUTTON_TEXT: string = '去解锁';
}

/**
 * 语言列表样式常量
 */
export class LanguageListConstants {
  // 尺寸
  static readonly ITEM_HEIGHT: number = 56; // 列表项高度
  static readonly HEADER_HEIGHT: number = 56; // 头部高度
  static readonly VIP_ICON_WIDTH: number = 40; // VIP图标宽度
  static readonly VIP_ICON_HEIGHT: number = 20; // VIP图标高度

  // 字体
  static readonly ITEM_FONT_SIZE: number = 16; // 列表项字号
  static readonly TITLE_FONT_SIZE: number = 16; // 标题字号（与列表项一致）
  static readonly HEADER_FONT_SIZE: number = 16; // 头部字号

  // 间距
  static readonly TITLE_TOP_MARGIN: number = 16; // 标题顶部边距
  static readonly TITLE_BOTTOM_MARGIN: number = 8; // 标题底部边距
  static readonly TITLE_LEFT_MARGIN: number = 16; // 标题左边距
  static readonly LIST_HORIZONTAL_PADDING: number = 16; // 列表水平内边距
  static readonly HEADER_LEFT_PADDING: number = 16; // 头部左内边距
  static readonly HEADER_RIGHT_PADDING: number = 16; // 头部右内边距

  // 文案
  static readonly COMMON_LANGUAGES_TITLE: string = '常用语言';
}

//图标尺寸常量
export class IconSizeConstants {
  static readonly BACK_ICON_SIZE: number = 28; // 返回图标尺寸
  static readonly DROPDOWN_ICON_SIZE: number = 20; // 下拉图标尺寸
  static readonly SWITCH_ICON_SIZE: number = 24; // 交换图标尺寸
  static readonly CHECKMARK_ICON_SIZE: number = 20; // 选中图标尺寸
}
