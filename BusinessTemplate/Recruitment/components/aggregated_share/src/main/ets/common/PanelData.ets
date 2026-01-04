import { ShareAppType, ShareWay } from './ShareEnum';
import { ShareKinds } from './ShareParams';

export const unifiedShareList: ShareKinds[][] = [
  [
    {
      kindId: ShareAppType.WECHAT_SESSION,
      icon: $r('app.media.ic_wechat'),
      label: '微信',
    },
    {
      kindId: ShareAppType.QQ,
      icon: $r('app.media.ic_qq'),
      label: 'QQ',
    },
  ],
  [
    {
      kindId: ShareWay.SYSTEM,
      icon: $r('app.media.ic_public_systemshare'),
      label: '系统分享',
    },
  ],
]

export const posterShareList: ShareKinds[] = [
  {
    kindId: ShareAppType.WECHAT_SESSION,
    icon: $r('app.media.ic_wechat'),
    label: '微信',
    isPoster: true,
  },
  {
    kindId: ShareAppType.WECHAT_TIMELINE,
    icon: $r('app.media.ic_wechat_timeline'),
    label: '朋友圈',
    isPoster: true,
  },
  {
    kindId: ShareAppType.WEIBO,
    icon: $r('app.media.ic_weibo'),
    label: '微博',
    isPoster: true,
  },
  {
    kindId: ShareWay.SAVE_TO_ALBUM,
    icon: $r('app.media.ic_public_save'),
    label: '保存图片',
    isPoster: true,
  },
]