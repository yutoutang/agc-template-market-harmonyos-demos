import { MyConfig, UserInfoDetail, PreferencesUtil } from 'commons';
import { SearchHotModel, SearchParams } from '../viewModel/SearchHistoryModel';
import { getHotSearch, IArticle } from '../service/AgendaService';
import { promptAction } from '@kit.ArkUI';


@Builder
export function AgendaSearchAndFilterBuilder() {
  AgendaSearchAndFilter()
}

@Component
export struct AgendaSearchAndFilter {
  @Consume('pageStack') pageStack: NavPathStack
  @StorageProp('token') token: string = '';
  @StorageProp('deviceId') deviceId: string = '';
  @StorageLink('userInfo') userInfo: UserInfoDetail = new UserInfoDetail()
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm'
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @State changeValue: string = ''
  @State isFocus: boolean = true
  @State isShowCollapse: boolean = false
  @State isOpen: boolean = false
  @State historyHeight: number = 0
  @State historyList: string[] = []
  @State hotList: SearchHotModel[] = []

  aboutToAppear() {
    this.isFocus = true
    let util = PreferencesUtil.getInstance();
    let context = getContext(this) as Context
    let preferences = util.getPreferences(context);
    this.historyList = preferences.getSync('historySearch', []) as string[]
    this.getHotSearch()
  }

  // 获取热门搜索
  getHotSearch() {
    getHotSearch().then(res => {
      let list = res.data;
      this.hotList = list.map<SearchHotModel>((item: IArticle) => {
        return {
          text: item.title,
          order: item.order,
          isHot: item.isRecommend === 1
        }
      })
    })
  }

  aboutToDisappear() {
  }

  @Builder
  HistoryItem(title: string) {
    Column() {
      Text(title)
        .fontColor('#e6000000')
        .fontSize(14)
        .maxLines(1)
        .textOverflow({
          overflow: TextOverflow.Ellipsis
        })
    }
    .backgroundColor('#0d000000')
    .borderRadius(20)
    .height(28)
    .justifyContent(FlexAlign.Center)
    .padding({ left: 14, right: 14 })
    .margin({
      right: 8,
      bottom: 8
    })
    .onClick(() => {
      this.pushHistory(title)
      this.pageStack.pushPath({
        name: 'AgendaSearchResult',
        param: new SearchParams(title)
      })
    })
  }

  @Builder
  HotItem(title: string, isHot: boolean) {
    Row() {
      Text(title)
        .fontColor('#e6000000')
        .fontSize(14)
        .maxLines(1)
        .textOverflow({
          overflow: TextOverflow.Ellipsis
        })
      if (isHot) {
        Image(`${MyConfig.URL}agenda2%2Fhot.png?token=85ff2b01-4ad4-41ca-8fd9-ddee6a65620e`).width(14).margin({ left: 2 })
      }
    }
    .backgroundColor('#F8F9FA')
    .borderRadius(20)
    .height(28)
    .padding({ left: 14, right: 14 })
    .margin({
      right: 8,
      bottom: 8
    })
    .onClick(() => {
      this.pushHistory(title)
      this.pageStack.pushPath({
        name: 'AgendaSearchResult',
        param: new SearchParams(title)
      })
    })
  }

  pushHistory(value: string) {
    let util = PreferencesUtil.getInstance();
    let context = getContext(this) as Context
    let preferences = util.getPreferences(context);
    if (!value) {
      // 删除
      util.preferencesPut(preferences, 'historySearch', [])
      return
    }
    if (!this.historyList.includes(value.trim())) {
      this.historyList.unshift(value)
      util.preferencesPut(preferences, 'historySearch', this.historyList)
    }
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Search({ value: this.changeValue, placeholder: '搜索议程、活动、演讲嘉宾', })
            .width('100%')
            .searchButton('搜索', {
              fontSize: '16fp',
              fontColor: '#0A59F7'
            })
            .backgroundColor('#0d000000')
            .placeholderColor($r('sys.color.font_secondary'))
            .placeholderFont({ size: $r('sys.float.Body_L') })
            .textFont({ size: $r('sys.float.Body_L') })
            .defaultFocus(this.isFocus)
            .onSubmit((value: string) => {
              // 存储搜索历史
              if (value.trim()) {
                this.pushHistory(value)
                this.pageStack.pushPath({
                  name: 'AgendaSearchResult',
                  param: new SearchParams(value)
                })
              } else {
                promptAction.showToast({
                  alignment: Alignment.Center,
                  message: '输入内容不能为空',
                  duration: 500
                });
              }
            })
            .onChange((value: string) => {
              this.changeValue = value
            })
        }
        .width('100%')
        .padding({
          left: 16,
          right: 16
        })

        Scroll() {
          Column() {
            // 搜索历史
            if (this.historyList.length > 0) {
              Column() {
                Row() {
                  Text('搜索历史')
                    .fontSize(16)
                    .lineHeight(24)
                    .fontColor('#111111')
                    .fontWeight(700)
                  Image(`${MyConfig.URL}agenda3%2Fdelete_icon.png?token=673bd5e2-ac49-4c46-a630-cf3606d423a1`).width(20).onClick(() => {
                    this.historyList = []
                    this.pushHistory('')
                    this.isShowCollapse = false
                    this.isOpen = false
                  })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .margin({
                  bottom: 12
                })

                Row() {
                  Flex({
                    wrap: FlexWrap.Wrap,
                  }) {
                    ForEach(this.historyList, (title: string) => {
                      this.HistoryItem(title)
                    }, (item: string) => item)
                  }
                  .onAreaChange((oldValue: Area, newValue: Area) => {
                    console.log(newValue.height + '')
                      this.historyHeight = newValue.height as number
                      if (this.historyHeight > 40) {
                        this.isShowCollapse = true
                      }
                  })
                  .layoutWeight(1)
                  .margin({
                    right: 10
                  })
                  .height(this.isShowCollapse ? (this.isOpen ? '' : 36) : '')
                  .clip(this.isShowCollapse)

                  if (this.isShowCollapse) {

                    Column() {
                      Image(`${MyConfig.URL}/project/hdc/2025/static/images/agenda_more.png`)
                        .width(14)
                        .rotate({ angle: this.isOpen ? 180 : 0 })
                        .animation({
                          duration: 300,
                        })
                    }
                    .alignItems(HorizontalAlign.Center)
                    .justifyContent(FlexAlign.Center)
                    .backgroundColor('#0d000000')
                    .width(28)
                    .height(28)
                    .borderRadius('50%')
                    .onClick(() => {
                      // 旋转90度
                      this.isOpen = !this.isOpen
                    })
                  }

                }
                .width('100%')
                .alignItems(VerticalAlign.Top)

              }.margin({ top: 28 })
            }

            // 热门搜索
            Column() {
              Row() {
                Text('热门搜索')
                  .fontSize(16)
                  .lineHeight(24)
                  .fontColor('#111111')
                  .fontWeight(700)
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .margin({
                bottom: 12
              })

              Flex({
                wrap: FlexWrap.Wrap,
              }) {
                ForEach(this.hotList, (item: SearchHotModel) => {
                  this.HotItem(item.text, item.isHot)
                }, (item: SearchHotModel) => item.text)
              }
              .width('100%')
            }.margin({ top: 28 })

          }
          .padding({ left: 16, right: 16 })
          .constraintSize({
            minHeight: `calc(100% - 40vp)`,
          })
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
    }
    .onTouch(() => {
      this.isFocus = false
      this.getUIContext().getFocusController().clearFocus();
    })
    .padding({ top: px2vp(this.topRectHeight) })
    .title()
    .backgroundColor('#F1F3F5')
  }
}
