import { ArticleModel, getPartnerList, MyConfig } from 'commons'

@Builder
export function PartnerBuilder() {
  Partner()
}


@Component
struct Partner {
  @Consume('pageStack') pageStack: NavPathStack
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('token') token: string = '';
  @StorageProp('deviceId') deviceId: string = '';
  @State loading: boolean = true;
  @State partnerList: ArticleModel[] = [];

  aboutToAppear(): void {
    getPartnerList().then(res => {
      let list = res.data
      // 按照sort 排序
      list.sort((a, b) => {
        return a.order - b.order
      })
      this.partnerList = list
    }).catch(() => {

    }).finally(() => {
      this.loading = false
    })
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          if (this.loading) {
            LoadingProgress()
              .layoutWeight(1)
              .width(80)
          } else {
            Column() {
              Column() {
                GridRow({ columns: 12, gutter: { x: 0, y: 0 } }) {
                  ForEach(this.partnerList, (item: ArticleModel, index) => {
                    GridCol({
                      span: {
                        xs: 4, // 超小屏幕(手机)占12列(即一行一列)
                        sm: 4, // 小屏幕
                        md: 2, // 中屏幕(折叠屏)占6列(即一行两列)
                        lg: 2, // 大屏幕
                        xl: 1    // 超大屏幕
                      }
                    }) {
                      Column() {
                        Image(MyConfig.URL + item.coverImageRealPath).width('80%')
                      }.height(52).justifyContent(FlexAlign.Center).margin({
                        bottom: 10
                      })
                    }
                  }, (item: ArticleModel) => JSON.stringify(item))
                }
              }
              .padding({
                left: 10,
                right: 10,
                top: 16,
                bottom: 16
              })
              .backgroundColor(Color.White)
              .borderRadius(14)
            }
            .padding({
              left: 16,
              right: 16,
              top: 12,
              bottom: 12
            })
            .margin({
              bottom: 24
            })

          }
        }
        .alignItems(HorizontalAlign.Start)
        .constraintSize({
          minHeight: '100%'
        })
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .title('合作伙伴')
    .padding({ top: px2vp(this.topRectHeight) })
    .backgroundColor('#F1F3F5')
  }
}