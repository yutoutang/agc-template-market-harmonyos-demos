import { RouterMap } from './CommonEnum';

export class CommonConstants {
  // 域名
  public static readonly BASE_URL = '';
  // 云存储域名
  public static readonly CLOUD_STORAGE_URL =
    'https://agc-storage-drcn.platform.dbankcloud.cn/v0/integrated-hotel-fa7tl/mock_media/';
  // 全屏宽度
  public static readonly FULL_WIDTH = '100%';
  // 全屏高度
  public static readonly FULL_HEIGHT = '100%';
  // 集团电话
  public static readonly TEL_NUMBER = '025-12345678';
  // 登录拦截页面
  public static readonly NEED_LOGIN_PAGE: RouterMap[] = [
  // 房间预下单页
    RouterMap.HOTEL_ROOM_ORDER,
    RouterMap.RESTAURANT_FOOD_ORDER,
    RouterMap.ORDER_LIST,
    RouterMap.ORDER_DETAIL,
    RouterMap.COMMENT_SUBMISSION,
    RouterMap.MINE_PROFILE_EDIT,
  ]
}
