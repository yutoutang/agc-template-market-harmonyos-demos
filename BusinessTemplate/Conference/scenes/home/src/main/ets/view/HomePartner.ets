import { ArticleModel, BreakpointType, getAdList, getPartnerList, MyConfig, splitArray } from 'commons'

@Component
export default struct HomePartner {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm'
  @State loading: boolean = true;
  @State partnerList: ArticleModel[][] = [];
  @State advertiseList: ArticleModel[] = [];

  loadPartnerList() {
    return getPartnerList().then((res) => {
      let arr: ArticleModel[] = []
      let list = res.data
      list.sort((a, b) => {
        return a.order - b.order
      })
      list.forEach((item: ArticleModel) => {
        arr.push(new ArticleModel(item))
      })
      // 将 arr 分割成 9个 一个数组 的二维数组
      this.partnerList = splitArray(arr, 9)
    })
  }

  loadAdList() {
    return getAdList().then((res) => {
      let list = res.data;
      list.sort((a, b) => {
        return a.order - b.order
      })
      list.forEach((item: ArticleModel) => {
        this.advertiseList.push(new ArticleModel(item))
      })
    })
  }

  async loadData() {
    await this.loadPartnerList()
    await this.loadAdList()
  }

  aboutToAppear(): void {
    this.loadData()
  }

  build() {
    Row() {
      Column() {
        // 合作伙伴
        Stack({ alignContent: Alignment.Bottom }) {
          Swiper() {
            ForEach(this.partnerList, (item: ArticleModel[], index?: number) => {
              Column() {
                Column() {
                  Column() {
                    GridRow({ columns: 12, gutter: { x: 0, y: 0 } }) {
                      ForEach(item, (itemData: ArticleModel, index?: number) => {
                        GridCol({
                          span: {
                            xs: 4,
                            sm: 4,
                          }
                        }) {
                          Column() {
                            Image(MyConfig.URL + itemData.coverImageRealPath!).width('80%')
                          }.height(50).justifyContent(FlexAlign.Center)
                        }
                      }, (itemData: ArticleModel) => JSON.stringify(itemData))
                    }
                  }.borderRadius(20)
                  .shadow({
                    radius: vp2px(15),
                    color: '#0a000000',
                    offsetX: 0,
                    offsetY: vp2px(4)
                  })
                  .padding({
                    top: 28,
                    bottom: 28,
                    left: 23,
                    right: 23
                  })
                  .height(210)
                }
                .borderRadius(20)
                .margin({
                  top: 14,
                  bottom: 14
                })
              }
              .padding({
                bottom: 14
              })
              .height(262)
            }, (item: ArticleModel[]) => JSON.stringify(item))
          }
          .width('100%')
          .indicator(this.partnerList.length > 1 ? new DotIndicator()
            .bottom(0)
            .itemWidth(6)
            .itemHeight(6)
            .selectedItemWidth(12)
            .selectedItemHeight(6)
            .color($r('sys.color.comp_background_secondary'))
            .selectedColor($r('sys.color.comp_background_emphasize')) : false)
          .displayCount(1)
          .loop(true)
          .autoPlay(true)
          .cachedCount(10)
        }

        //  广告位
        Stack({ alignContent: Alignment.Bottom }) {
          Swiper() {
            ForEach(this.advertiseList, (item: ArticleModel, index?: number) => {
              Column() {
                Column() {
                  Image(MyConfig.URL + item.coverImageRealPath).width('100%').borderRadius(20)
                }.height(154).margin({
                  bottom: 14
                })
              }.padding({
                bottom: 14
              })
            }, (item: ArticleModel) => JSON.stringify(item))
          }
          .itemSpace(12)
          .nextMargin(15)
          .onChange((index: number) => {

          })
          .width('100%')
          .indicator(this.advertiseList.length > 1 ? new DotIndicator()
            .bottom(0)
            .itemWidth(6)
            .itemHeight(6)
            .selectedItemWidth(12)
            .selectedItemHeight(6)
            .color($r('sys.color.comp_background_secondary'))
            .selectedColor($r('sys.color.comp_background_emphasize')) : false)
          .displayCount(1)
          .loop(true)
          .autoPlay(true)
          .cachedCount(10)
        }
        .margin({ top: 8 })

      }
      .width('100%')
      .padding(new BreakpointType<Padding>({
        sm: {
          left: $r('sys.float.padding_level8'),
          right: $r('sys.float.padding_level8'),
        },
        md: {
          left: $r('sys.float.padding_level12'),
          right: $r('sys.float.padding_level12'),
        },
        lg: {
          left: $r('sys.float.padding_level16'),
          right: $r('sys.float.padding_level16'),
        },
      }).getValue(this.currentBreakpoint));
    }.width('100%')
    .justifyContent(FlexAlign.Center)

  }
}