import axios, {
  InternalAxiosRequestConfig,
  AxiosResponse,
  AxiosError,
  AxiosInstance,
  AxiosRequestConfig,
} from '@ohos/axios';
import { promptAction } from '@kit.ArkUI';
import { checkStatus } from './checkStatus';
import { MyConfig } from '../constants/MyConfig';
import { buffer } from '@kit.ArkTS';
import { FavoriteService } from '../service/FavoriteService';
import { InterestLabelService } from '../service/InterestLabelService';

const favoriteService: FavoriteService = FavoriteService.instance;
const interestLabelService: InterestLabelService = InterestLabelService.instance;
const CONTINUE = 'continue';

export interface ApiResponse<T> { //根据项目实际项目修改
  code?: number;
  data: T;
  message?: string;
  body: T,
}

// 创建实例
const instance: AxiosInstance = axios.create({
  // 默认地址请求地址
  baseURL: '', //修改为自己项目的实际地址
  // 设置超时时间
  timeout: 100000,
  headers: {
    'contentType': 'application/json;charset=utf-8',
    'contentLanguage': 'zh_CN',
  },
});

// 添加请求拦截器
instance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  // 对请求数据做点什么
  /*  const token = 'token....'
    if (token) {
      config.headers['Authorization'] = 'Bearer ' + token //设置token
    }*/
  config.headers['Access-Control-Allow-Origin'] = '*';
  // 添加 user-agent
  config.headers['User-Agent'] = '';
  return config;
}, (error: AxiosError) => {
  // 对请求错误做些什么
  return Promise.reject(error);
});
// 添加响应拦截器 错误统一处理等
instance.interceptors.response.use((response: AxiosResponse) => {
  if (response.config.url === '/get_time') {
    return Promise.resolve(response.data);
  }
  if (response.data.code === 0) {
    return Promise.resolve(response.data);
  } else if (response.data.body && response.data.body.result === 0) {
    return Promise.resolve(response.data);
  } else {
    if (response.config.data) {
      try {
        let responseConfigData = JSON.parse(response.config.data) as Record<string, boolean>;
        if (!responseConfigData.hideToast) {
          promptAction.showToast({
            message: response.data.msg || response.data.body.desc || '请求失败，请稍后重试',
            duration: 2000,
            alignment: Alignment.Center,
          });
        }
      } catch (error) {
      }
    }
    return Promise.reject(response.data);
  }
}, async (error: AxiosError) => {
  // 请求超时 && 网络错误单独判断，没有 response
  if (error.message.indexOf('timeout') !== -1) {
    promptAction.showToast({ message: '请求超时！请您稍后重试' });
  }
  if (error.message.indexOf('Network Error') !== -1) {
    promptAction.showToast({ message: '网络错误！请您稍后重试' });
  }

  // mock数据使用，实际使用中删除此段代码即可
  const mockData: ESObject = await handleMockData(error);
  if (mockData.data !== CONTINUE) {
    return mockData;
  }

  // 根据服务器响应的错误状态码，做不同的处理
  const status = error.response?.status;
  if (status) {
    checkStatus(status);
  }

  return Promise.reject(error);
});

// mock数据使用，实际使用中删除此段代码即可
async function handleMockData(error: AxiosError): Promise<ESObject> {
  if (error.config?.url === '/subSeminar/list.json') {
    let data: ESObject = await MyConfig.context.resourceManager.getRawFileContent('mockData.json');
    let str: ESObject = JSON.parse(buffer.from(data).toString());
    return { data: str.mock_data };
  } else if (error.config?.url?.indexOf('subSeminarDetail') !== -1) {
    const subSeminarId = error.config?.url?.split('/')[1];
    let data: ESObject = await MyConfig.context.resourceManager.getRawFileContent(`${subSeminarId}_detail.json`);
    let str: ESObject = JSON.parse(buffer.from(data).toString());
    return { data: str.detail };
  } else if (error.config.url === '/loginByAuthCode') {
    const authData: ESObject = { token: '12345678', mobile: '12345678' };
    return { data: authData };
  } else if (error.config.url === '/user/sign-agreement') {
    const authData: ESObject = { token: '12345678' };
    return { data: authData };
  } else if (error.config.url === '/user/is-sign-agreement') {
    const authData: ESObject = { isSign: 1 };
    return { data: authData };
  } else if (error.config.url === '/hot_search.json') {
    let data: ESObject = await MyConfig.context.resourceManager.getRawFileContent(`hot_search.json`);
    let str: ESObject = JSON.parse(buffer.from(data).toString());
    return { data: str.mock_data };
  } else if (error.config.url === '/filter_label.json') {
    let data: ESObject = await MyConfig.context.resourceManager.getRawFileContent(`filter_label.json`);
    let str: ESObject = JSON.parse(buffer.from(data).toString());
    return { data: str.mock_data };
  } else if (error.config.url === '/favorite') {
    const data: ESObject = JSON.parse(error.config.data);
    if (data && data.favoriteId) {
      favoriteService.addFavorite(data.favoriteId);
      return { data: true };
    }
  } else if (error.config.url === '/cancel-favorite') {
    const data: ESObject = JSON.parse(error.config.data);
    if (data && data.favoriteId) {
      favoriteService.cancelFavorite(data.favoriteId);
      return { data: true };
    }
  } else if (error.config.url === '/my-favorites') {
    const favorites = favoriteService.getFavoriteIdList();
    return { data: favorites };
  } else if (error.config.url === '/live/status') {
    let data: ESObject = await MyConfig.context.resourceManager.getRawFileContent(`live_status.json`);
    let str: ESObject = JSON.parse(buffer.from(data).toString());
    return { data: str.mock_data };
  } else if (error.config.url === '/activityList.json') {
    let data: ESObject = await MyConfig.context.resourceManager.getRawFileContent(`activityList.json`);
    let str: ESObject = JSON.parse(buffer.from(data).toString());
    return { data: str.mock_data };
  } else if (error.config.url === '/videoList.json') {
    let data: ESObject = await MyConfig.context.resourceManager.getRawFileContent(`videoList.json`);
    let str: ESObject = JSON.parse(buffer.from(data).toString());
    return { data: str.mock_data };
  } else if (error.config.url === '/partnerList.json') {
    let data: ESObject = await MyConfig.context.resourceManager.getRawFileContent(`partnerList.json`);
    let str: ESObject = JSON.parse(buffer.from(data).toString());
    return { data: str.mock_data };
  } else if (error.config.url === '/advertiseList.json') {
    let data: ESObject = await MyConfig.context.resourceManager.getRawFileContent(`advertiseList.json`);
    let str: ESObject = JSON.parse(buffer.from(data).toString());
    return { data: str.mock_data };
  } else if (error.config.url === '/getPersonalDetail') {
    const data: ESObject = {
      ticketId: '123',
      name: '张三',
      userAvatar: 'my2%2Fmy_useravatar.png?token=ae7805b6-8997-43a5-a6f8-7ffe8abdf9f0',
      mobile: 'a00****0000',
      enterprise: 'xxx公司',
      ticketTypeName: 'VIP票',
      meetDay: ['2025-09-26', '2025-09-28'],
    };
    return { data: data };
  } else if (error.config.url === '/map.json') {
    let data: ESObject = await MyConfig.context.resourceManager.getRawFileContent(`map.json`);
    let str: ESObject = JSON.parse(buffer.from(data).toString());
    return { data: str.mock_data };
  } else if (error.config.url === '/traffic.json') {
    let data: ESObject = await MyConfig.context.resourceManager.getRawFileContent(`traffic.json`);
    let str: ESObject = JSON.parse(buffer.from(data).toString());
    return { data: str.mock_data };
  } else if (error.config.url === '/catering.json') {
    let data: ESObject = await MyConfig.context.resourceManager.getRawFileContent(`catering.json`);
    let str: ESObject = JSON.parse(buffer.from(data).toString());
    return { data: str.mock_data };
  } else if (error.config.url === '/getMyLabel') {
    const labels = interestLabelService.getInterestLabels();
    return { data: labels };
  } else if (error.config.url === '/setInterestLabel') {
    const data: ESObject = JSON.parse(error.config.data);
    interestLabelService.setInterestLabels(data.interestLabels);
    return { data: true };
  } else if (error.config.url === '/getInterestLabel.json') {
    let data: ESObject = await MyConfig.context.resourceManager.getRawFileContent(`interest_label.json`);
    let str: ESObject = JSON.parse(buffer.from(data).toString());
    return { data: str.mock_data };
  } else if (error.config.url === '/qaArticle.json') {
    let data: ESObject = await MyConfig.context.resourceManager.getRawFileContent(`qa_article.json`);
    let str: ESObject = JSON.parse(buffer.from(data).toString());
    return { data: str.mock_data };
  } else if (error.config.url === '/roleArticleList.json') {
    let data: ESObject = await MyConfig.context.resourceManager.getRawFileContent(`roleArticleList.json`);
    let str: ESObject = JSON.parse(buffer.from(data).toString());
    return { data: str.mock_data };
  } else if (error.config.url === '/Logout') {
    return { data: true };
  }

  return { data: CONTINUE };
}

// 封装请求方法
class RequestHttp {
  get<T>(url: string, params?: object): Promise<ApiResponse<T>> {
    return instance.get<null, ApiResponse<T>>(url, { params, baseURL: MyConfig.URL });
  }

  // 封装post方法
  post<T>(url: string, data?: object, config?: AxiosRequestConfig): Promise<ApiResponse<T>> {
    return instance.post<null, ApiResponse<T>>(url, data, config);
  }

  // 封装delete方法
  delete<T>(url: string, data?: object): Promise<ApiResponse<T>> {
    return instance.delete<null, ApiResponse<T>>(url, data);
  }

  // 封装put方法
  put<T>(url: string, data?: object): Promise<ApiResponse<T>> {
    return instance.put<null, ApiResponse<T>>(url, data);
  }
}


export const http = new RequestHttp();