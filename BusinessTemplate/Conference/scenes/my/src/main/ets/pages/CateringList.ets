import { AppUtil, MyConfig } from 'commons';
import { getMyCateringJson } from '../service/myUniversalService';
import { MyCaterItem } from '../viewModel/MyUniversalModel';
import { common } from '@kit.AbilityKit';

@Builder
export function CateringListBuilder() {
  CateringList();
}


@Component
struct CateringList {
  @Consume('pageStack') pageStack: NavPathStack;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('token') token: string = '';
  @StorageProp('deviceId') deviceId: string = '';
  @State loading: boolean = false;
  @State pageName: string = '';
  @State cateringList: MyCaterItem[] = [];

  aboutToAppear(): void {
    this.loadData();
  }

  loadData() {
    getMyCateringJson().then((res) => {
      res.data.forEach((item) => {
        if (item.title === this.pageName) {
          this.cateringList = item.list.sort((a, b) => {
            return a.order - b.order;
          });
        }
      });
      this.loading = false;
    });
  }

  @Builder
  CateItemCard(name: string, img: string, tagList: string[], desc: string, longitude: string, latitude: string,
    address: string) {
    Column() {
      Row() {
        Image(img).width(80).margin({ right: 12 });
        Column() {
          Text(name)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .lineHeight(20)
            .fontColor('#000000')
            .margin({
              bottom: 8,
            });
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(tagList, (item: string, index) => {
              Text(item) {
              }
              .fontSize(10)
              .fontColor('#FFBD00')
              .lineHeight(16)
              .backgroundColor('#66ffe59c')
              .padding({
                left: 6,
                right: 6,
                bottom: 2,
              })
              .borderRadius(2)
              .margin({
                right: 3,
                bottom: 3,
              });
            }, (item: string) => JSON.stringify(item));
          };

          Button('去这里').height(24).fontSize(12).margin({
            top: 11,
          }).onClick(() => {
            let mapUrl = this.getUIContext().getHostContext()!.resourceManager.getStringByNameSync('map_url');
            const bundleName = AppUtil.getBundleName();
            const uri =
              `${mapUrl}/routes?daddr=${latitude},${longitude}(${address})&type=drive&utm_source=${bundleName}`;
            let context = this.getUIContext().getHostContext()! as common.UIAbilityContext;
            context.openLink(uri, {
              appLinkingOnly: false,
            });

          });
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1);
      }.width('100%').alignItems(VerticalAlign.Top);

      Column() {
        Text(desc)
          .fontSize(12).lineHeight(18);
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .margin({ top: 12 })
      .padding(12)
      .backgroundColor('#F7F7F7')
      .borderRadius(15);
    }
    .padding({
      left: 14,
      right: 14,
      top: 16,
      bottom: 16,
    })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#ffffff')
    .borderRadius(14);
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          if (this.loading) {
            LoadingProgress()
              .layoutWeight(1)
              .width(80);
          } else {
            Column() {
              GridRow({ columns: 12, gutter: { x: 12, y: 12 } }) {
                ForEach(this.cateringList, (item: MyCaterItem, index) => {
                  GridCol({
                    span: {
                      xs: 12, // 超小屏幕(手机)占12列(即一行一列)
                      sm: 12, // 小屏幕
                      md: 6, // 中屏幕(折叠屏)占6列(即一行两列)
                      lg: 6, // 大屏幕
                      xl: 6, // 超大屏幕
                    },
                  }) {
                    this.CateItemCard(item.name,
                      `${MyConfig.URL}my3%2Fmy_catering_plate.png?token=219dd3e8-1dd1-4747-bab7-65d05d08fce5`,
                      item.tag, item.desc, item.longitude, item.latitude, item.address);
                  };
                }, (item: MyCaterItem) => JSON.stringify(item));
              };
            }
            .padding({
              left: 16,
              right: 16,
              top: 12,
              bottom: 12,
            })
            .margin({
              bottom: 24,
            });
          }
        }
        .alignItems(HorizontalAlign.Start)
        .constraintSize({
          minHeight: '100%',
        });
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring);
    }
    .title(`${this.pageName}美食`)
    .onReady((ctx: NavDestinationContext) => {
      try {
        const myParams = ctx?.pathInfo?.param as Record<string, string>;
        if (myParams) {
          this.pageName = myParams.name;
        }
      } catch (e) {
      }
    })
    .backgroundColor('#F1F3F5')
    .padding({ top: px2vp(this.topRectHeight) });
  }
}