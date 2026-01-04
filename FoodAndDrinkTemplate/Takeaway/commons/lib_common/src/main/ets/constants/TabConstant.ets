export const MY_TAB_BAR_HOME = ['全部', '地方菜系', '汉堡披萨', '甜食饮品', '快食简餐'];
export const MY_TAB_BAR_COUPONS = ['地方菜系', '汉堡披萨', '甜食饮品', '快食简餐', '通用卡券'];

export class TabConstant {
  static readonly ACTIVE_COLOR: ResourceColor = $r('app.color.app_yellow');
  // 待选颜色: 同上
  static readonly FROZEN_COLOR: ResourceColor = 'rgba(0, 0, 0, 0.6)';
  // 导航区背景颜色
  static readonly TAB_BAR_BGCOLOR: ResourceColor = '#F1F3F5';
  // 内容背景颜色
  static readonly TAB_CONTENT_BGCOLOR: ResourceColor = '#F1F3F5';
  // 选中文字粗细
  static readonly ACTIVE_WEIGHT: number | string | FontWeight = FontWeight.Medium;
  // 待选文字粗细
  static readonly FROZEN_WEIGHT: number | string | FontWeight = FontWeight.Normal;
  // 动画时长
  static readonly ANIMATION_DURATION: number = 300;
  // 导航区高度
  static readonly TAB_BAR_HEIGHT: number = 56;
  // 条形高度
  static readonly LINE_HEIGHT: number = 2;
  // 条形距离顶部位置
  static readonly MARGIN_TOP: number = 44;
}