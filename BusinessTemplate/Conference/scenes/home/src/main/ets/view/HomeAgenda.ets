import dayJs from 'dayjs';
import {
  AgendaListItem,
  AgendaListItemModel,
  getReserveList,
  getSubSeminarList
} from 'agenda';
import { BreakpointType, Constants, MyConfig, splitArray } from 'commons';

@Component
export default struct HomeAgenda {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm'
  @StorageProp('token') @Watch('hasToken') token: string = '';
  @State isShowCardViewSheet: boolean = false
  @State isActiveTab: number = 0
  @State agendaList: AgendaListItemModel[][] = []
  @State agendaAllList: AgendaListItemModel[] = []
  @State myCollAgendaList: string[] = []
  @State isEmpty: boolean = false
  @State isAllEmpty: boolean = false
  @State isLoading: boolean = true

  async hasToken() {
    if (this.token) {
      try {
        this.loadData()
      } catch (e) {
      }
    }
  }

  aboutToAppear() {
    this.getUIContext().getHostContext()!.eventHub.on('onShown', (index: number) => {
      if (index === Constants.PAGE_INDEX_HOME) {
        this.loadData()
      }
    });
    this.getUIContext().getHostContext()!.eventHub.on('switchTab', (index: number) => {
      if (index === Constants.PAGE_INDEX_HOME) {
        this.loadData()
      }
    });
  }

  loadData() {
    Promise.all([
      this.getList(),
      this.getMyCollAgendaList()
    ]).then(() => {
      this.agendaAllList.forEach((item) => {
        const index =  this.myCollAgendaList.indexOf(item.mThirdSeminarId)
        if (index !== -1) {
          item.isCollect = true
          item.favoriteId = this.myCollAgendaList[index]
        }

      })
      this.agendaList = this.organizationalData(this.myCollAgendaList, this.agendaAllList)
      this.isLoading = false
    })
  }

  // 获取我的收藏列表
  getMyCollAgendaList() {
    if (!this.token) {
      this.myCollAgendaList = []
      return Promise.resolve()
    }
    return getReserveList({
      token: this.token
    }).then((res) => {
      this.myCollAgendaList = res.data;
      return Promise.resolve()
    }).catch(() => {
      return Promise.resolve()
    })
  }

  // 议程列表
  async getList() {
    return getSubSeminarList().then((res) => {
      let list = res.data
      list = list.filter((item) => item.mAgendaType === '议程')
      this.agendaAllList = list
    })
  }

  // 获取议程状态
  getAgendaStatus(startTime: string, endTime: string): string {
    const now = dayJs(); // 当前时间
    const start = dayJs(Number(startTime) * 1000);
    const end = dayJs(Number(endTime) * 1000);
    if (now.isBefore(start)) {
      return '未开始'; // 当前时间早于开始时间
    } else if (now.isAfter(end)) {
      return '已结束'; // 当前时间晚于结束时间
    } else if (now.isAfter(start) && now.isBefore(end)) {
      return '进行中'; // 当前时间在开始和结束之间
    } else {
      return '默认'
    }
  }

  //组织数据
  organizationalData(myCollAgendaList: string[], agendaList: AgendaListItemModel[]) {

    // 直接过滤并设置 isCollect 和 favoriteId
    let arrList = agendaList.map((item: AgendaListItemModel) => {

      item.isTimeStatus = this.getAgendaStatus(item.startTime, item.endTime)

      return item;
    })
    let currentList: AgendaListItemModel[] = []
    let noStartList: AgendaListItemModel[] = []
    let playingList: AgendaListItemModel[] = []
    let meetingEndList: AgendaListItemModel[] = []
    noStartList = arrList
      .filter((item) => item.isTimeStatus === '未开始')
      .slice(0, 6);
    playingList = arrList
      .filter((item) => item.isTimeStatus === '进行中')
      .slice(0, 6);
    if (noStartList.length === 0 && playingList.length === 0) {
      this.isAllEmpty = true
      meetingEndList = arrList.filter((item) => item.mAgendaType === '议程' && item.isShowHomeAgenda &&
        item.isShowHomeAgenda.join(',') === 'Y')

      meetingEndList.sort((a, b) => {
        return Number(a.isShowHomeAgendaSort) - Number(b.isShowHomeAgendaSort);
      });
      meetingEndList.forEach((item) => {
        currentList.push(new AgendaListItemModel(item))
      })
    } else {
      this.isAllEmpty = false
      if (this.isActiveTab === 0) {
        noStartList.forEach((item) => {
          currentList.push(new AgendaListItemModel(item))
        })
      } else {
        playingList.forEach((item) => {
          currentList.push(new AgendaListItemModel(item))
        })
      }
    }
    const chunkedList = splitArray(currentList, 2); // 按大小为 2 的块分割数组
    this.isEmpty = chunkedList.length === 0
    return chunkedList
  }

  // 设置收藏状态
  async setCollect() {
    this.agendaList.forEach((item) => {
      item.forEach((item) => {
        const index = this.myCollAgendaList.indexOf(item.mThirdSeminarId)
        item.isCollect = index !== -1
        item.favoriteId = index !== -1?this.myCollAgendaList[index]:'';
      })
    })
  }

  // 切换标签
  async changeTap(isActive: number) {
    this.isActiveTab = isActive
    this.agendaList = this.organizationalData(this.myCollAgendaList, this.agendaAllList)
    await this.getMyCollAgendaList()
    this.setCollect()
    this.isLoading = false
  }

  async updateList() {
    if (this.token) {
      await this.getMyCollAgendaList()
    }
    this.agendaList = this.organizationalData(this.myCollAgendaList, this.agendaAllList)
  }

  @Builder
  tabItem(name: string, isActive: number) {
    Text(name)
      .fontSize(14)
      .padding({
        top: 12,
        bottom: 12,
      })
      .textAlign(TextAlign.Center)
      .backgroundColor(this.isActiveTab === isActive ? '#fff' : '')
      .borderRadius(this.isActiveTab === isActive ? 20 : 0)
      .width('50%')
      .onClick(() => {
        this.changeTap(isActive)
      })
  }

  build() {
    Row() {
      Column() {
        // tab
        if (!this.isAllEmpty) {
          Column() {
            Row() {
              this.tabItem('即将开始', 0)
              this.tabItem('正在进行', 1)
            }
            .backgroundColor('#0d000000')
            .borderRadius(20)
            .width('100%')
            .padding(2)
          }
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
        }

        Column() {
          Column() {
            Stack() {
              Column() {
                Swiper() {
                  ForEach(this.agendaList, (subItem: AgendaListItemModel[], subIndex: number) => {
                    Column() {
                      Column() {
                        ForEach(this.agendaList[subIndex], (item: AgendaListItemModel, index: number) => {
                          AgendaListItem({
                            item: this.agendaList[subIndex][index], isRecommend: true
                          })
                          if (subItem.length === 2 && index === 0) {
                            Column() {
                              Column().width('100%').height(1).margin({
                                left: 12,
                                right: 12
                              }).border({
                                width: {
                                  bottom: 1
                                },
                                color: '#1a000000',
                                style: BorderStyle.Dashed

                              })
                            }.width('100%').padding({
                              left: 12,
                              right: 12
                            })
                          }
                        }, (item: AgendaListItemModel) => item.mThirdSeminarId)
                      }
                      .padding({
                        top: 8,
                        bottom: 8,
                        left: 4,
                        right: 4
                      })
                      .width('calc(100% - 24vp)')
                      .height(270)
                      .alignItems(HorizontalAlign.Start)
                      .justifyContent(FlexAlign.Start)
                      .border({
                        width: 2,
                        color: 'rgba(255, 255, 255, 1)',
                      })
                      .shadow({
                        radius: vp2px(15),
                        color: '#12000000',
                        offsetX: 0,
                        offsetY: vp2px(4)
                      })
                      .backgroundColor('rgba(255, 255, 255, 0.8)')
                      .borderRadius(20)
                      .margin(12)
                    }.margin({
                      bottom: 48
                    }).height(270)

                  }, (item: AgendaListItemModel[]) => item[0].mThirdSeminarId)
                }
                .width('100%')
                .loop(true)
                .displayCount(1)
                .indicator(this.agendaList.length > 1 ? new DotIndicator()
                  .bottom(0)
                  .itemWidth(6)
                  .itemHeight(6)
                  .selectedItemWidth(12)
                  .selectedItemHeight(6)
                  .color($r('sys.color.comp_background_secondary'))
                  .selectedColor($r('sys.color.comp_background_emphasize')) : false)
              }

              if (this.isEmpty) {
                Column() {
                  Image(`${MyConfig.URL}agenda3%2Fno_data_home_agenda.png?token=a27def5d-07d3-4c63-94cc-da5d86579702`).width(86).margin({
                    bottom: 10
                  })

                  Text(`暂无${this.isActiveTab === 0 ? '即将开始' : '进行中'}的议程`)
                    .fontSize(12)
                    .lineHeight(18)
                    .fontColor('#66000000')
                  Text('点击“更多”查看全部议程').fontSize(12).lineHeight(18).fontColor('#66000000')
                }
                .borderRadius(20)
                .width('calc(100% - 24vp)')
                .height(270)
                .backgroundColor(Color.White)
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Center)
                .shadow({
                  radius: vp2px(15),
                  color: '#12000000',
                  offsetX: 0,
                  offsetY: vp2px(4)
                })
                .margin(12)
              }

              if (this.isLoading) {
                Column() {
                  LoadingProgress().width(70)
                }
                .width('calc(100% - 24vp)')
                .height(270)
                .backgroundColor(Color.White)
                .alignItems(HorizontalAlign.Center)
                .justifyContent(FlexAlign.Center)
                .borderRadius(20)
                .margin(12)
              }
            }
            .width('100%')
            .height(294)
          }
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }.padding({
        top: 14,
        bottom: 10
      })
      .width('100%')
    }.width('100%')
    .justifyContent(FlexAlign.Center)

  }
}