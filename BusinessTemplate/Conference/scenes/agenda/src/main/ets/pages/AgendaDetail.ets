import { promptAction } from '@kit.ArkUI';
import { UserInfoDetail, isSigned, Phone, MyConfig, WebViewParams, AppUtil } from 'commons';
import { AgendaDetailModel, AgendaItemModel, liveItem } from '../viewModel/AgendaDetailModel';
import { AgendaListItemModel } from '../viewModel/AgendaModel'
import { ScheduleItem } from '../view/ScheduleItem'
import {
  addReserve,
  deleteReserve,
  getReserveList,
  getSubSeminarDetail,
  getSubSeminarList,
  addCalendar,
  getAgendaLiveStatus
} from '../service/AgendaService'
import dayjs from 'dayjs'
import { AgendaListItem } from '../view/AgendaListItem';
import { calendarManager } from '@kit.CalendarKit';
import { addEvent, requestCalendarPermissions, requestPermissionOnSetting } from '../utils/CalendarUtil'
import { abilityAccessCtrl, common, PermissionRequestResult, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';


@Builder
export function AgendaDetailBuilder() {
  AgendaDetail()
}

@Component
struct SubTitle {
  @Prop title: string = ''
  @Prop bgcolor: string = ''

  build() {
    Row() {
      Column()
        .width(3)
        .height(14)
        .backgroundColor(this.bgcolor)
        .borderRadius(1)
        .margin({ right: 5, top: 1 })
      Text(this.title)
        .lineHeight(24)
        .fontSize(16)
        .fontColor('#000000')
        .fontWeight(700)
    }
    .margin({
      top: 16,
      bottom: 10
    })
    .width('100%')
  }
}

const weekMap: Record<string, string> = {
  'monday': '周一',
  'tuesday': '周二',
  'wednesday': '周三',
  'thursday': '周四',
  'friday': '周五',
  'saturday': '周六',
  'sunday': '周日'
};
//1  直播  2 结束 3 回顾 0  敬请期待
const liveStatus: Record<string, string> = {
  '0': '直播未开始',
  '1': '直播进行中',
  '2': '直播已结束',
  '3': '直播回放'
}

interface MyParams {
  id: string
}

@Component
export struct AgendaDetail {
  @Consume('pageStack') pageStack: NavPathStack
  scroller: Scroller = new Scroller()
  listScroller: Scroller = new Scroller()
  @StorageProp('token') token: string = '';
  @StorageProp('deviceId') deviceId: string = '';
  @StorageLink('addCalcIds') addCalcIds: string[] = [];
  @StorageLink('userInfo') userInfo: UserInfoDetail = new UserInfoDetail()
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm'
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @State private navTitle: string = ''
  @State scrollY: number = 0
  @State headerOpacity: number = 1
  @State contentTitleScale: number = 1
  @State agendaDetail: AgendaDetailModel | undefined = undefined;
  @State weekDay: string = ''
  @State isLoading: boolean = true;
  @State classList: string[] = ['议程简介', '议程安排', '相关议程']
  @State activeIndex: number = 0
  @State showTab: boolean = false
  @State subSeminarId: string = ''
  @State isAddCalc: boolean = false
  @State agendaDetailTopHeight: number = 0
  @State agendaDetailInfoHeight: number = 0
  @State isOpen: boolean = false
  @State isShowCollapse: boolean = false
  @StorageLink('isAgree') isAgree: boolean = false;
  @State agendaCorrelationData: AgendaListItemModel[] = []
  @State agendaAllList: AgendaListItemModel[] = []
  @State myAgendaAllList: string[] = []
  @State refreshFlag: boolean = true
  @State listStatusLive: liveItem[] = []

  aboutToAppear() {
    let params: MyParams =
      this.pageStack.getParamByName('AgendaDetail')[this.pageStack.getParamByName('AgendaDetail').length-1] as MyParams
    this.subSeminarId = params.id
    this.loadData()
  }

  loadData() {
    // this.isLoading = true
    if (this.addCalcIds.includes(this.subSeminarId)) {
      this.isAddCalc = true
    }

    Promise.all([
      this.getAgendaDetail(),
      this.getLiveStatus(),
      this.getAgendaCorrelation(),
      this.getMyCollAgendaList(),
    ]).then(async () => {

      let favoriteId = this.myAgendaAllList.find((item) => item === this.agendaDetail?.mThirdSeminarId)
      if (favoriteId) {
        if (this.agendaDetail) {
          this.agendaDetail.isCollect = true
          this.agendaDetail.favoriteId = favoriteId;
        }
      }

      let list = this.agendaAllList.filter((item) => {
        return this.agendaDetail && this.agendaDetail.mLikeMeeting &&
          this.agendaDetail.mLikeMeeting.indexOf(item.mThirdSeminarId) > -1
      })

      if (this.agendaDetail && this.agendaDetail.mLiveUrl) {
        if (this.listStatusLive.length > 0) {
          this.listStatusLive.forEach((liveItem: liveItem) => {
            if (this.agendaDetail && this.agendaDetail.mLiveUrl.indexOf(liveItem.liveId) > -1) {
              this.agendaDetail.mLiveStatus = liveItem.status
            }
          })
        } else {
          this.agendaDetail.mLiveStatus = '0' // 默认敬请期待 暂定 1  直播  2 结束 3 回顾 0  敬请期待
        }
      }


      list.sort((a, b) => {
        return dayjs(parseInt(a.startTime) * 1000).valueOf() - dayjs(parseInt(b.startTime) * 1000).valueOf()
      })

      list.forEach((subItem, m) => {
        const index =  this.myAgendaAllList.indexOf(subItem.mThirdSeminarId);
        subItem.isCollect = index !== -1
        subItem.favoriteId = this.myAgendaAllList[index] || ''
      })

      this.agendaCorrelationData = list.map((item) => {
        return new AgendaListItemModel(item)
      })

      if (this.agendaDetail?.mAgendaType === '活动') {
        this.classList = ['活动介绍']
      } else {
        let hasAgenda = this.agendaDetail?._agendaList && this.agendaDetail?._agendaList.length > 0 ? ['议程安排'] : []
        let hasRecommend = this.agendaCorrelationData.length > 0 ? ['相关议程'] : []
        this.classList = ['议程简介', ...hasAgenda, ...hasRecommend]
      }
      this.isLoading = false
    })
  }

  updateStatus() {
    return Promise.all([
      this.getLiveStatus(),
      this.getMyCollAgendaList()
    ]).then(() => {
      let favoriteId = this.myAgendaAllList.find((item) => item === this.agendaDetail?.mThirdSeminarId)
      if (favoriteId) {
        if (this.agendaDetail) {
          this.agendaDetail.isCollect = true
          this.agendaDetail.favoriteId = favoriteId;
        }
      } else {
        if (this.agendaDetail) {
          this.agendaDetail.isCollect = false
        }
      }

      if (this.agendaDetail && this.agendaDetail.mLiveUrl) {
        if (this.listStatusLive.length > 0) {
          this.listStatusLive.forEach((liveItem: liveItem) => {
            if (this.agendaDetail && this.agendaDetail.mLiveUrl.indexOf(liveItem.liveId) > -1) {
              this.agendaDetail.mLiveStatus = liveItem.status
            }
          })
        } else {
          this.agendaDetail.mLiveStatus = '0' // 默认敬请期待 暂定 1  直播  2 结束 3 回顾 0  敬请期待
        }
      }

      this.agendaCorrelationData.forEach((subItem, m) => {
        subItem.isCollect = this.myAgendaAllList.indexOf(subItem.mThirdSeminarId) !== -1;
      })
    })
  }

  // 获取议程详情
  getAgendaDetail() {
    return getSubSeminarDetail(this.subSeminarId).then(async (res) => {
      if (res.data.mMeetingTypeCn === '主题演讲') {
        res.data.mAgendaType = '主题演讲'
      }
      res.data.name = res.data.name.replace('|', '')
        .split('###')[0] || '';
      if (res.data.agendaList && res.data.agendaList[0] &&
      res.data.agendaList[0].agendas) {
        res.data._agendaList = res.data.agendaList[0].agendas
      }
      this.agendaDetail = res.data;
      this.weekDay = weekMap[dayjs(parseInt(this.agendaDetail.startTime) * 1000).format('dddd').toLowerCase()];
      this.navTitle = this.agendaDetail.name
    })
  }

  // 获取直播状态
  getLiveStatus() {
    return getAgendaLiveStatus().then(async (res) => {
      this.listStatusLive = res.data
    }).catch(() => {
      this.listStatusLive = []
      return Promise.resolve([])
    })
  }

  // 获取相关议程
  getAgendaCorrelation() {
    return getSubSeminarList().then(async (res) => {
      let list = res.data
      this.agendaAllList = list
    })
  }

  // 获取我的收藏列表
  getMyCollAgendaList() {
    if (!this.token) {
      return Promise.resolve([])
    }
    return getReserveList({
      token: this.token,
    }).then((res) => {
      this.myAgendaAllList = res.data
      return Promise.resolve(res.data)
    }).catch(() => {
      return Promise.resolve([])
    })
  }

  getColor() {
    switch (this.agendaDetail?.mAgendaType) {
      case '主题演讲':
        return '#F2403D'
      case '议程':
        return '#153AD1'
      default:
        return '#972EC3'
    }
  }

  getBgUrl() {
    switch (this.agendaDetail?.mAgendaType) {
      case '主题演讲':
        return 'agenda2%2Fagenda_detail_bg_1.png?token=51e59091-1cec-4a1d-ad6b-611172b25617'
      case '议程':
        return 'agenda2%2Fagenda_detail_bg_3.png?token=648e1ed8-4a6d-4d43-b084-300fa44d3f3b'
      case '活动':
        return 'agenda2%2Fagenda_detail_bg_3.png?token=648e1ed8-4a6d-4d43-b084-300fa44d3f3b'
      default:
        return ''
    }
  }

  getFlowerUrl() {
    switch (this.agendaDetail?.mAgendaType) {
      case '主题演讲':
        return 'agenda2%2Fagenda_detail_bg_1_flower.png?token=57b9105f-0cdb-4275-9e3c-c375c1569c09'
      case '议程':
        return 'agenda2%2Fagenda_detail_bg_3_flower.png?token=e797160c-8a1f-4a40-a30e-f20bdc092069'
      case '活动':
        return 'agenda2%2Fagenda_detail_bg_3_flower.png?token=e797160c-8a1f-4a40-a30e-f20bdc092069'
      default:
        return ''
    }
  }

  getSign() {
    return isSigned({
      token: this.token,
    }).then(res => {
      if (res.data.isSign === 1) {
        this.isAgree = true
      }
      return Promise.resolve(res.data.isSign === 1)
    }).catch(() => {
      return Promise.resolve(false)
    })
  }

  loginSuccess() {
    if (!this.isAgree) {
      this.getSign().then((res) => {
        if (!res) {
          this.pageStack.pushPath({
            name: 'PrivacyDialog',
            param: null,
            onPop: (popInfo: PopInfo) => {
              if (popInfo.result === 'success') {
                this.signPrivacySuccess()
              }
            }
          })
        } else {
          this.signPrivacySuccess()
        }
      })
    } else {
      this.signPrivacySuccess()
    }
  }

  async signPrivacySuccess() {
    let myCollAgendaList = await this.getMyCollAgendaList()
    if (myCollAgendaList.some((item) => item ===
      this.agendaDetail?.mThirdSeminarId)) {
      if (this.agendaDetail) {
        this.agendaDetail.isCollect = true
      }
      return
    }
    this.isCollect(this.getUIContext())
  }

  async jumpFunc() {
    if (!this.isAgree) {
      await this.getSign()
      if (!this.isAgree) {
        this.pageStack.pushPath({
          name: 'PrivacyDialog',
          param: null,
          onPop: (popInfo: PopInfo) => {
            if (popInfo.result === 'success') {
              this.signPrivacySuccess()
            }
          }
        })
        return
      }
    }
    this.isCollect(this.getUIContext())
  }

  addCalendarSuccess() {
    this.addCalcIds.push(this.subSeminarId)
    this.isAddCalc = true;
  }

  /// 是收藏还是取消收藏
  isCollect(context: UIContext, item?: AgendaListItemModel) {
    if (this.agendaDetail) {
      this.agendaDetail.isCollect = !this.agendaDetail.isCollect
    }
    if (this.agendaDetail?.isCollect) {
      // 收藏
      addReserve({
        token: this.token,
        favoriteId: this.agendaDetail?.mThirdSeminarId || '',
      }).then((res) => {
        context.getPromptAction().showToast({
          alignment: Alignment.Center,
          message: '收藏成功',
          duration: 500
        });
      })
    } else {
      // 取消收藏
      deleteReserve({
        token: this.token,
        favoriteId: this.agendaDetail?.mThirdSeminarId || '',
      }).then((res) => {
        context.getPromptAction().showToast({
          alignment: Alignment.Center,
          message: '取消收藏成功',
          duration: 500
        });
      })
    }

  }

  @Builder
  buildNavTitle(title: string) {
    Text(title)
      .opacity(this.headerOpacity)
      .fontSize(20)
      .fontWeight(700)
      .height(56)
      .maxLines(1)
      .fontColor('#000000')
      .textOverflow({
        overflow: TextOverflow.Ellipsis
      })
      .margin({ left: 8 })
      .animation({ duration: 300, curve: Curve.EaseOut })
  }

  @Builder
  tabBuilder(text: string, idx: number, color: string) {
    Row() {
      Text(text)
        .fontSize(this.activeIndex === idx ? 16 : 14)
        .fontColor(this.activeIndex === idx ? color : '#99000000')
        .fontWeight(this.activeIndex === idx ? '700' : '400')
        .lineHeight(this.activeIndex === idx ? 24 : 20)
    }
    .width(90)
    .height(50)
    .justifyContent(FlexAlign.Center)
    .border({
      width: {
        bottom: 2,
      },
      color: this.activeIndex === idx ? color : 'transparent',
    })
    .onClick(() => {
      this.activeIndex = idx
      this.listScroller.scrollToIndex(this.activeIndex)
    })
  }

  build() {
    NavDestination() {
      Stack() {
        if (!this.isLoading) {
          Stack({ alignContent: Alignment.Bottom }) {
            Scroll(this.scroller) {
              Column() {
                Column() {
                  Row() {
                    Text(this.agendaDetail?.name)
                      .layoutWeight(1)
                      .margin({ right: this.agendaDetail?.mAgendaType !== '活动' ? 23 : 0 })
                      .lineHeight(26)
                      .fontSize(18)
                      .fontWeight(700)
                    Stack() {
                      Image(this.agendaDetail?.isCollect ?
                        `${MyConfig.URL}my2%2Fagenda_collectioned.png?token=1f4e16bb-0412-4781-8410-897e5b35b343` :
                        `${MyConfig.URL}agenda2%2Fagenda_collection.png?token=02af0472-2ff3-4a1c-84c6-c05da8906e57`)
                        .width(34)
                        .onClick(() => {
                          this.jumpFunc()
                        })
                      if (!this.token) {
                        Phone({
                          cWidth: 34,
                          cHeight: 34,
                          callback: () => {
                            this.loginSuccess()
                          }
                        })
                      }
                    }

                  }.alignItems(VerticalAlign.Center).margin({ bottom: 10 })

                  Text() {
                    Span(dayjs(parseInt(this.agendaDetail?.startTime) * 1000).format('MM/DD'))
                    Span(` ${this.weekDay} `)
                    Span(`${dayjs(parseInt(this.agendaDetail?.startTime) * 1000)
                      .format('HH:mm')}-${dayjs(parseInt(this.agendaDetail?.endTime) * 1000).format('HH:mm')}`)
                  }.fontSize(14).fontColor($r('sys.color.mask_secondary')).margin({ bottom: 20 }).width('100%')

                  Row() {
                    Image(`${MyConfig.URL}agenda2%2Fagenda_address2.png?token=bd51bfc0-b56d-4576-b0ce-7d5e9c7d9150`)
                      .width(14)
                      .margin({ right: 4 })
                    Text(this.agendaDetail?.hotel).layoutWeight(1).margin({ right: 16 }).fontSize(14)
                    if (this.agendaDetail?.agendMapName && this.agendaDetail?.mJingDu &&
                      this.agendaDetail?.agendaCorrelationData) {
                      Stack() {
                        Image(`${MyConfig.URL}agenda3%2FgoHere.png?token=e5a6ecc7-635d-457a-b87f-159a25a937da`).width(88)
                        Text('去这里').fontSize(14).fontColor($r('sys.color.mask_secondary'))
                      }.onClick(() => {
                        let lng = this.agendaDetail?.mJingDu
                        let lat = this.agendaDetail?.agendaCorrelationData
                        let name = this.agendaDetail?.agendMapName
                        if (!lat || !lng || !name) {
                          return
                        }
                        let mapUrl = getContext(this).resourceManager.getStringByNameSync('map_url');
                        const bundleName = AppUtil.getBundleName();
                        const uri =
                          `${mapUrl}/routes?daddr=${lat},${lng}(${name})&type=drive&utm_source=${bundleName}}`;
                        let context = getContext(this) as common.UIAbilityContext;
                        context.openLink(uri, {
                          appLinkingOnly: false
                        }).then(() => {
                          console.info('openlink success.');
                        })
                          .catch((error: BusinessError) => {
                            console.error(`openlink failed. error:${JSON.stringify(error)}`);
                          });
                      })
                    }
                  }.alignItems(VerticalAlign.Center)

                  if (this.agendaDetail?.mLiveUrl) {
                    Row() {
                      Image(`${MyConfig.URL}agenda2%2Fagenda_live.png?token=c2c141de-0a9c-492a-a434-193b8dcc2be6`)
                        .width(16)
                        .margin({ right: 6 })
                      Text(liveStatus[this.agendaDetail.mLiveStatus])
                        .fontSize(14)
                        .fontColor($r('sys.color.black'))
                        .fontWeight(500)
                    }
                    .justifyContent(FlexAlign.Center)
                    .width('100%')
                    .height(40)
                    .backgroundColor('#b3ffffff')
                    .border({
                      width: 1,
                      color: Color.White,
                      radius: 20
                    })
                    .margin({ top: 26 })
                    .onClick(() => {
                      this.pageStack.pushPath({
                        name: 'MyWebView',
                        param: new WebViewParams(this.agendaDetail?.mLiveUrl)
                      })
                    })
                  }

                }.width('100%').padding({
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: 32
                })
                .id('agenda_detail_top')
                .onSizeChange((oldValue, newValue: SizeOptions) => { // 获取最外层盒子高度
                  if (newValue.height !== 0) {
                    this.agendaDetailTopHeight = newValue.height as number
                  }
                })

                Column() {
                  if (this.agendaDetail?.mAgendaType !== '活动') {
                    Tabs() {
                      ForEach(this.classList, (item: string, index: number) => {
                        TabContent() {
                        }
                        .tabBar(this.tabBuilder(item, index, this.getColor()))
                      }, (item: string) => JSON.stringify(item))
                    }
                    .width('100%')
                    .height(50)
                    .border({
                      width: {
                        bottom: 1,
                      },
                      color: '#d5d5d5',
                    })

                    .visibility(this.showTab ? Visibility.Visible : Visibility.None)
                    .animation({ duration: 300 })
                  }
                  List({ scroller: this.listScroller }) {
                    if (this.agendaDetail?.mParseIntro) {
                      ListItem() {
                        Column() {
                          // 议程简介
                          SubTitle({
                            title: this.agendaDetail?.mAgendaType === '活动' ? '活动介绍' : '议程简介',
                            bgcolor: this.getColor()
                          })

                          Column() {
                            Text(this.agendaDetail?.mParseIntro)
                              .fontSize(14)
                              .fontColor('#99111111')
                              .lineHeight(22)
                              .maxLines(this.isShowCollapse ? (this.isOpen ? 100 : 5) : 100)
                              .textOverflow({
                                overflow: TextOverflow.Ellipsis
                              })
                              .width('100%')
                              .onSizeChange((oldValue, newValue: SizeOptions) => { // 获取最外层盒子高度
                                if (newValue.height !== 0) {
                                  if (this.agendaDetail?.mAgendaType !== '活动') {
                                    this.agendaDetailInfoHeight = newValue.height as number
                                    if (this.agendaDetail && this.agendaDetail?._agendaList &&
                                      this.agendaDetail?._agendaList.length > 0) {
                                      if (this.agendaDetailInfoHeight > 22 * 5 + 11 && !this.isShowCollapse) {
                                        this.isShowCollapse = true
                                      }
                                    } else {
                                      this.isShowCollapse = false
                                    }

                                  } else {
                                    this.isShowCollapse = false
                                  }
                                }
                              })

                            if (this.isShowCollapse) {
                              Row() {
                                Text(this.isOpen ? '收起' : '展开')
                                  .fontSize(14).lineHeight(20)
                                  .fontColor('#7a000000')
                                  .margin({ right: 4 })
                                Image(`${MyConfig.URL}/project/hdc/2025/static/images/agenda_more.png`)
                                  .width(10)
                                  .rotate({ angle: this.isOpen ? 180 : 0 })
                                  .animation({
                                    duration: 300,
                                  })
                              }
                              .justifyContent(FlexAlign.Center)
                              .width(62)
                              .height(24)
                              .borderRadius(12)
                              .backgroundColor('#ffffff')
                              .margin({ top: 12 })
                              .onClick(() => {
                                this.isOpen = !this.isOpen
                              })
                            }
                            if (this.agendaDetail && this.agendaDetail?._agendaList &&
                              this.agendaDetail?._agendaList.length === 0) {
                              Column().height(60)
                            }

                          }

                        }
                      }
                    }
                    if (this.agendaDetail?._agendaList && this.agendaDetail?._agendaList.length > 0 &&
                      this.agendaDetail?.mAgendaType !== '活动') {
                      ListItem() {
                        Column() {
                          Divider().height(1).backgroundColor('#1ad9dbdc').margin({ top: 16 })
                          // 议程安排
                          SubTitle({
                            title: '议程安排',
                            bgcolor: this.getColor()
                          })
                          Column() {
                            if (this.agendaDetail?._agendaList.length > 0) {
                              ForEach(this.agendaDetail?._agendaList, (item: AgendaItemModel, index: number) => {
                                ScheduleItem({
                                  item: item,
                                  agendaDetail: this.agendaDetail,
                                  isLast: index === (this.agendaDetail?._agendaList || []).length - 1
                                })
                              }, (item: AgendaItemModel) => item.agendaId)
                            } else {
                              Column() {
                                Image(`${MyConfig.URL}agenda3%2Fno_data_plan.png?token=1bc592b5-0525-4d67-844d-b1d2157c938e`)
                                  .width(86)
                                  .margin({
                                    bottom: 5
                                  })
                                Text('敬请期待').fontSize(12).lineHeight(13).fontColor('#66000000')
                              }
                              .height(100)
                              .justifyContent(FlexAlign.Center)
                              .alignItems(HorizontalAlign.Center)

                            }

                          }.width('100%')
                          .padding({
                            left: 16,
                            right: 16,
                            bottom: 20
                          })
                          .backgroundColor($r('sys.color.white')).borderRadius(20)
                        }
                        .padding({ bottom: this.classList.includes('相关议程') ? 0 : 180 })
                        .constraintSize({
                          minHeight: this.classList.includes('相关议程') ? 0 : '100%',
                        })
                      }

                    }
                    if (this.classList.includes('相关议程')) {
                      ListItem() {
                        Column() {
                          Divider().height(1).backgroundColor('#1ad9dbdc').margin({ top: 16 })
                          // 相关议程
                          SubTitle({
                            title: '相关议程',
                            bgcolor: this.getColor()
                          })
                          GridRow({ gutter: { x: 8, y: 8 } }) {
                            ForEach(this.agendaCorrelationData, (subItem: AgendaListItemModel, index: number) => {
                              GridCol({
                                span: {
                                  sm: 12,
                                  md: 6,
                                  lg: 6,
                                },
                              }) {
                                AgendaListItem({
                                  item: this.agendaCorrelationData[index], isRecommend: true,
                                })
                              }

                            }, (subItem: AgendaListItemModel) => subItem.subSeminarId)
                          }
                        }
                        .padding({ bottom: 180 })
                        .constraintSize({
                          minHeight: '100%',
                        })
                      }
                    }
                  }
                  .scrollBar(BarState.Off)
                  .width('100%')
                  .height(`100%`)
                  .nestedScroll({
                    scrollForward: NestedScrollMode.PARENT_FIRST,
                    scrollBackward: NestedScrollMode.SELF_FIRST
                  })
                  .onScrollIndex((index) => {
                    this.activeIndex = index
                  })
                  .padding({
                    left: 16,
                    right: 16,
                  })
                }
                .width('100%')
                .height('100%')
                .linearGradient({
                  colors: [['#ffffff', 0.0], ['#F1F3F5', 0.5], ['#F1F3F5', 1.0]]
                })
                .borderRadius({
                  topLeft: 20,
                  topRight: 20,
                })
              }
            }
            .scrollBar(BarState.Off)
            .edgeEffect(EdgeEffect.Spring)
            .width('100%')
            .height('100%')
            .onWillScroll((xOffset: number, yOffset: number, scrollState: ScrollState) => {
              let scrollHeight = this.scroller.currentOffset().yOffset
              if (parseInt(scrollHeight + '') >= parseInt(this.agendaDetailTopHeight + '') - 50) {
                this.showTab = true
              } else {
                this.showTab = false
              }
            })

            Column() {
              if (this.isAddCalc) {
                Button('已添加至日历')
                  .width(178)
                  .fontColor($r('sys.color.font_emphasize'))
                  .backgroundColor('rgba(240,240,240,0.9)')
              } else {
                  Button('添加至日历')
                    .width(178)
                    .onClick(async () => {
                  this.refreshFlag = false
                  if (this.isAddCalc) {
                    return
                  }

                  let eventParams: calendarManager.Event = {
                    location: { location: this.agendaDetail?.hotel },
                    type: 0,
                    title: this.agendaDetail?.name || '',
                    description: this.agendaDetail?.mParseIntro,
                    startTime: parseInt(this.agendaDetail?.startTime || '0'),
                    endTime: parseInt(this.agendaDetail?.endTime || '0'),
                  }

                  let calendarMgr: calendarManager.CalendarManager | null = null;
                  const permissions: Permissions[] = ['ohos.permission.READ_CALENDAR', 'ohos.permission.WRITE_CALENDAR'];
                  let atManager = abilityAccessCtrl.createAtManager();
                  atManager.requestPermissionsFromUser(this.getUIContext().getHostContext()!, permissions)
                    .then((result: PermissionRequestResult) => {
                      calendarMgr = calendarManager.getCalendarManager(this.getUIContext().getHostContext()!);
                      calendarMgr.getCalendar().then((data: calendarManager.Calendar) => {
                        addEvent(this.getUIContext().getHostContext()!, eventParams, () => {
                          this.addCalendarSuccess()
                        })
                        console.info(`Succeeded in getting calendar, data -> ${JSON.stringify(data)}`);
                      }).catch((err: BusinessError) => {
                        this.getUIContext().getPromptAction().showToast({
                          message: '日历授权出现错误'
                        })
                      });
                    })
                    .catch((error: BusinessError) => {
                      this.getUIContext().getPromptAction().showToast({
                        message: '日历授权出现错误'
                      })
                    })
                })
              }
            }.margin({
              bottom: 40
            })
          }
          .backgroundImage(`${MyConfig.URL}${this.getFlowerUrl()}`)
          .backgroundImageSize({
            width: 260,
          })
          .backgroundImagePosition(Alignment.TopEnd)
          .height('100%')
          .width('100%')
        }

        if (this.isLoading) {
          Column() {
            LoadingProgress().width(70)
          }.backgroundColor($r('sys.color.white')).width('100%').height('100%').justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
    }
    .padding({ top: px2vp(this.topRectHeight) })
    .backgroundImage(this.getBgUrl() ?
      `${MyConfig.URL}${this.getBgUrl()}` : '')
    .backgroundImageSize({
      width: '100%',
    })
    .backgroundImagePosition(Alignment.TopStart)
    .backgroundColor('#F1F3F5')
    .title(this.buildNavTitle(this.showTab ? this.navTitle : ''))
    .onShown(() => {
      if (this.refreshFlag) {
        if (this.agendaDetail?.name) {
          this.updateStatus()
        }
      }
      this.refreshFlag = true
    })
  }
}
