export const FLAG_MAP: Map<string, ResourceStr> =
  new Map([['1', $r('app.media.flag_yellow')], ['2', $r('app.media.flag_green')], ['3', $r('app.media.flag_gray')],
    ['4', $r('app.media.flag_gray')]]);


export const ICON_MAP: Map<string, ResourceStr> =
  new Map([['1', $r('app.media.icon_pending')], ['2', $r('app.media.icon_pending')],
    ['3', $r('app.media.icon_expired')],
    ['4', $r('app.media.icon_expired')]]);


export const EXPLAIN_LABEL_MAP: Map<string, string> =
  new Map([['1', '待支付'], ['2', '待使用'], ['3', '已结束'], ['4', '已取消']]);


export const ACTIVE_LABEL_MAP: Map<string, string> =
  new Map([['1', '待支付'], ['2', '待参加'], ['3', '已结束'], ['4', '已取消']]);