import { MyConfig } from 'commons';
import { getMyCateringJson } from '../service/myUniversalService';
import { MyCatering } from '../viewModel/MyUniversalModel';

@Builder
export function CateringBuilder() {
  Catering();
}

class CateringListParams {
  name: string;

  constructor(name: string) {
    this.name = name;
  }
}

@Component
struct Catering {
  @Consume('pageStack') pageStack: NavPathStack;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('token') token: string = '';
  @StorageProp('deviceId') deviceId: string = '';
  @State loading: boolean = false;
  @State cateringList: MyCatering[] = [];

  aboutToAppear(): void {
    this.loadData();
  }

  @Builder
  CateItem(name: string, time: string, address: string, img: string) {
    Column() {
      Row() {
        Image(`${MyConfig.URL}my3%2Fmy_catering_cate.svg?token=4369ec66-a68b-448b-b1f3-3a8115860e39`)
          .width(28)
          .margin({ right: 10 });
        Text(name).fontSize(14).fontWeight(FontWeight.Bold).lineHeight(20).fontColor('#333333');
      }.width('100%').margin({ bottom: 9 });

      Image(img).width('100%').margin({ bottom: 12 });
      Text() {
        Span('时间：').fontColor('#e6000000');
        Span(time).fontColor('#99000000');
      }.fontSize(12).lineHeight(18);

      Text() {
        Span('地点：').fontColor('#e6000000');
        Span(address).fontColor('#99000000');
      }.fontSize(12).lineHeight(18).margin({ top: 5 });

      Button('点击查看  →')
        .width('100%')
        .height(33)
        .backgroundColor(Color.Transparent)
        .backgroundImage(`${MyConfig.URL}my2%2Fcate_1_btn_bg.png?token=210756d8-f55a-4dce-8b95-25d5443b915e`)
        .backgroundImageSize(ImageSize.FILL)
        .fontColor($r('sys.color.font_on_primary'))
        .fontSize($r('sys.float.Body_M'))
        .margin({ top: 12 });


    }
    .padding({
      left: 16,
      right: 16,
      top: 9,
      bottom: 23,
    })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#ffffff')
    .borderRadius(15)
    .onClick(() => {
      this.pageStack.pushPath({
        name: 'CateringList',
        param: new CateringListParams(name),
      });
    });
  }

  loadData() {
    getMyCateringJson().then((res) => {
      this.cateringList = res.data;
      this.loading = false;
    });
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
                ForEach(this.cateringList, (item: MyCatering, index: number) => {
                  GridCol({
                    span: {
                      xs: 12, // 超小屏幕(手机)占12列(即一行一列)
                      sm: 12, // 小屏幕
                      md: 6, // 中屏幕(折叠屏)占6列(即一行两列)
                      lg: 6, // 大屏幕
                      xl: 6, // 超大屏幕
                    },
                  }) {
                    this.CateItem(item.title, item.time, item.address,
                      `${MyConfig.URL}${item.image}`);
                  };
                }, (item: MyCatering) => JSON.stringify(item));
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
    .title('园区餐饮')
    .backgroundColor('#F1F3F5')
    .padding({ top: px2vp(this.topRectHeight) });
  }
}