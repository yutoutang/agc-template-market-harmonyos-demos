import { common } from '@kit.AbilityKit';
import { DialogCallBuilder, IBaseStore, Params, PopViewUtils, SystemSceneUtils } from 'foundation';
import { HomeBaseVM } from '../viewmodel/HomeBaseVM';

@ComponentV2
export struct StoreList {
  homeVM: HomeBaseVM = HomeBaseVM.instance;
  scroller = new Scroller();

  getStoreLocation(item: IBaseStore) {
    return `距您${item.distance ?? '0m'} | ${item.address}`
  }

  @Builder
  StoreCard(item: IBaseStore) {
    Column({space: 12}) {
      Row() {
        Text(item.storeName)
          .fontSize(16)
          .fontWeight(500)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Start)

        Blank()

        SymbolGlyph($r('sys.symbol.local')).fontSize(14).fontColor([$r('sys.color.icon_primary')])
        Text(item.distance ?? '0m')
          .fontSize(10)
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(400)
          .margin({left: 4})
      }
      .width('100%')

      Text(item.address)
        .fontSize(10)
        .fontColor($r('sys.color.font_secondary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Start)

      Row() {
        SymbolGlyph($r('sys.symbol.clock')).fontSize(12).fontColor([$r('sys.color.icon_secondary')])
        Text('营业时间：09:00 - 22:30')
          .fontSize(10)
          .fontColor($r('sys.color.font_secondary'))
          .margin({left: 8})

        Blank()

        Image($r('app.media.ic_public_location')).width(24).height(24)
          .onClick(() => {
            const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
            SystemSceneUtils.jumpPetalMap(context, item.address, item.coords.split(','))
          })

        Image($r('app.media.ic_public_telephone')).width(24).height(24)
          .margin({left: 24})
          .onClick(() => {
            PopViewUtils.showPopView<Params>(wrapBuilder(DialogCallBuilder), new Params(item.mobile.split(',')),
              { alignment: DialogAlignment.Bottom, autoCancel: true });
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Column() {
      List({ space: 10 }) {
        LazyForEach(this.homeVM.dataSource, (item: IBaseStore) => {
          ListItem() {
            this.StoreCard(item)
          }
        }, (v: IBaseStore) => v.id + v.storeName)
        ListItem() {
          Text('--已经到底啦--').fontSize(12).margin({ top: 20, bottom: 30 }).width('100%').textAlign(TextAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      .padding(10)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .cachedCount(1)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .width('100%')
    .height('100%')
  }
}