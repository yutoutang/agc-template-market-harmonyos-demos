import { UserInfoDetail, MyConfig, BreakpointType } from 'commons';
import { getReserveList, getSubSeminarList } from '../service/AgendaService'
import { getMyAgendaFilterDictList } from '../service/DictService'
import { AgendaList } from '../view/AgendaList';
import { ActivityList } from '../view/ActivityList';
import { Constants } from 'commons'
import {
  agendaDate,
  addressList,
  AgendaListItemModel,
  InitAgendaList,
  ObjectItem,
  AgendaSearchResultParam,
  SwiperItemsObject,
  addressShowList,
  hostItem
} from '../viewModel/AgendaModel';
import { DictListItem, FilterDIctList } from '../viewModel/DistListModel';
import { FilterItem } from '../view/FilterItem';
import dayjs from 'dayjs';


@Builder
export function AgendaBuilder() {
  Agenda()
}

@Component
export struct Agenda {
  @Consume('pageStack') pageStack: NavPathStack
  @StorageProp('token') @Watch('hasToken') token: string = '';
  @StorageProp('deviceId') deviceId: string = '';
  @Consume('agendaParams') agendaParams: number;
  @StorageLink('userInfo') userInfo: UserInfoDetail = new UserInfoDetail()
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm'
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @State changeValue: string = ''
  @State submitValue: string = ''
  @State text: string = ''
  @State fontColor: string = '#99000000'
  @State selectedFontColor: string = '#153AD1'
  @State currentDateIndex: number = 0
  @State currentAdrIndex: number = 0
  @State agendaDate: string[] = agendaDate
  @State addressList: string[] = addressList
  @State addressShowList: string[] = addressShowList
  @State isRefreshing: boolean = false
  @State agendaMetadata: AgendaListItemModel[] = []
  @State agendaData: ObjectItem[] = [];
  @State isShowAgendaFilterDialog: boolean = false
  @State filterDictObject: FilterDIctList = new FilterDIctList([])
  @State filterCurrentAddressIndex: number = -1;
  @State isLoading: boolean = true;
  @State myCollAgendaList: string[] = [];
  @State swiperDataList: SwiperItemsObject[] = [];
  @State hostList: hostItem[] = [];

  @Builder
  filterTitle(title: string) {
    Column() {
      Text(title)
        .fontSize(16)
        .lineHeight(23)
        .fontColor('#111111')
        .fontWeight(700)
        .padding({
          top: 5,
          bottom: 12
        })
    }.justifyContent(FlexAlign.Start).alignItems(HorizontalAlign.Start).width('100%')
  }

  @Builder
  FlexItem(list: DictListItem[]) {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(list, (item: DictListItem) => {
        FilterItem({ item: item })
      }, (item: DictListItem) => JSON.stringify(item))
    }
  }

  @Builder
  AgendaFilterDialogBuilder() {
    Column() {
      Column() {
        Scroll() {
          Column() {
            this.filterTitle('我所在的区域')
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.filterDictObject.addressList, (item: DictListItem) => {
                FilterItem({
                  item: item, callback: (clickItem) => {
                    this.filterDictObject.addressList.forEach((item: DictListItem) => {
                      if (clickItem.paramId === item.paramId) {
                        item.isSelect = !item.isSelect
                      } else {
                        item.isSelect = false
                      }
                    })
                    this.filterCurrentAddressIndex = this.filterDictObject.addressList.findIndex(item => item.isSelect);
                  }
                })
              }, (item: DictListItem) => JSON.stringify(item))
            }

            this.filterTitle('会议类型')
            if (this.filterCurrentAddressIndex === -1) {
              this.FlexItem(this.filterDictObject.allMeetingTypeList)
            } else if (this.filterCurrentAddressIndex === 0) {
              this.FlexItem(this.filterDictObject.meetingTypeList)
            } else {
              this.FlexItem(this.filterDictObject.meetingTypeListXi)
            }
            this.filterTitle('技术领域')
            this.FlexItem(this.filterDictObject.technoSphereList)
          }
        }.scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
      }.height('90%').padding({
        bottom: 20
      })


      Row() {
        Column() {
          Text('重置').fontSize(16).lineHeight(23).fontColor('#0A59F7')
        }
        .backgroundColor('#F1F3F5')
        .borderRadius(20)
        .padding(new BreakpointType<Padding>({
          sm: {
            top: 8,
            bottom: 10,
            left: 59,
            right: 59
          },
          md: {
            top: 8,
            bottom: 10,
            left: 120,
            right: 120
          },
          lg: {
            top: 8,
            bottom: 10,
            left: 120,
            right: 120
          },
        }).getValue(this.currentBreakpoint))
        .onClick(() => {
          this.resetSelect()
        })

        Column() {
          Text('确认').fontSize(16).lineHeight(23).fontColor('#fff')
        }
        .backgroundColor('#153AD1')
        .borderRadius(20)
        .margin({ left: 20 })
        .padding(new BreakpointType<Padding>({
          sm: {
            top: 8,
            bottom: 10,
            left: 59,
            right: 59
          },
          md: {
            top: 8,
            bottom: 10,
            left: 120,
            right: 120
          },
          lg: {
            top: 8,
            bottom: 10,
            left: 120,
            right: 120
          },
        }).getValue(this.currentBreakpoint))
        .onClick(() => {
          this.goSearchResult()
        })
      }.justifyContent(FlexAlign.Center).width('100%')

    }
    .padding({
      left: 14,
      right: 14,
      bottom: 30
    }).expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  hasToken() {
    if (this.token) {
      try {
        this.onShown()
      } catch (error) {
        console.log('getMyCollAgendaList error:', error)
      }
    }
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
      this.myCollAgendaList = res.data
      return Promise.resolve()
    }).catch(() => {
      return Promise.resolve()
    })
  }

  private resetListSelectState(list: DictListItem[]) {
    list.forEach((item: DictListItem) => {
      item.isSelect = false;
    });
  }

  //重置
  resetSelect() {
    // 地点
    this.resetListSelectState(this.filterDictObject.addressList);
    // 全部
    this.resetListSelectState(this.filterDictObject.allMeetingTypeList);
    // 会议类型
    this.resetListSelectState(this.filterDictObject.meetingTypeList);
    // 小山村
    this.resetListSelectState(this.filterDictObject.meetingTypeListXi);
    // 技术支持
    this.resetListSelectState(this.filterDictObject.technoSphereList);

    this.filterCurrentAddressIndex = -1;
  }

  private goSearchResultSelect(list: DictListItem[]) {
    let arr: string[] = []
    list.forEach((item) => {
      if (item.isSelect) {
        arr.push(item.name)
      }
    })
    return arr
  }

  goSearchResult() {
    let address: string[] = [];
    let type: string[] = [];
    let technoSphere: string[] = [];
    // 地点

    address = this.goSearchResultSelect(this.filterDictObject.addressList)

    if (address.length === 0) {
      type = this.goSearchResultSelect(this.filterDictObject.allMeetingTypeList)
    } else {
      if (address.join(',') === '大广场') {
        // 会议类型
        type = this.goSearchResultSelect(this.filterDictObject.meetingTypeList)
      } else {
        // 会议类型
        type = this.goSearchResultSelect(this.filterDictObject.meetingTypeListXi)
      }
    }

    technoSphere = this.goSearchResultSelect(this.filterDictObject.technoSphereList)
    this.isShowAgendaFilterDialog = false;
    this.pageStack.pushPath({
      name: 'AgendaSearchResult',
      param: new AgendaSearchResultParam(1, address.join(','), type.join(','), technoSphere.join(',')),
      onPop: (popInfo: PopInfo) => {
        if (popInfo.result === 'result') {
          this.isShowAgendaFilterDialog = true;
        }
      }
    })

  }

  aboutToAppear() {
    getContext().eventHub.on('onShown', (index: number) => {
      if (index === Constants.PAGE_INDEX_AGENDA) {
        if (this.agendaMetadata.length === 0) {
          this.loadData()
        } else {
          this.onShown()
        }
        this.getDictList()
      }
    });
    getContext().eventHub.on('switchTab', (index: number) => {
      if (index === Constants.PAGE_INDEX_AGENDA) {
        this.getDictList()
        if (this.agendaMetadata.length === 0) {
          this.loadData()
        } else {
          this.onShown()
        }
      }
    });
  }

  async onShown() {
    await this.getMyCollAgendaList()
    this.setCollect()
  }

  aboutToDisappear(): void {
    getContext().eventHub.off('onShown');
    getContext().eventHub.off('switchTab');
  }

  async changeTab(address?: string) {
    if (!address) {
      this.currentAdrIndex = 0;
    }
    this.organizationalData()
  }

  loadData() {
    if (this.swiperDataList.length === 0) {
      this.setCurrentDate()
    }
    Promise.all([
      this.getAgedList(),
      this.getMyCollAgendaList(),
    ]).then(() => {
      this.agendaMetadata.forEach((item) => {
        item.isCollect = this.myCollAgendaList.indexOf(item.mThirdSeminarId) !== -1;
      })

      this.organizationalData()
    })
  }

  getAgedList() {
    return getSubSeminarList().then(async (res) => {
      this.agendaMetadata = res.data.map((item: AgendaListItemModel) => {
        return new AgendaListItemModel(item)
      })
    })
  }

  organizationalData() {
    let swiperDataList: SwiperItemsObject[] = []
    this.agendaDate.forEach((item, index) => {
      swiperDataList.push(
        new SwiperItemsObject(
          index,
          new InitAgendaList(this.agendaMetadata, '议程', item,
            this.addressList[this.currentAdrIndex]).items,
          new InitAgendaList(this.agendaMetadata, '活动', item,
            this.addressList[this.currentAdrIndex]).items)
      )
    })

    this.swiperDataList = swiperDataList.map((item: SwiperItemsObject, index: number) => {
      return new SwiperItemsObject(
        index,
        item.agendaList,
        item.activityList)
    })
    this.isLoading = false
  }

  // 设置收藏状态
  async setCollect() {
    this.swiperDataList.forEach((swiperItem: SwiperItemsObject, index) => {
      swiperItem.agendaList.forEach((item, index2) => {
        item.subItems.forEach((subItem, m) => {
          subItem.isCollect = this.myCollAgendaList.indexOf(subItem.mThirdSeminarId) !== -1;
        })
      });
    })
  }

  setCurrentDate() {
    // 当前时间小于等于2025年9月26日
    if (dayjs().isBefore(dayjs('2025-09-27')) || dayjs().isAfter(dayjs('2025-09-29'))) {
      this.currentDateIndex = 0
    } else if (dayjs().isSame(dayjs('2025-09-27'), 'day')) {
      this.currentDateIndex = 1
    } else if (dayjs().isSame(dayjs('2025-09-28'), 'day')) {
      this.currentDateIndex = 2
    }
  }

  getDictList() {
    if (this.filterDictObject.addressList.length === 0) {
      getMyAgendaFilterDictList().then((res) => {
        const arr = res.data;
        this.filterDictObject = new FilterDIctList(arr)
      })
    }
  }

  async collectBack() {
    if (this.token) {
      await this.getMyCollAgendaList()
    }
    // 遍历 items 并设置收藏状态
    this.agendaMetadata.forEach((item: AgendaListItemModel) => {
      const index = this.myCollAgendaList.indexOf(item.mThirdSeminarId) ;
      if (index !== -1) {
        item.isCollect = true;
        item.favoriteId = this.myCollAgendaList[index];
      } else {
        item.isCollect = false;
        item.favoriteId = '';
      }
      this.agendaMetadata.push(new AgendaListItemModel(item) as AgendaListItemModel)
    });
  }

  build() {
    Column() {
      /*标题*/
      Column() {
        Text('议程')
          .width('100%')
          .fontSize(24)
          .fontColor('#111111')
          .fontWeight(700)
      }.height(56).justifyContent(FlexAlign.Center).padding({ left: 20 })

      Row() {
        Row() {
          Image(`${MyConfig.URL}agenda2%2Fagenda_search_icon.png?token=e0d7eb27-6641-42c4-8caa-32d4de2fb0cd`).width(16).margin({ right: 6 })
          Text('搜索议程、活动、演讲嘉宾').fontSize(16).lineHeight(23).fontColor('#66000000')
        }
        .backgroundColor('#0d000000')
        .borderRadius(20)
        .layoutWeight(1)
        .padding({
          left: 12,
          right: 54,
          top: 7,
          bottom: 10
        })
        .margin({
          right: 8
        })
        .onClick(() => {
          this.pageStack.pushPath({
            name: 'AgendaSearchAndFilter',
          })
        })

        Column() {
          Image(`${MyConfig.URL}agenda2%2Fagenda_filter_icon.png?token=10e3e50e-c3f3-4b4f-bf8a-a9d8ebe1b239`).width(16)
        }
        .backgroundColor('#0d000000')
        .borderRadius('50%')
        .padding(12)
        .onClick(() => {
          this.isShowAgendaFilterDialog = true
        })
        .bindSheet($$this.isShowAgendaFilterDialog, this.AgendaFilterDialogBuilder(), {
          height: '90%',
          dragBar: false,
          showClose: true,
          preferType: SheetType.BOTTOM,
          title: { title: '筛选' },
          backgroundColor: '#fff',
          onDisappear: () => {
            this.isShowAgendaFilterDialog = false;
          }
        })

      }.width('100%')
      .padding({ left: 16, right: 16 })
      .margin({
        bottom: 12
      })

      // 日期
      Row() {
        ForEach(this.agendaDate, (item: string, index: number) => {
          Text(item)
            .fontColor(this.currentDateIndex === index ? this.selectedFontColor : this.fontColor)
            .fontSize(16)
            .lineHeight(23)
            .fontWeight(this.currentDateIndex === index ? 700 : 400)
            .border({
              width: {
                top: 0,
                right: 0,
                left: 0,
                bottom: this.currentDateIndex === index ? 2 : 0
              },
              color: this.selectedFontColor
            })
            .padding({
              left: 16,
              right: 16,
              bottom: 22
            })
            .onClick(() => {
              this.currentDateIndex = index
              this.changeTab()
            })
        }, (item: string) => JSON.stringify(item))

      }
      .width('100%')
      .height(40)
      .justifyContent(FlexAlign.SpaceAround)
      .border({
        width: {
          bottom: 1
        },
        color: '#D5D5D5'
      })

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(70)
        }
        .width('100%')
        .height('calc(100% - 172vp)')
        .justifyContent(FlexAlign.Center)
      }
      if (this.swiperDataList.length > 0) {
        Swiper() {
          ForEach(this.swiperDataList, (item: SwiperItemsObject, index: number) => {
            Scroll() {
              Column() {
                this.swiperItem(this.swiperDataList[index])
              }
              .padding({ top: 14 })
              .constraintSize({
                minHeight: '100%'
              })
            }
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
          }, (item: SwiperItemsObject) => JSON.stringify(item))
        }
        .layoutWeight(1)
        .indicator(false).index($$this.currentDateIndex)
      }
    }
    .backgroundColor('#F1F3F5')
    .width('100%')
    .height('100%')
    .padding({ top: px2vp(this.topRectHeight) })
    .expandSafeArea([SafeAreaType.KEYBOARD], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  builderSubTitle(title: string) {
    Column() {
      Text(title)
        .fontSize(18)
        .fontColor(`#111111`)
        .lineHeight(25).fontWeight(700)
    }.width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({
      bottom: 12,
      left: 16
    })
  }

  @Builder
  swiperItem(item: SwiperItemsObject) {
    // 地点
    if (item.dateIndex !== 0) {
      Row({ space: 8 }) {
        ForEach(this.addressShowList, (item: string, index: number) => {
          Stack({ alignContent: Alignment.Bottom }) {
            Stack(){
              Image(this.currentAdrIndex === index ?
                `${MyConfig.URL}agenda3%2Fsearch_address_xi.png?token=5832c256-9276-41ff-9b04-572d868e710f` :
                `${MyConfig.URL}agenda3%2Fsearch_address_san.png?token=daa654a4-f91d-45bd-9667-a4d26ade8512`)
                .width('50%')
                .borderRadius(16)
                .height(35)

                Text(item)
                  .fontColor(this.currentAdrIndex === index ? Color.White : '#e6000000')
                  .fontSize(14)
                  .fontWeight(this.currentAdrIndex === index ? 700 : 400)
                  .lineHeight(20)
            }

            if (this.currentAdrIndex === index) {
              Column() {
              }
              .width(6)
              .height(6)
              .borderRadius('50%')
              .backgroundColor('#FFBD00')
              .margin({
                bottom: -3
              })
            }
          }
          .onClick(() => {
            this.currentAdrIndex = index
            this.changeTab('address')
          })
        }, (item: string) => JSON.stringify(item))
      }
      .width('100%')
      .height(35)
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 24 })
      .padding({ right: 16, left: 16 })
    }
    Column() {
      if (item.dateIndex !== 0 && item.agendaList.length > 0) {
        this.builderSubTitle('议程')
      }
      if (item.agendaList.length > 0) {
        Column({ space: 20 }) {
          ForEach(item.agendaList, (subItem: ObjectItem, idx: number) => {
            AgendaList({
              item: item.agendaList[idx]
            }
            )
          }, (item: ObjectItem) => JSON.stringify(item))
        }
        .width('100%')
        .margin({
          bottom: 36
        })
      }
      if (item.activityList.length > 0 && item.dateIndex !== 0) {
        this.builderSubTitle('活动')
        Column() {
          GridRow({
            gutter: { x: 8, y: 8 }
          }) {
            ForEach(item.activityList, (subItem: ObjectItem, idx2: number) => {
              GridCol({
                span: {
                  sm: 12,
                  md: 6,
                  lg: 6,
                },
              }) {
                ActivityList({ item: item.activityList[idx2] })
              }
            }, (item: ObjectItem) => JSON.stringify(item))
          }
        }.margin({
          left: 16,
          right: 16,
        })
      }
      // 敬请期待
      if (item.agendaList.length === 0 && item.dateIndex === 0) {
        Column() {
          Image(`${MyConfig.URL}agenda3%2Fno_data_plan.png?token=1bc592b5-0525-4d67-844d-b1d2157c938e`)
            .width(86)
            .margin({
              bottom: 5
            })
          Text('敬请期待').fontSize(12).lineHeight(13).fontColor('#66000000')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }.padding({
      bottom: 80
    })
  }
}
