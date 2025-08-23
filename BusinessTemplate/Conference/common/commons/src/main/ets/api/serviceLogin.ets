import { http } from '../utils/api';
import { MyConfig } from '../constants/MyConfig'
import { ApiResponse } from '../utils/api'
import { UserInfoDetail } from '../viewModel/UserModel';

interface LoginParams {
  code: string;
}

interface loginResult { //根据项目实际项目修改
  token: string,
  mobile?: string
}

interface logOutParams { //根据项目实际项目修改
  token: string,
}

// 授权登录
export function loginByAuthCode(params: LoginParams): Promise<ApiResponse<loginResult>> {
  return http.post<loginResult>('/loginByAuthCode', params, {
    baseURL: MyConfig.EVENTSURL
  })
}

// 退出登录
export function logOutCleartokenion(params: logOutParams): Promise<ApiResponse<boolean>> {
  return http.post<boolean>('/Logout', params, {
    baseURL: MyConfig.PROJECTURL
  })
}

interface ContactsGetParams {
  token: string;
}

// 获取报名信息
export function seminarContactsGet(params: ContactsGetParams): Promise<ApiResponse<UserInfoDetail>> {
  return http.post<UserInfoDetail>('/getPersonalDetail', params, {
    baseURL: MyConfig.PROJECTURL
  })
}

// 是否签署了协议
interface IsSignedParams {
  token: string
}


export function isSigned(params: IsSignedParams): Promise<ApiResponse<SignResultContent>> {
  return http.post<SignResultContent>('/user/is-sign-agreement', params, {
    baseURL: MyConfig.PROJECTURL
  })
}

// 签署协议
interface SignParams {
  token: string
}

interface SignResultContent {
  isSign: number;
}

interface SignResult {
  result?: number;
  content: SignResultContent;
  desc?: string;
}

export function sign(params: SignParams): Promise<ApiResponse<SignResult>> {
  return http.post<SignResult>('/user/sign-agreement', params, {
    baseURL: MyConfig.PROJECTURL
  })
}