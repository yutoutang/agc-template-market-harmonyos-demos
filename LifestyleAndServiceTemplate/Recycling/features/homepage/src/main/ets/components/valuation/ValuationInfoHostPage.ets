import { BuildValuationInfoPageBuilder } from 'valuation_information'
import { phoneRouterControl, NavPageInfo } from 'oh_router'
import { Constants, RouterMap } from 'common'
import { OrderSubmitPageBuilder } from './OrderSubmitPage';

interface SelectionPair {
  title: string;
  value: string
}

interface SubmitData {
  modelName: string;
  imageSrc?: ResourceStr;
  deviceType: string;
  price: number;
  selections: SelectionPair[]
}

interface HostParams {
  modelName: string;
  imageSrc: ResourceStr;
  deviceType?: string
}

interface OrderParams {
  modelName: string;
  imageSrc?: ResourceStr;
  deviceType?: string;
  price?: number;
  selections?: SelectionPair[]
}

@Builder
export function ValuationInfoHostPageBuilder(params: object) {
  ValuationInfoHostPage({ params: params as HostParams })
}

@ComponentV2
export struct ValuationInfoHostPage {
  @Param params: HostParams = { modelName: '', imageSrc: $r('app.media.image_demo_phone3'), deviceType: 'phone' }

  build() {
    NavDestination() {
      Column() {
        BuildValuationInfoPageBuilder({
          modelName: this.params.modelName,
          imageSrc: this.params.imageSrc,
          deviceType: this.params.deviceType,
          onBack: () => phoneRouterControl.popPage(),
          onSubmit: (data: SubmitData) => {
            const requiredTitles =
              data.deviceType === 'computer' ? ['内存', '硬盘类型', '处理器'] : ['保修期', '容量', '颜色']
            const selectedTitles = new Set(data.selections?.map(s => s.title) ?? [])
            for (let t of requiredTitles) {
              if (!selectedTitles.has(t)) {
                this.getUIContext().getPromptAction().showToast({ message: `请选择${t}必选项！` })
                return
              }
            }
            const orderParam: OrderParams = {
              modelName: data.modelName,
              imageSrc: data.imageSrc,
              deviceType: data.deviceType,
              price: data.price,
              selections: data.selections,
            }
            const orderPage: NavPageInfo = {
              pageName: RouterMap.VALUATION_ORDER_PAGE,
              builder: wrapBuilder(OrderSubmitPageBuilder),
              param: orderParam,
            }
            phoneRouterControl.jumpPage(orderPage)
          },
        })
      }
      .width('100%')
      .height('100%')
    }
    .hideToolBar(true).title('填写估价信息').padding({ top: Constants.PADDING_7XL })
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }
}
