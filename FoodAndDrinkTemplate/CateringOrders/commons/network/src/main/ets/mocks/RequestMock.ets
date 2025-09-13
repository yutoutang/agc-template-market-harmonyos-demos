import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import HttpRequest from '../apis/HttpRequest';
import { RequestUrl } from '../constants/Index';
import { CouponItem, DishesTypeResp, GoodsResp, GoodsSpecResp, MyCarResp, MyOrderResp } from '../types/Order';
import { AddCarReq } from '../types/Request';
import { BaseResponse } from '../types/Response';
import { AppInfoResp, StoreInfoResp, TableInfoResp } from '../types/Store';
import { HelpMsgResp, RechargeRecord, UserInfoResp } from '../types/User';
import { AxiosMock } from './AxiosMock';
import {
  addCar,
  addGoods,
  addOrder,
  cancelOrder,
  cleanCar,
  deleteOrder,
  getCouponsResp,
  getDishesList,
  getGoodsInfoResp,
  getGoodsSpecInfo,
  getHuaweiPayInfo,
  getIsNew,
  getLqCoupons,
  getMyCar,
  getMyCoupons,
  getMyOrder,
  getOrderInfo,
  getSnackSizedDeal,
  getUpdCar,
} from './MockData/Order';
import { getAppInfoResp, getStoreInfoResp, getStoreList, getTableInfoResp } from './MockData/Store';
import {
  getCloseLogin,
  getHelp,
  getOpenLogin,
  getRechargeRecord,
  getUserInfoResp,
  rechargeMoney,
} from './MockData/User';

const mock: AxiosMock = new AxiosMock(HttpRequest.instance, {
  delayResponse: 100,
});

mock.onGet(RequestUrl.GET_APP_INFO_URL).reply(async (config: AxiosRequestConfig) => {
  let list = getAppInfoResp();
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: list } as BaseResponse<AppInfoResp>,
  };
});
mock.onGet(RequestUrl.GET_TABLE_LIST_URL).reply(async (config: AxiosRequestConfig) => {
  let list = getTableInfoResp();
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: list } as BaseResponse<Array<TableInfoResp>>,
  };
});
mock.onGet(RequestUrl.GET_STORE_LIST_URL).reply(async (config: AxiosRequestConfig) => {
  let list = getStoreList();
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: list } as BaseResponse<Array<StoreInfoResp>>,
  };
});

mock.onGet(RequestUrl.GET_LOGIN_HM_URL).reply(async (config: AxiosRequestConfig) => {
  let data = getUserInfoResp();
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<UserInfoResp>,
  };
});
mock.onGet(RequestUrl.GET_OPEN_LOGIN_HM_URL).reply(async (config: AxiosRequestConfig) => {
  let data = getOpenLogin();
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<UserInfoResp>,
  };
});
mock.onGet(RequestUrl.GET_CLOSE_LOGIN_HM_URL).reply(async (config: AxiosRequestConfig) => {
  let data = getCloseLogin();
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<UserInfoResp>,
  };
});

mock.onGet(RequestUrl.GET_STORE_INFO_URL).reply(async (config: AxiosRequestConfig) => {
  const storeId: string = config.params?.storeId
  let data = getStoreInfoResp(storeId);
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<StoreInfoResp>,
  };
});
mock.onGet(RequestUrl.GET_DISHES_LIST_URL).reply(async (config: AxiosRequestConfig) => {
  let data = getDishesList();
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<Array<DishesTypeResp>>,
  };
});

mock.onGet(RequestUrl.GET_GOOD_INFO_URL).reply(async (config: AxiosRequestConfig) => {
  const goodsId: string = config.params?.goodsId
  let data = getGoodsInfoResp(goodsId);
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<GoodsResp>,
  };
});
mock.onGet(RequestUrl.GET_GOOD_SPEC_URL).reply(async (config: AxiosRequestConfig) => {
  let data = getGoodsSpecInfo(config.params);
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<GoodsSpecResp>,
  };
});
mock.onGet(RequestUrl.GET_ADD_CAR_URL).reply(async (config: AxiosRequestConfig) => {
  let data = addCar(config.params as AddCarReq);
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<number>,
  };
});

mock.onGet(RequestUrl.GET_MY_CAR_URL).reply(async (config: AxiosRequestConfig) => {
  let data = getMyCar();
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<MyCarResp>,
  };
});

mock.onGet(RequestUrl.GET_DEL_CAR_URL).reply(async (config: AxiosRequestConfig) => {
  let data = cleanCar();
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<number>,
  };
});

mock.onGet(RequestUrl.GET_UPD_CAR_URL).reply(async (config: AxiosRequestConfig) => {
  let data = getUpdCar(config.params);
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<number>,
  };
});

mock.onGet(RequestUrl.GET_ADD_DN_ORDER_URL).reply(async (config: AxiosRequestConfig) => {
  let data = addOrder(config.params);
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<string>,
  };
});

mock.onGet(RequestUrl.GET_MY_ORDER_URL).reply(async (config: AxiosRequestConfig) => {
  let data = getMyOrder(config.params);
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<Array<MyOrderResp>>,
  };
});

mock.onGet(RequestUrl.GET_ORDER_INFO_URL).reply(async (config: AxiosRequestConfig) => {
  let data = getOrderInfo(config.params);
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<MyOrderResp>,
  };
});

mock.onGet(RequestUrl.GET_CANCEL_ORDER_URL).reply(async (config: AxiosRequestConfig) => {
  let data = cancelOrder(config.params);
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<number>,
  };
});

mock.onGet(RequestUrl.GET_HELP_URL).reply(async (config: AxiosRequestConfig) => {
  let data = getHelp();
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<Array<HelpMsgResp>>,
  };
});
mock.onGet(RequestUrl.GET_COUPONS_URL).reply(async (config: AxiosRequestConfig) => {
  let data = getCouponsResp();
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<Array<CouponItem>>,
  };
});
mock.onGet(RequestUrl.GET_LQ_COUPONS_URL).reply(async (config: AxiosRequestConfig) => {
  let data = getLqCoupons(config.params);
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<number>,
  };
});

mock.onGet(RequestUrl.GET_MY_COUPONS_URL).reply(async (config: AxiosRequestConfig) => {
  let data = getMyCoupons();
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<CouponItem[]>,
  };
});
mock.onGet(RequestUrl.GET_IS_NEW_URL).reply(async (config: AxiosRequestConfig) => {
  let data = getIsNew();
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<number>,
  };
});

mock.onPost(RequestUrl.GET_ADD_GOODS_URL).reply(async (config: AxiosRequestConfig) => {
  let data = addGoods(config.params);
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<number>,
  };
});

mock.onGet(RequestUrl.GET_SNACK_SIZED_DEAL).reply(async (config: AxiosRequestConfig) => {
  let data = getSnackSizedDeal(config.params);
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<Array<GoodsResp>>,
  };
});

mock.onDelete(RequestUrl.GET_DELETE_ORDER_URL).reply(async (config: AxiosRequestConfig) => {
  let data = deleteOrder(config.params);
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<number>,
  };
});

mock.onGet(RequestUrl.GET_HUAWEI_PAY_INFO_URL).reply(async (config: AxiosRequestConfig) => {
  let data = getHuaweiPayInfo(config.params);
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<number>,
  };
});
mock.onPost(RequestUrl.RECHARGE_MONEY_URL).reply(async (config: AxiosRequestConfig) => {
  let data = rechargeMoney(config.params.rechargeTierId);
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<number>,
  };
});
mock.onGet(RequestUrl.GET_RECHARGE_RECORD_URL).reply(async (config: AxiosRequestConfig) => {
  let data = getRechargeRecord();
  return {
    status: HttpStatusCode.Ok,
    data: { code: 0, msg: '', data: data } as BaseResponse<RechargeRecord[]>,
  };
});