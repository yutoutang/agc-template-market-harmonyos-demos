import { DigestObj, TransVar, XFConfig } from '../model/Translator';
import { buffer, util } from '@kit.ArkTS';
import CryptoJS from '@ohos/crypto-js';
import axios, { AxiosRequestConfig, AxiosResponse } from '@ohos/axios';
import { TranLogger } from '../util/TranLogger';

export class TranslatorService {
  // TODO 添加文本翻译对应的Websocket服务接口认证信息
  private static config: XFConfig = {
    // 请求地址
    hostUrl: 'https://itrans.xfyun.cn/v2/its',
    host: 'itrans.xfyun.cn',
    //在控制台-我的应用-机器翻译获取
    appid: 'dd674b07',
    //在控制台-我的应用-机器翻译获取
    apiSecret: 'ZmZmYzBhNjM5ZTAxY2IzNzc4MGJkMGNj',
    //在控制台-我的应用-机器翻译获取
    apiKey: 'bf6949ea0abbd9dd17b5fed25002525b',
    uri: '/v2/its',
  }

  private static getPostBody(text: string, from: string, to: string) {
    let base64 = new util.Base64Helper();
    let arr = new Uint8Array(buffer.from(text, 'utf-8').buffer)
    let base64Str = base64.encodeToStringSync(arr);

    let digestObj: DigestObj = {
      //填充common
      common: {
        app_id: TranslatorService.config.appid,
      },
      //填充business
      business: {
        from: from,
        to: to,
      },
      //填充data
      data: {
        text: base64Str,
      },
    }
    return digestObj
  }

  // 请求获取请求体签名
  private static getDigest(body: DigestObj) {
    return 'SHA-256=' + CryptoJS.enc.Base64.stringify(CryptoJS.SHA256(JSON.stringify(body)))
  }

  // 鉴权签名
  private static getAuthStr(date: string, digest: string) {
    let signatureOrigin =
      `host: ${TranslatorService.config.host}\ndate: ${date}\nPOST ${TranslatorService.config.uri} HTTP/1.1\ndigest: ${digest}`
    let signatureSha: string = CryptoJS.HmacSHA256(signatureOrigin, TranslatorService.config.apiSecret)
    let signature: string = CryptoJS.enc.Base64.stringify(signatureSha)
    let authorizationOrigin =
      `api_key="${TranslatorService.config.apiKey}", algorithm="hmac-sha256", headers="host date request-line digest", signature="${signature}"`
    return authorizationOrigin
  }

  static async translate(from: string, to: string, text: string) {
    const transVar: TransVar = {
      text, //待翻译文本
      from: from === 'zh' ? 'cn' : from, //源语种
      to: to === 'zh' ? 'cn' : to, //目标语种
    }
    const date = (new Date().toUTCString())
    const postBody = TranslatorService.getPostBody(transVar.text, transVar.from, transVar.to)
    const digest = TranslatorService.getDigest(postBody)
    const options: AxiosRequestConfig = {
      url: TranslatorService.config.hostUrl,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json,version=1.0',
        'Host': TranslatorService.config.host,
        'Date': date,
        'Digest': digest,
        'Authorization': TranslatorService.getAuthStr(date, digest),
      },
      data: postBody,
    }

    try {
      const response: AxiosResponse = await axios.request(options)
      return response.data.data.result.trans_result.dst as string
    } catch (e) {
      TranLogger.info(JSON.stringify(e))
    }
    return ''
  }
}