/**
 * 华为账号登录错误码
 */
export enum ErrorCode {
  // The operation for obtaining the shipping address is canceled.
  SHIPPING_ADDRESS_USER_CANCELED = 1008100006,
  // Authorization revoking is performed.
  AUTHENTICATION_USER_CANCELED = 1001502012,
  // The operation for obtaining the invoice title is canceled.
  INVOICE_ASSISTANT_USER_CANCELED = 1010060001,
  // The operation for obtaining the avatar is canceled.
  EXTEND_SERVICE_USER_CANCELED = 1001600005,
  // A network exception occurred in the API for obtaining the shipping address.
  SHIPPING_ADDRESS_NETWORK_ERROR = 1008100002,
  // A network exception occurs in the authorization API.
  AUTHENTICATION_NETWORK_ERROR = 1001502005,
  // A network exception occurred in the API for obtaining the invoice title.
  INVOICE_ASSISTANT_NETWORK_ERROR = 1010060005,
  // A network exception occurred in the API for obtaining the avatar.
  EXTEND_SERVICE_NETWORK_ERROR = 1001600001,
  // 用户未登录华为账号
  UN_LOGIN_1 = 1001502001,
  // 用户未登录华为账号
  UN_LOGIN_2 = 1001600002,
}