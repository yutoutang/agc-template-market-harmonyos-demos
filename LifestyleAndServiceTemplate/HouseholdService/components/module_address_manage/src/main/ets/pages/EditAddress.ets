/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { LengthMetrics } from '@kit.ArkUI';
import { RouterMap } from 'module_base';
import { FormItem, FormType } from 'module_form';
import { ParamAddressPage } from '../common/Constant';
import { AddrViewModel } from '../viewmodel/AddrViewModel';

@Builder
export function EditAddressBuilder() {
  EditAddressModule()
}

@ComponentV2
export struct EditAddressModule {
  @Local addressVM: AddrViewModel = new AddrViewModel();
  stack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          this.FormCard()
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

        this.BottomBar()
      }
      .width('100%')
      .height('100%')
    }
    .title('添加地址', { paddingStart: new LengthMetrics(10) })
    .backgroundColor($r('app.color.common_page_bg'))
    .onReady((context) => {
      this.stack = context.pathStack;

      const params: ParamAddressPage[] =
        this.stack.getParamByName(RouterMap.EDIT_ADDRESS) as ParamAddressPage[];
      if (params.length && params[params.length - 1]) {
        const param = params[params.length - 1];
        if (param.param) {
          this.addressVM = new AddrViewModel(param.param);
        }
      }
    })

  }

  @Builder
  FormCard() {
    Column() {
      FormItem({
        param: {
          type: FormType.ADDRESS,
          label: '所在地区',
          required: true,
        },
        value: this.addressVM.name!!,
      })

      FormItem({
        param: {
          type: FormType.INPUT,
          label: '详细地址与门牌号',
          required: true,
        },
        value: this.addressVM.address!!,
      })

      FormItem({
        param: {
          type: FormType.INPUT,
          label: '收货人姓名',
          required: true,
        },
        value: this.addressVM.contactName!!,
      })

      FormItem({
        param: {
          type: FormType.INPUT,
          inputType: InputType.PhoneNumber,
          label: '手机号',
          required: true,
          last: true,
        },
        value: this.addressVM.contactPhone!!,
      })
    }
    .margin({ top: 10 })
    .padding({ left: 12, right: 12 })
    .backgroundColor(Color.White)
  }

  @Builder
  BottomBar() {
    Row() {
      Button('保存地址')
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(500)
        .width('100%')
        .height(40)
        .onClick(() => {
          this.addressVM.onSubmit().then(() => {
            this.stack.pop('ok');
          });
        })
    }
    .padding(10)
  }
}
