import axios, { AxiosError, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios';
import { BASE_URL } from '../constants/AppConstant';
import { HttpUrlMap } from '../constants/HttpUrlMap';
import { MockApi } from './MockApi';

/**
 * 是否使用mock数据
 */
const useMock: boolean = true;

const instance = axios.create({
  baseURL: BASE_URL,
  timeout: 3000,
});

// Add a request interceptor.
instance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  if (!config.url?.includes('loginWithHuaweiID')) {
    config.headers.set('Token', AppStorage.get('Token'));
  }
  return config;
}, (error: AxiosError) => {
  return Promise.reject(error);
});


const onRejectedNormal = (error: AxiosError) => {
  return Promise.reject(error.response?.data);
};

const onRejectedMock = (error: AxiosError): Promise<Object> => {
  const resp: Object = getMockResponse(error.config);
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(resp);
    }, 100)
  })
};

// Add a response interceptor.
instance.interceptors.response.use((response: AxiosResponse) => {
  if (response.status === 200 && response.data?.errorCode === 0) {
    return response.data?.data;
  }
  return Promise.reject(response.data);
}, useMock ? onRejectedMock : onRejectedNormal);


/**
 * 映射相应mock接口
 * @param config
 * @returns
 */
export const getMockResponse = (config?: InternalAxiosRequestConfig): Object => {
  const url = config?.url || '';
  switch (url) {
    case HttpUrlMap.LOGIN_WITH_HUAWEI_ID:
      return MockApi.loginWithHuaweiID();
    case HttpUrlMap.REFRESH_TOKEN:
      return MockApi.refreshToken();
    case HttpUrlMap.BIND_MOBILE_WITH_CODE:
      return MockApi.bindMobileWithCode();
    case HttpUrlMap.CONFIRM_REBIND_MOBILE:
      return MockApi.confirmRebindMobileWithSecret();
    case HttpUrlMap.GET_USER_INFO:
      return MockApi.getUserInfo();
    case HttpUrlMap.UPDATE_USER_INFO:
      return MockApi.modifyUserInfo(config);
    case HttpUrlMap.UNBIND_MOBILE:
      return MockApi.unbindMobile();
    case HttpUrlMap.GET_STORE_INFO:
      return MockApi.getStoreInfo();
    case HttpUrlMap.GET_STORE_LIST:
      return MockApi.getStoreList();
    case HttpUrlMap.GET_GOOD_LIST:
      return MockApi.getGoodList();
    case HttpUrlMap.GET_APPOINTMENT_LIST:
      return MockApi.getAppointmentList(config);
    case HttpUrlMap.CREATE_APPOINTMENT_INFO:
      return MockApi.createAppointmentInfo(config);
    case HttpUrlMap.UPDATE_APPOINTMENT_INFO:
      return MockApi.updateAppointmentInfo(config);
    case HttpUrlMap.CANCEL_APPOINTMENT:
      return MockApi.cancelAppointment(config);
    case HttpUrlMap.ACTIVE_MEMBER_CARD:
      return MockApi.activeMemberCard();
    case HttpUrlMap.GET_SINGLE_VISIT_CARD_LIST:
      return MockApi.getSingleVisitCardList();
    case HttpUrlMap.GET_GROUP_LIST:
      return MockApi.getGroupList();
    case HttpUrlMap.PRE_ORDER:
      return MockApi.preOrder(config);
    case HttpUrlMap.GET_MY_SINGLE_VISIT_CARD_LIST:
      return MockApi.getMySingleVisitCardList();
    case HttpUrlMap.GET_MY_GROUP_LIST:
      return MockApi.getMyGroupList();
    case HttpUrlMap.REFUND_GROUP:
      return MockApi.refund(config);
    default:
      return '';
  }
}


export default instance;