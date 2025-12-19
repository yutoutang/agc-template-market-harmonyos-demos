import { BEDROOM_MAP, CommonUtils, Constant, ILayout } from 'foundation';
import { Layout } from '../model/Index';
import { Util } from '../util/Util';

@ComponentV2
export struct Layouts {
  @Local selectLayouts: ILayout[] = [];
  @Local layoutTabIndex: number = 0;
  @Param layouts: ILayout[] = [];
  @Local initialLayouts: Layout[] = [];

  aboutToAppear(): void {
    this.initialLayouts = Util.getLayoutList(this.layouts);
    this.selectLayouts = this.initialLayouts[0].layouts;
  }

  @Builder
  layoutBuilder() {
    Column({ space: 14 }) {
      Row({ space: 12 }) {
        ForEach(this.initialLayouts, (item: Layout, index: number) => {
          Text() {
            Span(item.bedroomCount === 0 ? '全部' : `${BEDROOM_MAP.get(item.bedroomCount)}室`);
            Span(`(${item.layouts.length})`);
          }
          .fontSize(12)
          .borderRadius(12)
          .fontColor(this.layoutTabIndex === index ? $r('sys.color.white') : $r('sys.color.black'))
          .backgroundColor(this.layoutTabIndex === index ? '#0A59F7' : '#F1F3F5')
          .padding({
            left: 8,
            right: 8,
            top: 4,
            bottom: 4,
          })
          .onClick(() => {
            this.layoutTabIndex = index;
            this.selectLayouts = item.layouts;
          });
        }, (item: Layout, index: number) => item.layouts.toString());
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.Start);

      List({ space: 12 }) {
        ForEach(this.selectLayouts, (item: ILayout) => {
          ListItem() {
            Stack({ alignContent: Alignment.TopStart }) {
              Column({ space: 8 }) {
                Image(CommonUtils.handleImgUrl(item.image, this.getUIContext().getHostContext()!))
                  .size({ height: 124, width: 184 })
                  .border({ width: 1, color: 'rgba(0,0,0,0.20)', radius: 8 })
                  .padding({
                    left: 28,
                    right: 28,
                    top: 20,
                    bottom: 20,
                  });

                Column({ space: 4 }) {
                  Text(`${item.bedroom}室${item.lounge}厅${item.bathroom}卫`)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.black'))
                    .opacity(0.9);
                  Text(`建面${item.space}㎡/南北，约${item.total}万/套`)
                    .opacity(0.9)
                    .fontSize(10)
                    .fontColor($r('sys.color.black'));
                }.alignItems(HorizontalAlign.Start).width(184);
              };

              if (item.isPivotal) {
                Text('主力户型')
                  .fontSize(8)
                  .fontColor($r('sys.color.white'))
                  .backgroundColor('#0A59F7')
                  .borderRadius({ bottomRight: 8, topLeft: 8 })
                  .padding({
                    left: 8,
                    right: 8,
                    top: 4,
                    bottom: 4,
                  });
              }
            };
          };
        }, (item: ILayout) => item.total.toString() + item.space.toString());
      }.listDirection(Axis.Horizontal).scrollBar(BarState.Off).alignSelf(ItemAlign.Start).edgeEffect(EdgeEffect.Spring);
    }.height(210);
  }

  build() {
    this.layoutBuilder();
  }
}