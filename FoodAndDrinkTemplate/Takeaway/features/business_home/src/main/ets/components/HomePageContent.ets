import {
  BreakpointStorage,
  BreakpointSystem,
  BreakpointTypeEnum,
  CommonConstants,
  iResourceMgr,
  RandomUtils,
  RouterMap,
  RouterUtils
} from 'lib_common';
import { FilterComponents, ProductWaterFlow } from 'lib_product_waterflow';
import { CategoryItem } from 'lib_takeaway_api';
import { common } from '@kit.AbilityKit';
import { HashMap } from '@kit.ArkTS';
import { HomeViewModel } from '../viewmodels/HomeViewModel';
import { StoreResponse } from 'lib_takeaway_api/src/main/ets/params/response/StoreResponse';

@ComponentV2
export struct HomePageContent {
  @Param
  bannerList: ResourceStr[] = [
    $r('app.media.homepage_banner1'),
    $r('app.media.homepage_banner2'),
    $r('app.media.homepage_banner3'),
  ];
  context: common.UIAbilityContext = getContext() as common.UIAbilityContext;
  @Local isShow: boolean = false
  @Param
  categoryList: CategoryItem[] = [];
  @Param
  storeList: StoreResponse[] = [];
  @Param
  scroller: Scroller = new Scroller();
  @Event
  handleClickCategory: (id: string, title: string, index: number) => void;
  @Local
  curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint
  @Require @Param
  vm: HomeViewModel;
  @Local
  changeByThreshold: number = 0

  @Computed
  get waterFlowTemplate() {
    if (this.curBreakpoint.value === BreakpointTypeEnum.SM) {
      return '1fr 1fr'
    }
    return '1fr 1fr 1fr'
  }

  build() {
    Column({ space: 12 }) {
      this.bannerBuilder();
      this.categoryBuilder();
      this.labelBuilder();
      ProductWaterFlow({
        bgColor: Color.Transparent,
        changeByThreshold: this.vm.changeByThreshold,
        scoreThreshold: this.vm.scoreThreshold,
        salesThreshold: this.vm.salesThreshold,
        address: this.vm.settingInfo.address,
        showInitLoading: true,
        deliveryTimeThreshold: this.vm.deliveryTimeThreshold,
        customColumnTemplate: this.waterFlowTemplate,
        handleProductClick: (id) => {
          RouterUtils.pushPathByName(RouterMap.STORE_PAGE, id)
        },
        handleBack: () => {
          this.scroller.scrollEdge(Edge.Top);
        },
      });
    }
    .padding({
      top: 16,
      left: 16,
      right: 16,
    })
    .backgroundColor(Color.Transparent);
  }

  @Builder
  bannerBuilder() {
    Swiper() {
      ForEach(this.bannerList, (item: ResourceStr, index: number) => {
        Image(item)
          .objectFit(ImageFit.Cover)
          .draggable(false)
          .onClick(() => {
            RouterUtils.pushPathByName(RouterMap.STORE_PAGE, `store_00${index + 1}`)
          })
      }, (item: ResourceStr, index: number) => JSON.stringify(item));
    }
    .width('100%')
    .indicator(false)
    .autoPlay(true)
    .clip(true)
    .borderRadius($r('app.float.border_radius_l'));
  }

  @Builder
  categoryBuilder() {
    Column() {
      Scroll() {
        Row({ space: 16 }) {
          ForEach(this.categoryList, (category: CategoryItem, index: number) => {
            Column() {
              Image(iResourceMgr.resolveUri(category.iconUrl))
                .width(48)
                .height(48)
                .margin({ bottom: 4 });
              Text(category.label)
                .fontSize(12)
                .fontColor(CommonConstants.FONT_COLOR_LEVEL3);
            }
            .constraintSize({ minWidth: 70 })
            .onClick(() => {
              this.handleClickCategory?.(category.id, category.label, index + 1)
            })
          }, (item: CategoryItem, index: number) => item.id)
        }
        .constraintSize({ minWidth: '100%' })
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .backgroundColor(CommonConstants.BACKGROUND_COLOR)
    .padding({ top: 16, bottom: 16 })
    .borderRadius(CommonConstants.BORDER_RADIUS_16)
  }

  @Builder
  labelBuilder() {
    Row() {
      Text() {
        Span('推荐店铺')
      }
      .fontWeight(FontWeight.Bold)
      .layoutWeight(1)

      Row() {
        Text('筛选')
          .fontSize($r('app.string.font_size_12'))
          .fontColor(CommonConstants.FONT_COLOR_LEVEL3)
          .margin({ right: $r('app.string.space_xs') })
        Image($r('app.media.ic_sx'))
          .height(16)
          .fillColor((this.vm.scoreThreshold !== undefined || this.vm.salesThreshold !== undefined ||
            this.vm.deliveryTimeThreshold !== undefined) ? '#FFF17D00' : CommonConstants.FONT_COLOR_LEVEL3)
      }
      .onClick(() => {
        this.isShow = true
        this.vm.isShowFilter = true
      })

    }
    .backgroundColor(Color.Transparent)
    .height(22)
    .width($r('app.string.size_percent_full'))
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  mySXBuilder(context: common.UIAbilityContext) {
    FilterComponents({
      scoreThreshold: this.vm.scoreThreshold,
      salesThreshold: this.vm.salesThreshold,
      deliveryTimeThreshold: this.vm.deliveryTimeThreshold,
      handleClickItem: (item: HashMap<string, number>) => {
        this.isShow = false
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
        this.changeByThreshold = RandomUtils.random(100)
      }
    });
  }
}
