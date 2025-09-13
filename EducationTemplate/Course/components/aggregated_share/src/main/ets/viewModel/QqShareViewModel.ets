/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { IQQOpenApi, OpenApiConfig, QQOpenApiFactory, ShareResultType } from '@tencent/qq-open-sdk';
import { cryptoFramework } from '@kit.CryptoArchitectureKit'
import { promptAction } from '@kit.ArkUI';
import { QqShareContent, QqShareData, ShareOptions } from '../model/Model';

/**
 * QQ分享
 * 实际业务请填写实际appid
 */
export class QqShareViewModel {
  static appId = 102803516
  private static _instance: QqShareViewModel
  private static qqOpenApi: IQQOpenApi
  shareData: QqShareData = new QqShareData()

  public initQqShare(): IQQOpenApi {
    if (!QqShareViewModel.qqOpenApi) {
      let openApiOption: OpenApiConfig = {
        forceEnableWeb: false,
        autoHandleAuthResult: true,
      }

      QqShareViewModel.qqOpenApi =
        QQOpenApiFactory.createApi(QqShareViewModel.appId, openApiOption)
    }
    return QqShareViewModel.qqOpenApi
  }

  static get instance() {
    if (!QqShareViewModel._instance) {
      QqShareViewModel._instance = new QqShareViewModel()
    }
    return QqShareViewModel._instance
  }

  /*
   * 需要根据业务获取实际签名
   * */
  public genSign(appId: string | number, shareDataStr: string, timestamp: number, nonce: number) {
    let totalStr = `POSTconnect.qq.com/share?appid=${appId}&nonce=${nonce}&ts=${timestamp}&${shareDataStr}`
    return '业务签名'
  }

  /**
   * 生成 [min, max] 之间的密码学安全随机整数
   * --------------------------------------
   * @param min   最小值（包含）
   * @param max   最大值（包含）
   * @returns number
   */
  public randomIntSync(min: number, max: number): number {
    if (min > max) {
      throw new Error('min 必须 ≤ max');
    }
    const range = max - min + 1;

    // 计算需要多少字节：log2(range) / 8，向上取整
    const bytesNeeded = Math.ceil(Math.log2(range) / 8);

    // 生成安全随机字节
    const rand = cryptoFramework.createRandom();
    const blob = rand.generateRandomSync(bytesNeeded);
    const arr = blob.data; // Uint8Array

    // 字节 → 大整数
    let n = 0;
    for (let i = 0; i < arr.length; i++) {
      n = (n << 8) | arr[i];
    }

    // 映射到 [min, max]
    return min + (n % range);
  }

  public handleShareInfo(qrCodeInfo: ShareOptions) {
    /*
     * 生成时间戳并计算签名
     * */
    let timeStamp = Date.parse(new Date().toString()) / 1000
    let nonce = this.randomIntSync(100, 100_000_099);
    let shareContent: QqShareContent = {
      msgStyle: 0,
      title: qrCodeInfo.title,
      url: '',
      pictureUrl: qrCodeInfo.coverUrl as string,
    }
    let shareDataSign = this.genSign(QqShareViewModel.appId, qrCodeInfo.title, timeStamp, nonce)
    this.shareData.timestamp = timeStamp
    this.shareData.shareJson = JSON.stringify(shareContent)
    this.shareData.nonce = nonce
    this.shareData.shareJsonSign = shareDataSign
  }

  public async share(qrCodeInfo: ShareOptions) {
    this.handleShareInfo(qrCodeInfo)
    let result = await QqShareViewModel.qqOpenApi.share(2, this.shareData);
    switch (result.resultType) {
      case ShareResultType.Success: {
        promptAction.showToast({ message: '分享成功' })
      }
        break
      case ShareResultType.Cancel: {
        let msg: string = result.message ?? '用户取消分享'
        promptAction.showToast({ message: msg })
      }
        break
      case ShareResultType.Error: {
        let msg: string = result.message ?? '分享失败'
        promptAction.showToast({ message: msg })
      }
        break
    }
  }
}
