/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { AppStorageV2, display, window } from '@kit.ArkUI';
import { TopBar, WindowSize } from 'commonlib';

@ComponentV2
export struct DataSharingPage {
  @Local windowSize: WindowSize = AppStorageV2.connect(WindowSize, () => new WindowSize())!
  @Local nowDate: string = ''
  @Local contentHeight: number = 0
  uiContext: UIContext = this.getUIContext()
  private pageSize: window.Size = {
    width: display.getDefaultDisplaySync().width,
    height: display.getDefaultDisplaySync().height
  };

  aboutToAppear(): void {
    this.getCurrentScreenWidthAndHeight()
    //获取时间
    this.nowDate = this.getNowDateString()
  }

  getNowDateString(): string {
    let currentTimestamp = Date.now();
    let nowDate = new Date(currentTimestamp);
    const year = nowDate.getFullYear();
    const month = ('0' + (nowDate.getMonth() + 1)).slice(-2);
    const day = ('0' + nowDate.getDate()).slice(-2);
    const hour = nowDate.getHours();
    const min = nowDate.getMinutes();
    const sec = nowDate.getSeconds();
    return `${year}-${month}-${day}  ${hour}:${min}:${sec}`;
  }

  /**
   * 获取屏幕宽高
   */
  getCurrentScreenWidthAndHeight() {
    this.contentHeight = this.uiContext.px2vp(this.windowSize.screenHeight - this.windowSize.statusHeight -
    this.windowSize.bottomHeight) - 56
  }

  build() {
    Column() {
      TopBar({ title: $r('app.string.third_party_information_sharing') })
        .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
      Scroll() {
        Column() {
          Text($r('app.string.third_party_information_sharing'))
            .fontSize($r('sys.float.Title_S'))
            .height($r('app.float.vp_27'))
            .fontWeight(FontWeight.Bold)
            .margin({ top: $r('app.float.vp_15'), bottom: $r('app.float.vp_15') })
          Text(`生效时间：${this.nowDate}`)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
            .height($r('app.float.vp_19'))
            .fontWeight(FontWeight.Regular)
            .margin({ bottom: $r('app.float.vp_16') })
          Text('我们在引入合作伙伴之前会严格进行隐私安全尽职调查，' +
            '并通过合同约束要求合作伙伴采取严格的措施来保护您的个人数据。' +
            '在满足新的服务需求及业务功能变更时，我们可能会调整我们的合作伙伴，' +
            '并及时在本说明中向您公开说明最新情况。'+
            '请注意，共享信息合作伙伴具体使用情况请仔细阅读合作伙伴的隐私政策。' +
            '目前本应用涉及共享信息合作伙伴列表如下：\n\n ' +
            '请注意，合作方的代码可能因为其版本升级、策略调整等原因导致数据处理类型存在一定变化，' +
            '请以其公示的官方说明为准。 \n\n' +
            '第三方公司名称：XXXX有限公司\n\n' +
            '产品/类型：XX \n\n' +
            '涉及个人信息：设备标识符（IMEI、MEID、IMSI、huawei ID、硬件序列号/Serial、ICCID、OAID）、' +
            '设备MAC地址、IP 地址、WLAN接入点（如SSID、BSSID)、Wifi列表、网络信息、设备信息、软件列表 \n\n' +
            '收集方式：SDK自行采集 \n\n' +
            '第三方个人信息处理规范：\n' +
            '*****.****.***')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_primary'))
            .height($r('app.float.vp_19'))
            .fontWeight(FontWeight.Regular)
            .margin({ bottom: $r('app.float.vp_16') })
        }
        .padding({ left: $r('app.float.vp_16'), right: $r('app.float.vp_16') })
        .width('100%')
        .height(this.getUIContext()
          .px2vp(this.pageSize.height - this.windowSize.statusHeight - this.windowSize.bottomHeight) - 56)
      }
      .height(this.contentHeight)
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)

  }
}

@Builder
export function DataSharingBuilder() {
  DataSharingPage()
}