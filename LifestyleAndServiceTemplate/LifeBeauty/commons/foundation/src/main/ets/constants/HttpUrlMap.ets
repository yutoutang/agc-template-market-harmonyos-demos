/**
 * 云侧接口url
 */
export enum HttpUrlMap {
  LOGIN_WITH_HUAWEI_ID = '/api/hw-atomic/loginWithHuaweiID',
  REFRESH_TOKEN = '/api/hw-atomic/refreshToken',
  BIND_MOBILE_WITH_CODE = '/api/hw-atomic/bindMobileWithCode',
  CONFIRM_REBIND_MOBILE = '/api/hw-atomic/confirmRebindMobileWithSecret',
  GET_USER_INFO = '/api/hw-atomic/getUserInfo',
  UPDATE_USER_INFO = '/api/hw-atomic/updateUserInfo',
  UNBIND_MOBILE = '/api/hw-atomic/unbindMobile',
  GET_STORE_INFO = '/api/metaservice/storeInfo',
  GET_STORE_LIST = '/api/metaservice/store/list',
  GET_GOOD_LIST = '/api/metaservice/goods/list',
  GET_APPOINTMENT_LIST = '/api/metaservice/reserv/list',
  CREATE_APPOINTMENT_INFO = '/api/metaservice/reserv/create',
  UPDATE_APPOINTMENT_INFO = '/api/metaservice/reserv/update',
  CANCEL_APPOINTMENT = '/api/metaservice/reserv/cancel',
  ACTIVE_MEMBER_CARD = '/api/metaservice/active/member',
  GET_SINGLE_VISIT_CARD_LIST = '/api/metaservice/card/list',
  GET_GROUP_LIST = '/api/metaservice/group/list',
  PRE_ORDER = '/api/metaservice/order',
  GET_MY_SINGLE_VISIT_CARD_LIST = '/api/metaservice/card/list/buy',
  GET_MY_GROUP_LIST = '/api/metaservice/group/list/buy',
  REFUND_GROUP = '/api/metaservice/group/refund',
}
;