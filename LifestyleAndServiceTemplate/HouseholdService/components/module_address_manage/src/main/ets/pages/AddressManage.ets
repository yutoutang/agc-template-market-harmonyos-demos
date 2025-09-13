import { LengthMetrics } from '@kit.ArkUI';
import { RouterMap, UIEmpty } from 'module_base'
import { AddrListVM } from '../viewmodel/AddressListViewModel'
import { AddrViewModel } from '../viewmodel/AddrViewModel';
import { ParamAddressPage, TypeAddressPage } from '../common/Constant';

@Builder
export function AddressManageBuilder() {
  AddressManageModule()
}

@ComponentV2
export struct AddressManageModule {
  addrVM: AddrListVM = AddrListVM.instance;

  build() {
    NavDestination() {
      Column() {
        if (this.addrVM.list.length) {
          List({ space: 10, scroller: this.addrVM.listScroller }) {
            ForEach(this.addrVM.list, (v: AddrViewModel) => {
              ListItem() {
                this.SingleLocationCard(v)
              }
              .padding({
                left: 10,
                right: 10,
              })
              .swipeAction({
                end: {
                  builder: () => {
                    this.ItemEnd(v)
                  },
                  onAction: () => {
                    this.addrVM.deleteConfirm(v);
                  },
                },
                edgeEffect: SwipeEdgeEffect.Spring,
              })
            }, (item: AddrViewModel) => JSON.stringify(item))
          }
          .width('100%')
          .layoutWeight(1)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .padding({
            top: 10,
            bottom: 20,
          })
        } else {
          Column() {
            UIEmpty({ emptyDesc: '暂无地址', fg: 12 }).margin({ top: 200 })
          }
          .layoutWeight(1)
        }

        this.BottomBar()
      }
      .width('100%')
      .height('100%')
    }
    .title('地址管理', { backgroundColor: Color.White, paddingStart: new LengthMetrics(10) })
    .backgroundColor($r('app.color.common_page_bg'))
    .onReady((context) => {
      this.addrVM.setStack(context.pathStack);
      this.addrVM.getRouteParam();
      this.addrVM.queryList();
    })
  }

  @Builder
  ItemEnd(v: AddrViewModel) {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.trash_fill'))
          .fontColor([$r('sys.color.font_on_primary')])
          .fontWeight(FontWeight.Normal)
          .fontSize(24)
      }
      .type(ButtonType.Circle)
      .width(40)
      .height(40)
      .backgroundColor($r('app.color.common_red'))
      .onClick(() => {
        this.addrVM.deleteConfirm(v);
      })
    }
    .padding({ left: 20, right: 20 })
  }

  @Builder
  SingleLocationCard(v: AddrViewModel) {
    Column({ space: 10 }) {
      Row() {
        Text(v.name).fontSize(10).fontColor($r('app.color.common_grey'))
        Blank()
        Image($r('app.media.ic_public_feedback'))
          .width(16)
          .responseRegion({
            x: '-50%',
            y: '-50%',
            width: '200%',
            height: '200%',
          })
          .onClick(() => {
            const param: ParamAddressPage = {
              type: TypeAddressPage.EDIT,
              param: v.getModel,
            };
            this.addrVM.stack.pushPath({
              name: RouterMap.EDIT_ADDRESS,
              param: param,
              onPop: (info: PopInfo) => {
                if (info.result) {
                  this.addrVM.queryList();
                }
              },
            });
          })
      }
      .width('100%')

      Text(v.address).fontSize(14).fontWeight(500).fontColor(Color.Black)
      Row({ space: 4 }) {
        Text(v.contactName).fontSize(12).fontColor($r('app.color.common_grey'))
        Text(v.contactPhone).fontSize(12).fontColor($r('app.color.common_grey'))
      }
    }
    .width('100%')
    .padding(10)
    .borderRadius(8)
    .backgroundColor(this.addrVM.isSelected(v) ? $r('app.color.common_theme_color_5') : Color.White)
    .borderWidth(1)
    .borderColor(this.addrVM.isSelected(v) ? $r('app.color.common_theme_color') : Color.White)
    .stateStyles({
      pressed: {
        .backgroundColor($r('app.color.grey_10'))
        .borderColor($r('app.color.grey_10'))
      },
    })
    .alignItems(HorizontalAlign.Start)
    .onClick(() => {
      if (this.addrVM.needPop) {
        this.addrVM.stack.pop(v);
      }
    })
  }

  @Builder
  BottomBar() {
    Row() {
      Button('新增地址')
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(500)
        .width('100%')
        .height(40)
        .onClick(() => {
          const param: ParamAddressPage = {
            type: TypeAddressPage.NEW,
          };
          this.addrVM.stack.pushPath({
            name: RouterMap.EDIT_ADDRESS,
            param,
            onPop: (info: PopInfo) => {
              if (info.result) {
                this.addrVM.queryList();
              }
            },
          });
        })
    }
    .padding(10)
  }
}
