import { MyConfig, UserInfoDetail } from 'commons';
import { getReserveList, getSubSeminarList } from '../service/AgendaService';
import { AgendaListItemModel, } from '../viewModel/AgendaModel';
import { AgendaListItem } from '../view/AgendaListItem';
import { AgendaItemModel, GuestModel } from '../viewModel/AgendaDetailModel';
import { DictListItem, FilterDIctList } from '../viewModel/DistListModel';
import { FilterItem } from '../view/FilterItem';
import { getMyAgendaFilterDictList } from '../service/DictService';
import dayjs from 'dayjs';

@Builder
export function AgendaSearchResultBuilder() {
  AgendaSearchResult()
}

@Component
export struct AgendaSearchResult {
  @Consume('pageStack') pageStack: NavPathStack
  @StorageProp('token') token: string = '';
  @StorageProp('deviceId') deviceId: string = '';
  @StorageLink('userInfo') userInfo: UserInfoDetail = new UserInfoDetail()
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm'
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @State filterDictObject: FilterDIctList = new FilterDIctList([])
  @State isShowAgendaFilterDialog: boolean = false
  @State changeValue: string = ''
  @State isFocus: boolean = false
  @State allAgendaList: AgendaListItemModel[] = []
  @State agendaList: AgendaListItemModel[] = []
  @State isLoading: boolean = true;
  @State isEmpty: boolean = false;
  @State isFilter: number = 0; //是议程首页筛选过来的
  @State address: string = ''; //地点
  @State type: string = ''; //会议类型
  @State technoSphere: string = ''; //技术支持
  @State technoSphereArray: string[] = []; //技术支持
  @State myCollAgendaList: string[] = [];
  @State filterCurrentAddressIndex: number = -1;

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
                    //  有item.isSelect 的话  this.filterCurrentAddressIndex  没有 this.filterCurrentAddressIndex 是负一
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
        }.backgroundColor('#F1F3F5').borderRadius(20).padding({
          top: 8,
          bottom: 10,
          left: 59,
          right: 59
        }).onClick(() => {
          this.resetSelect()
        })

        Column() {
          Text('确认').fontSize(16).lineHeight(23).fontColor('#fff')
        }
        .backgroundColor('#153AD1')
        .borderRadius(20)
        .margin({ left: 20 })
        .padding({
          top: 8,
          bottom: 8,
          left: 59,
          right: 59
        })
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

  aboutToAppear() {
    this.getDictList()
  }

  // 获取我的收藏列表
  getMyCollAgendaList() {
    if (!this.token) {
      return Promise.resolve([])
    }
    return getReserveList({
      token: this.token
    }).then((res) => {
      this.myCollAgendaList = res.data;
      return Promise.resolve(this.myCollAgendaList)
    }).catch(() => {
      return Promise.resolve([])
    })
  }

  getAllAgendaList() {
    return getSubSeminarList().then(async (res) => {
      let list = res.data
      this.allAgendaList = list
    })
  }

  async loadData() {

    Promise.all([
      this.getAllAgendaList(),
      this.getMyCollAgendaList()
    ]).then(async () => {
      this.allAgendaList.forEach((item: AgendaListItemModel) => {
        item._agendaList = item.agendaList[0] && item.agendaList[0].agendas || []
        const index = this.myCollAgendaList.indexOf(item.mThirdSeminarId);
        if (index !== -1) {
          item.isCollect = true;
          item.favoriteId = this.myCollAgendaList[index];
        } else {
          item.isCollect = false;
          item.favoriteId = '';
        }
      })
      // 搜索议程标题、地点和嘉宾
      try {

        this.allAgendaList = this.allAgendaList.filter((item: AgendaListItemModel) => {
          let condition: boolean = true
          let addressCondition: boolean = true
          let typeCondition: boolean = true
          let technoSphereCondition: boolean = true
          if (this.changeValue) {
            condition = item.name.toLowerCase().indexOf(this.changeValue.toLowerCase()) > -1 ||
              item.mMategoryI.indexOf(this.changeValue) > -1;
            if (item._agendaList && item._agendaList.length > 0) {
              item._agendaList.forEach((childAgenda: AgendaItemModel) => {
                // //日程名称、地点
                if (childAgenda.name.toLowerCase().indexOf(this.changeValue.toLowerCase()) > -1) {
                  condition = true;
                }
                if (childAgenda.guests && childAgenda.guests.length > 0) {
                  childAgenda.guests.forEach((guest: GuestModel) => {
                    //嘉宾名称
                    if (guest.name?.toLowerCase().indexOf(this.changeValue.toLowerCase()) > -1) {
                      condition = true;
                    }
                  });
                }
              });
            }
          }
          if (this.address) {
            addressCondition = item.mMategoryI && item.mMategoryI.join(',').indexOf(this.address) > -1
          }

          if (this.type) {
            typeCondition = item.mMeetingTypeCn && this.type.indexOf(item.mMeetingTypeCn.join(',')) > -1
          }
          if (this.technoSphere) {
            if (item.crowdArea && item.crowdArea.length > 0) {
              technoSphereCondition = this.technoSphere.split(',').some(val => item.crowdArea.indexOf(val) > -1);
            } else {
              technoSphereCondition = false
            }
          }

          if (this.isFilter) {
            return addressCondition && typeCondition && technoSphereCondition
          } else {
            return condition
          }
        })
        this.allAgendaList = this.allAgendaList.sort((a, b) => {
          return dayjs(a.startTime).valueOf() - dayjs(b.startTime).valueOf();
        })
        let arrList: AgendaListItemModel[] = []
        this.allAgendaList.forEach((item) => {
          arrList.push(new AgendaListItemModel(item) as AgendaListItemModel)
        })
        this.agendaList = arrList
      } catch (e) {
        console.log('e', JSON.stringify(e))
      }

      this.isLoading = false
      if (this.agendaList.length === 0) {
        this.isEmpty = true
      } else {
        this.isEmpty = false
      }

    })
  }

  getDictList() {
    if (this.filterDictObject.addressList.length === 0) {
      getMyAgendaFilterDictList().then((res) => {
        const arr = res.data;
        this.filterDictObject = new FilterDIctList(arr)

        if (this.isFilter) {
          this.filterDictObject.addressList.forEach((item) => {
            if (this.address.indexOf(item.name) > -1) {
              item.isSelect = true
            }
          })
          if (this.address) {
            if (this.address === '大广场') {
              this.filterCurrentAddressIndex = 0
            } else {
              this.filterCurrentAddressIndex = 1
            }
          } else {
            this.filterCurrentAddressIndex = -1
          }
          this.isSelect(this.filterDictObject.allMeetingTypeList, this.type)
          this.isSelect(this.filterDictObject.meetingTypeList, this.type)
          this.isSelect(this.filterDictObject.meetingTypeListXi, this.type)
          this.isSelect(this.filterDictObject.technoSphereList, this.technoSphere)
        }

      })
    }
  }

  isSelect(list: DictListItem[], type: string) {
    list.forEach((item) => {
      if (type.indexOf(item.name) > -1) {
        item.isSelect = true
      }
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

  goSearchResultSelect(list: DictListItem[]) {
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
    // 技术支持
    technoSphere = this.goSearchResultSelect(this.filterDictObject.technoSphereList)
    this.address = address.join(',')
    this.type = type.join(',')
    this.technoSphere = technoSphere.join(',')
    this.loadData()
    this.isShowAgendaFilterDialog = false;

  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          if (this.isFilter) {
            Row() {
              Row() {
                Image(`${MyConfig.URL}agenda2%2Fagenda_search_icon.png?token=e0d7eb27-6641-42c4-8caa-32d4de2fb0cd`)
                  .width(16)
                  .margin({ right: 6 })
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
                title: { title: '筛选' },
                backgroundColor: '#fff',
                onDisappear: () => {
                  this.isShowAgendaFilterDialog = false;
                }
              })

            }.width('100%')
          } else {
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
              .onChange((value: string) => {
                this.changeValue = value
              })
              .onSubmit((value: string) => {
                this.loadData()
              })
          }

          // .onWillDelete((info: DeleteValue) => {
          //   // 回退
          //   console.log('will delete')
          //   this.pageStack.pop()
          //   return true;
          // })
        }
        .width('100%')
        .padding({
          left: 16,
          right: 16
        })
        .margin({
          bottom: 16
        })

        Stack() {
          Scroll() {
            Column() {
              GridRow({ gutter: { x: 8, y: 8 } }) {
                ForEach(this.agendaList, (subItem: AgendaListItemModel, index: number) => {
                  GridCol({
                    span: {
                      sm: 12,
                      md: 6,
                      lg: 6,
                    }
                  }) {
                    AgendaListItem({
                      item: subItem, isRecommend: true
                    })
                  }
                }, (item: AgendaListItemModel) => JSON.stringify(item))
              }
            }
            .padding({ left: 16, right: 16, bottom: 32 })
            .constraintSize({
              minHeight: '100%'
            })
          }
          .edgeEffect(EdgeEffect.Spring)
          .scrollBar(BarState.Off)

          if (this.isEmpty) {
            Column() {
              Image(`${MyConfig.URL}agenda3%2Fno_data_home_agenda.png?token=a27def5d-07d3-4c63-94cc-da5d86579702`).width(150)
              Text('暂无相关议程').fontSize(14).fontColor('#999999')
            }
            .backgroundColor('#F1F3F5')
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }

          // loading
          if (this.isLoading) {
            Column() {
              LoadingProgress().width(70)
              Text('正在加载...').fontSize(14).fontColor('#999999').margin({
                top: 10
              })
            }
          }
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    }
    .onTouch(() => {
      this.isFocus = false
      this.getUIContext().getFocusController().clearFocus();
    })
    .onReady((ctx: NavDestinationContext) => {
      try {
        const myParams = ctx?.pathInfo?.param as Record<string, string>;
        if (myParams) {
          this.changeValue = myParams.title
          this.isFilter = Number(myParams.isFilter)
          this.address = myParams.address
          this.type = myParams.type
          this.technoSphere = myParams.technoSphere
          this.loadData()
        }
      } catch (e) {
        console.log('e', JSON.stringify(e))
      }
    })
    .onBackPressed(() => {
      this.pageStack.pop('result')
      return true
    })
    .onShown(() => {
      if (this.filterDictObject.addressList.length > 0) {
        this.loadData()
      }
    })
    .padding({ top: px2vp(this.topRectHeight) })
    // .title('', { barStyle: BarStyle.SAFE_AREA_PADDING })
    // .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .backgroundColor('#F1F3F5')
  }
}
