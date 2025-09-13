import { ShareType } from './Enums';
import { ShareItem } from './Types';

export class Constants {
  public static readonly FONT_COLOR_LEVEL1 = '#E6000000';
  public static readonly FONT_COLOR_1_INVERT = '#FFFFFF';
  public static readonly FONT_COLOR_LEVEL2 = '#99000000';
  public static readonly FONT_COLOR_LEVEL3 = '#66000000';
  public static readonly BACKGROUND_COLOR = '#FFFFFF';
  public static readonly BACKGROUND_COLOR_GREY = '#f1f3f5';
  public static readonly BACKGROUND_COLOR_GREY_2 = '#0d000000';
  public static readonly BACKGROUND_COLOR_TRANSPARENT = '#00000000';
  public static readonly BORDER_RADIUS_4 = '4vp';
  public static readonly BORDER_RADIUS_16 = '16vp';
  public static readonly BORDER_RADIUS_CAPSULE = '99vp';
  public static readonly SPACE_S = '8vp';
  public static readonly SPACE_M = '12vp';
  public static readonly SPACE_L = '16vp';
  public static readonly SHARE_OPTION_LIST: ShareItem[] = [
    {
      label: '生成海报',
      type: ShareType.SAVE_POSTER,
      icon: $r('app.media.ic_save_poster'),
    },
    {
      label: '复制链接',
      type: ShareType.COPY_URL,
      icon: $r('app.media.ic_copy_link'),
    },
  ];
}
