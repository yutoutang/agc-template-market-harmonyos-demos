import {
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  CommonConstants,
  RandomUtils,
  RouterMap,
  RouterUtils
} from 'lib_common';
import { FilterComponents, ProductWaterFlow, RequestType } from 'lib_product_waterflow';
import { NavHeaderBar } from 'lib_widget';
import { FilterComponentsDialog } from '../components/FilterComponentsDialog';
import { HomeViewModel } from '../viewmodels/HomeViewModel';
import { HashMap } from '@kit.ArkTS';

@Builder
export function StoreCategoryPageBuilder() {
  StoreCategoryPage()
}

@ComponentV2
export struct StoreCategoryPage {
  @Local vm: HomeViewModel = new HomeViewModel();
  @Local title: string = '地方菜系'
  @Local categoryId: string = ''
  @Local index: number = 0;
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Param scroller: Scroller = new Scroller();

  @Computed
  get storeWaterFlowTemplate() {
    if (this.curBreakpoint.value === BreakpointTypeEnum.SM) {
      return '1fr 1fr'
    }
    return '1fr 1fr 1fr'
  }

  @Local
  changeByCategoryNum: number = 0
  dialogController: CustomDialogController = new CustomDialogController({
    builder: FilterComponentsDialog({
      vm: this.vm,
      changeByThreshold: this.changeByCategoryNum,
      changeByThresholdZ: (value: number) => {
        this.changeByCategoryNum = value
      },
      confirm: () => {
        this.confirm()
      },
    }),
    width: '100%',
    height: '55%',
    cornerRadius: 16,
    offset: { dx: 0, dy: -68 },
  });

  confirm() {
    this.dialogController.close()
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        title: this.title,

      })
      Column() {
        Column() {
          Row() {
            Row() {
              Image($r('app.media.search'))
                .width(20)
                .height(20)
                .margin({ left: 16, right: 5 })
                .fillColor('#FFC0B7B7')

              Text('请输入搜索关键词')
                .fontSize(16)
                .layoutWeight(1)
                .textAlign(TextAlign.Start)
                .fontColor('#FFC0B7B7')
            }
            .width('82%')
            .height(40)
            .backgroundColor('#D1FFFFFF')
            .borderRadius(24)
            .margin({ right: 10 })
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
              this.vm.jumpToSearchStorePage(this.index);
            })

            Row() {
              Text('筛选')
                .fontSize($r('app.string.font_size_14'))
                .margin({ right: $r('app.string.space_xs') })
              Image($r('app.media.ic_sx'))
                .height(16)
                .fillColor($r('sys.color.black'))
            }
            .onClick(() => {
              this.vm.isShowFilter = this.vm.isShowFilter ? false : true
            })
          }
          .width('100%')
          .margin({ bottom: 10 })
        }.width('100%')
        .padding({
          left: 10,
          right: 10,
        })

        Stack({ alignContent: Alignment.Top }) {
          Column() {
            ProductWaterFlow({
              customColumnTemplate: this.storeWaterFlowTemplate,
              categoryId: this.categoryId,
              changeByCategoryNum: this.vm.changeByCategoryNum,
              requestType: RequestType.BY_CATEGORY,
              scoreThreshold: this.vm.scoreThreshold,
              salesThreshold: this.vm.salesThreshold,
              address: this.vm.settingInfo.address,
              showInitLoading: true,
              deliveryTimeThreshold: this.vm.deliveryTimeThreshold,
              handleProductClick: (id) => {
                RouterUtils.pushPathByName(RouterMap.STORE_PAGE, id)
              },
              handleBack: () => {
                this.scroller.scrollEdge(Edge.Top);
              },
            });
          }
          .padding({
            left: 10,
            right: 10,
            top: 5,
            bottom: 5
          })

          if (this.vm.isShowFilter) {
            // 蒙层
            Column() {
            }
            .borderRadius({
              topLeft: 12,
              topRight: 12,
            })
            .margin({
              top: this.vm.isShowFilter ? 8 : 0,
            })
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.FULL_PERCENT)
            .backgroundColor($r('sys.color.mask_fourth'))
            .onClick(() => {
              this.vm.isShowFilter = false
            })

            // 筛选内容
            Column() {
              Text('筛选店铺')
                .fontWeight(FontWeight.Bold)
                .fontSize(24)
                .alignSelf(ItemAlign.Start)
                .padding({ left: 16, top: 16 })
              FilterComponents({
                scoreThreshold: this.vm.scoreThreshold,
                salesThreshold: this.vm.salesThreshold,
                deliveryTimeThreshold: this.vm.deliveryTimeThreshold,
                confirm: () => {
                  this.vm.isShowFilter = false
                },
                handleClickItem: (item: HashMap<string, number>) => {
                  // 遍历item值，获取对应的数据
                  if (!item.isEmpty()) {
                    this.vm.scoreThreshold = item.get(FilterComponents.EVALUATION_KEY)
                    this.vm.salesThreshold = item.get(FilterComponents.SALESVOLUME_KEY)
                    this.vm.deliveryTimeThreshold = item.get(FilterComponents.TIME_KEY)
                  } else {
                    // 清空筛选条件
                    this.vm.scoreThreshold = undefined
                    this.vm.salesThreshold = undefined
                    this.vm.deliveryTimeThreshold = undefined
                  }
                  //随机数
                  this.vm.changeByCategoryNum = RandomUtils.random(100)
                }

              })
            }
            .margin({
              top: this.vm.isShowFilter ? 6 : 0,
            })
            .backgroundColor($r('app.color.background_color_white'))
            .borderRadius(12)
            .width(CommonConstants.FULL_PERCENT)
          }
        }
        .layoutWeight(1)
      }
      .backgroundColor(Color.Transparent)
      .layoutWeight(1)
    }
    .linearGradient({
      colors: [['#FFF17D00', 0], ['#00FBB535', 0.4]],
    })
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background_color_grey'))
    .padding({ bottom: this.vm.windowModel.windowBottomPadding })
    .onReady((context) => {
      const param = context.pathInfo.param as Record<string, string>
      if (param) {
        this.title = param.title
        this.categoryId = param.id
        this.index = parseInt(param.index)
      }
    })

  }
}