import { getQaArticleList, IArticle, MyConfig } from 'commons';

@Builder
export function QaBuilder() {
  Qa();
}

@Component
struct Qa {
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('token') token: string = '';
  @StorageProp('deviceId') deviceId: string = '';
  @State loading: boolean = false;
  @State cardsData: IArticle[] = [];
  @State currentIndex: number = 0;

  aboutToAppear(): void {
    getQaArticleList().then(res => {
      let list = res.data;
      // 按照sort 排序
      list.sort((a, b) => {
        return a.order - b.order;
      });
      this.cardsData = list;
    }).catch(() => {

    }).finally(() => {
      this.loading = false;
    });
  }

  // 切换指定卡片的展开/收起状态
  toggleCard(index: number) {
    animateTo({
      duration: 200,
      curve: Curve.EaseOut,
    }, () => {
      if (this.currentIndex === index) {
        this.currentIndex = -1;
        return;
      }
      this.currentIndex = index;
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
            Column({ space: 12 }) {
              ForEach(this.cardsData, (card: IArticle, index: number) => {
                Column() {
                  Row() {
                    Image(`${MyConfig.URL}my2%2Ficon_qa.png?token=93ee14ae-49f4-4d35-99b8-143b93666fca`)
                      .width(16)
                      .margin({ right: 6 });

                    Row() {
                      Text(card.title)
                        .fontSize(14)
                        .fontWeight(FontWeight.Bold)
                        .lineHeight(20)
                        .fontColor('#000000')
                        .layoutWeight(1);
                      Image($r('sys.media.ohos_ic_public_arrow_down'))
                        .width(24)
                        .height(24)
                        .fillColor('#99000000')
                        .rotate({ angle: this.currentIndex === index ? 180 : 0 })
                        .animation({
                          duration: 300,
                          curve: Curve.FastOutSlowIn,
                        });
                    }.layoutWeight(1);
                  }
                  .width('100%')
                  .height(48)
                  .justifyContent(FlexAlign.SpaceBetween)
                  .alignItems(VerticalAlign.Center);

                  if (this.currentIndex === index) {

                    Column() {
                      Divider()
                        .width('100%').color('E4E4E4').margin({ bottom: 13 });
                      Text(card.summary)
                        .fontSize(12)
                        .lineHeight(18)
                        .fontColor('#99000000')
                        .margin({
                          right: 12,
                        })
                        .textAlign(TextAlign.Start);
                    }
                    .alignItems(HorizontalAlign.Start)
                    .animation({
                      duration: 300,
                      curve: Curve.EaseOut,
                    })
                    .visibility(this.currentIndex === index ? Visibility.Visible : Visibility.None)
                    .width('100%')
                    .padding({
                      bottom: 14,
                      left: 12,
                    });
                  }
                }
                .padding({
                  left: 16,
                  right: 16,
                })
                .borderRadius(14)
                .backgroundColor(Color.White)
                .width('100%')
                .onClick(() => this.toggleCard(index));
              }, (card: IArticle) => JSON.stringify(card));

            }.padding({
              left: 16,
              right: 16,
            })
            .margin({
              top: 12,
              bottom: 80,
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
    .title('常见问题')
    .padding({ top: px2vp(this.topRectHeight) })
    .backgroundColor('#F1F3F5');
  }
}