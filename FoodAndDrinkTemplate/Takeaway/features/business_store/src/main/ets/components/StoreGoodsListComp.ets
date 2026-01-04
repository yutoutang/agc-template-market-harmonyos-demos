import { CommonConstants } from 'lib_common';
import { Goods, GoodsTypeResp, MyCar } from 'lib_takeaway_api';
import { StorePageViewModel } from '../viewModels/StorePageVM';
import { GoodsTypeItem } from './GoodsTypeItem';
import { Constants } from '../common/Constants';
import { GoodInfoComp } from './GoodInfoComp';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct StoreGoodsListComp {
  @Consumer() storeCar: MyCar = AppStorageV2.connect(MyCar, () => new MyCar())!;
  @Require @Param vm: StorePageViewModel
  @Local currentIndex: number = 0;
  @Local index: number = 0
  // 当前搜索关键字
  @Local searchText: string = '';

  @Monitor('vm.displayGoodsList')
  displayGoodsListChange(monitor: IMonitor) {
    if (monitor.value()?.now) {
      this.index = this.vm.displayGoodsList.findIndex(item => item.goods?.some(i => i.isMust === Constants.GOODS_MUST))
    }
  }

  build() {
    Column() {
      Row() {
        // 商品分类
        List({ scroller: this.vm.titleItemScroller }) {
          ForEach(this.vm.originGoodsList, (item: GoodsTypeResp, index: number) => {
            ListItem() {
              GoodsTypeItem({
                typeName: item.typeName,
                hasIcon: item.id === Constants.GOOD_TYPE_HOT,
                isSelected: this.currentIndex === index,
                onClickAction: () => {
                  if (index !== undefined) {
                    this.currentIndexChangeAction(index, true);
                  }
                },
              })
            }
          }, (item: GoodsTypeResp) => item.typeName + this.currentIndex)
          ListItem() {
            Column()
              .width(CommonConstants.FULL_PERCENT)
              .height(78)
          }
        }
        .edgeEffect(EdgeEffect.Spring,{alwaysEnabled:true})
        .width(92)
        .height(CommonConstants.FULL_PERCENT)
        .listDirection(Axis.Vertical) // 排列方向
        .backgroundColor(Color.White)
        .scrollBar(BarState.Off)
        .divider({ strokeWidth: 1 })

        // 商品列表
        List({ scroller: this.vm.goodsScroller }) {
          // 商品搜索
          ListItem() {
            Search({ value: $$this.searchText, placeholder: '搜索商品' })
              .textFont({ size: $r('sys.float.Body_L'), weight: 400 })
              .backgroundColor('#F3F3F3')
              .width(CommonConstants.FULL_PERCENT)
              .placeholderFont({ size: $r('sys.float.Body_L') })
              .maxLength(20)
              .margin({
                top: 8,
              })
              .onChange((value: string) => {
                if (value) {
                  this.vm.displayGoodsList = this.vm.displayGoodsList.map((item) => {
                    item.goods = item.goods.filter(i => i.name?.includes(value))
                    return item
                  })
                } else {
                  this.vm.displayGoodsList = JSON.parse(JSON.stringify(this.vm.originGoodsList))
                }
              })
          }

          // 商品列表
          ForEach(this.vm.displayGoodsList, (item: GoodsTypeResp) => {
            ListItemGroup({
              header: this.titleHeader(item.typeName, item.goods.length),
              space: 10,
            }) {
              ForEach(item.goods, (listItem: Goods) => {
                ListItem() {
                  GoodInfoComp({ item: listItem, vm: this.vm })
                }
              }, (listItem: Goods) => JSON.stringify(listItem))

            }
          }, (item: GoodsTypeResp) => JSON.stringify(item))
          ListItem() {
            Column() {
              Divider().margin({ top: 12 })
              Text('已经到达底部')
                .fontSize(8)
                .fontWeight(300)
                .fontColor($r('sys.color.font_primary'))
                .margin({ top: 8 })
            }.width(CommonConstants.FULL_PERCENT).height(106)
          }
        }
        .padding({
          left: 8,
          right: 8,
        })
        .edgeEffect(EdgeEffect.Spring,{alwaysEnabled:true})
        .layoutWeight(1)
        .height(CommonConstants.FULL_PERCENT)
        .scrollBar(BarState.Off)
        .sticky(StickyStyle.None)
        .onScrollIndex((start: number) => this.currentIndexChangeAction(start - 1, false))
        .backgroundColor($r('sys.color.comp_background_list_card'))
      }
      .layoutWeight(1)

    }
    .width(CommonConstants.FULL_WIDTH)
    .height(CommonConstants.FULL_HEIGHT)
    .constraintSize({ maxHeight: CommonConstants.FULL_HEIGHT })
  }

  currentIndexChangeAction(index: number, isClassify: boolean): void {
    if (this.currentIndex !== index) {
      this.currentIndex = index;
      if (isClassify) {
        this.vm.goodsScroller.scrollToIndex(index + 1);
      } else {
        this.vm.titleItemScroller.scrollToIndex(index + 1);
      }
    }
  }

  @Builder
  titleHeader(title: string, count: number) {
    // 商品分类头部
    Row() {
      Text() {
        Span(`${title}`)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
        Span(`（${count}）`)
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.font_secondary'))
          .padding({ left: 4 })
      }
    }
    .margin({ bottom: 8, top: 8 })
  }
}