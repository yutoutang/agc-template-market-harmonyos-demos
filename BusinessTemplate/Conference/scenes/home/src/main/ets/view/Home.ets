import HomeTitle from '../view/HomeTitle'
import Countdown from '../view/Countdown'
import ExcitingVideos from '../view/ExcitingVideos'
import HomeAgenda from '../view/HomeAgenda'
import dayjs from 'dayjs'
import {
  seminarContactsGet,
  getTicketRoleArticleList,
  MyConfig,
  Constants,
  UserInfoDetail,
  BreakPointConstants,
  AvoidRepeatClick,
  AppUtil,
  BreakpointType,
} from 'commons'
import HomePartner from '../view/HomePartner'
import HomeActivities from '../view/HomeActivities'
import { AddFormMenuItem, display } from '@kit.ArkUI'
import { formBindingData } from '@kit.FormKit'
import { completeTask } from '../service/homeService'

interface CardObject {
  formName: string
  formDimension: number
  compEnName: string
}

const ticketInfoMap: Record<string, string> = {
  'VIP票': '1',
  '专家票': '2',
  '全通票': '3',
  '单日票': '4',
  '学生票': '5',
  '双日票': '6',
  '员工票': '3',
}

const ticketTagColors: Record<string, string[]> = {
  0: ['#2647C95C', '#4D47C95C'],
  1: ['#26FFBB99', '#4DFFBB99'],
  2: ['#261FB5F0', '#4D1FB5F0'],
  3: ['#26FFBB99', '#4DFFBB99'],
  4: ['#261FB5F0', '#4D1FB5F0'],
  5: ['#26ABE66C', '#4DABE66C'],
  6: ['#26FFBB99', '#4DFFBB99'],
}

@Component
export struct Home {
  @StorageProp('deviceId') deviceId: string = '';
  @Consume('pageStack') pageStack: NavPathStack
  @Consume('agendaParams') agendaParams: number;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @State roleList: string[] = []
  @State roleIndex: string = '0'
  @State roleDate: string[] = []
  @State greetingMessage: string = ''
  @State isShowCountdown: boolean = true
  @StorageProp('token') @Watch('hasToken') token: string = '';
  @StorageLink('userInfo') userInfo: UserInfoDetail = new UserInfoDetail()
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm'
  @StorageLink('ticketRoleArticle') ticketRoleArticle: string[] = [];
  @StorageLink('mainTabIndex') currentTabIndex: number = 0;
  @StorageProp('isRecommendation') isRecommendation: boolean = true;
  private compId: string = 'addforms@hdc2025';
  @State isShowCardViewSheet: boolean = false
  @State isShowCardViewSheet2: boolean = false
  @State isSmallHeight: boolean = false
  @State cardList: CardObject[] = [
    {
      formName: 'ticketWidget',
      formDimension: 2,
      compEnName: 'ticket',
    },
    {
      formName: 'bigAgendaWidget',
      formDimension: 4,
      compEnName: 'bigAgendaWidget',
    },
    {
      formName: 'mediumAgendaWidget',
      formDimension: 3,
      compEnName: 'mediumAgendaWidget',
    },
    {
      formName: 'smallAgendaWidget',
      formDimension: 2,
      compEnName: 'smallAgendaWidget',
    }
  ]
  @State days: number = 0;
  @State _day: number = 0
  scroller: Scroller = new Scroller()
  @State isScrolling: boolean = false
  isScrollingTimer = 0

  hasToken() {
    if (this.token) {
      try {
        this.getContactInfo()
      } catch (e) {
      }
    }
  }

  aboutToAppear() {
    this.getContactInfo()
    this.getUIContext().getHostContext()!.eventHub.on('onShown', (index: number) => {
      if (index === Constants.PAGE_INDEX_HOME) {
        this.updateGreetingMessage()
        if (this.userInfo.ticketTypeName) {
          this.roleIndex = ticketInfoMap[this.userInfo.ticketTypeName as string] || '3'
          let meetDay = this.userInfo.meetDay as string[]
          let roleDate: string[] = []
          roleDate.push(dayjs(meetDay[0]).format('MM月DD日'))
          if (meetDay.length > 1) {
            roleDate.push(dayjs(meetDay[meetDay.length-1]).format('DD日'))
          }
          this.roleDate = roleDate
          this.roleList = this.ticketRoleArticle
        }
        this.getContactInfo()
      }
    });
    this.getUIContext().getHostContext()!.eventHub.on('switchTab', (index: number) => {
      if (index === Constants.PAGE_INDEX_HOME) {
        this.updateGreetingMessage()
        if (this.userInfo.ticketTypeName) {
          this.roleIndex = ticketInfoMap[this.userInfo.ticketTypeName as string] || '3'
          let meetDay = this.userInfo.meetDay as string[]
          let roleDate: string[] = []
          roleDate.push(dayjs(meetDay[0]).format('MM月DD日'))
          if (meetDay.length > 1) {
            roleDate.push(dayjs(meetDay[meetDay.length-1]).format('DD日'))
          }
          this.roleDate = roleDate
          this.roleList = this.ticketRoleArticle
        }
        this.getContactInfo()
      }
    });

    let displayClass: display.Display | null = null;
    displayClass = display.getDefaultDisplaySync();
    if (Number(displayClass.height) < 2200) {
      this.isSmallHeight = true
    } else {
      this.isSmallHeight = false
    }
  }

  aboutToDisappear(): void {
    this.getCountDownCardTime()
  }

  getContactInfo() {
    // 获取报名信息
    if (this.token) {
      seminarContactsGet({
        token: this.token,
      }).then((res) => {
        this.userInfo = res.data as UserInfoDetail;
        getTicketRoleArticleList().then(roleRes => {
          let findData = roleRes.data.find((item) => {
            return item.title === this.userInfo.ticketTypeName
          })
          if (findData) {
            this.roleList = findData.summary.split('；')
            this.ticketRoleArticle = this.roleList
          }
        })
        this.roleIndex = ticketInfoMap[this.userInfo.ticketTypeName as string] || '3'
        let meetDay = this.userInfo.meetDay as string[]
        let roleDate: string[] = [];
        roleDate.push(dayjs(meetDay[0]).format('MM/DD'))
        if (meetDay.length > 1) {
          roleDate.push(dayjs(meetDay[meetDay.length - 1]).format('MM/DD'))
        }
        this.roleDate = roleDate
      })
    }
  }

  updateGreetingMessage() {
    this.isShowCountdown = dayjs().isBefore(dayjs('2025-09-26'))
    const currentHour = dayjs().hour();
    if (currentHour >= 5 && currentHour <= 8) {
      this.greetingMessage = '早上好';
    } else if (currentHour >= 9 && currentHour <= 11) {
      this.greetingMessage = '上午好';
    } else if (currentHour >= 12 && currentHour <= 13) {
      this.greetingMessage = '中午好';
    } else if (currentHour >= 14 && currentHour <= 17) {
      this.greetingMessage = '下午好';
    } else if (currentHour >= 18 && currentHour <= 23) {
      this.greetingMessage = '晚上好';
    } else if (currentHour >= 0 && currentHour <= 4) {
      this.greetingMessage = '夜深了';
    } else {
      this.greetingMessage = '首页'; // 可以根据需要设置默认问候
    }
  }

  getTicketTagColor(index: number): string[] {
    if (index > 6) {
      return ticketTagColors[0]
    }
    return ticketTagColors[index];
  }

  getCountDownCardTime() {
    this._day = Math.ceil(dayjs('2025-06-22').diff(dayjs()) / (1000 * 3600 * 24));
    this.days = Math.ceil(dayjs('2025-06-20').diff(dayjs()) / (1000 * 3600 * 24));
  }

  build() {
    Stack({
      alignContent: Alignment.BottomEnd
    }) {
      Column() {
        Column() {
          Text(this.greetingMessage)
            .width('100%')
            .fontSize(24)
            .fontColor('#111111')
            .fontWeight(700)
        }.height(56).justifyContent(FlexAlign.Center).padding({ left: 20 })

        Scroll(this.scroller) {
          Column() {
            // 搜索
            Row() {
              Image(`${MyConfig.URL}agenda2%2Fagenda_search_icon.png?token=e0d7eb27-6641-42c4-8caa-32d4de2fb0cd`)
                .width(16)
                .margin({ right: 6 })
              Text('搜索议程、活动、演讲嘉宾').fontSize(16).lineHeight(23).fontColor('#66000000')
            }
            .height(40)
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Start)
            .backgroundColor('#0d000000')
            .borderRadius(20)
            .width('calc(100% - 24vp)')
            .padding({
              left: 12
            })
            .margin({
              top: 16,
            })
            .onClick(() => {
              this.pageStack.pushPath({
                name: 'AgendaSearchAndFilter',
              })
            })

            Image(MyConfig.URL + 'new_home%2F111.png?token=c0b4b18e-e807-4176-abc5-98b7ac2ea1c8')
              .width('100%')
              .padding({
                top: 12,
                left: 16,
                right: 16
              })

            // 倒计时
            // 9月26凌晨零点 隐藏下方组件
            if (this.isShowCountdown) {
              Countdown()
            }

            if (this.token) {
              // 我的门票
              Column() {
                HomeTitle({ name: '我的门票' })
                Column() {

                  Stack(){
                    Image(MyConfig.URL+ 'home2%2Fbg_vip_card.png?token=2c9b8bef-9584-4d3f-83ee-c96c2f58d1d6')
                      .width('100%')
                      .height(46)
                      .border({ radius:{ topLeft:16, topRight: 16 } })

                    Row() {
                      Image(MyConfig.URL + 'home2%2Fic_public_equity.png?token=447bef99-fc98-44cf-950a-e4ec91001ef6')
                        .width(24)
                        .margin({
                          left: 16, right: 8
                        })
                      Text(this.userInfo.ticketTypeName?.toString())
                        .fontWeight(700)
                        .fontColor($r('sys.color.white'))
                        .fontSize(18)
                        .lineHeight(26)
                    }
                  }

                  Column(){
                    Column() {
                      Flex({
                        wrap: FlexWrap.Wrap
                      }) {
                        ForEach(this.roleList, (item: string, index: number) => {
                          Text(item)
                            .height(this.currentBreakpoint === 'sm' ? '36lpx' : 18)
                            .backgroundColor(this.getTicketTagColor(index)[0])
                            .border({
                              width: 1,
                              color: this.getTicketTagColor(index)[1]
                            })
                            .padding({ left: 8, right: 8 })
                            .borderRadius(100)
                            .margin({ right: 8, bottom: 8 })
                            .fontSize(10)
                            .fontColor('#99111111')
                        }, (item: string) => item)
                      }
                      .height(this.currentBreakpoint === 'sm' ? '90lpx' : 45)
                      .clip(true)
                    }.height(this.currentBreakpoint === 'sm' ? '154lpx' : 77).justifyContent(FlexAlign.Center)

                    Row() {
                      Image(MyConfig.URL + 'home2%2Fic_digital_schedule.png?token=a037067f-3121-421e-b51e-3172b3bd55c2')
                        .width(14)
                        .margin({ right: 6 })
                      Row() {
                        Text(this.roleDate[0]).fontSize(12).lineHeight(18).fontWeight(700)
                        if (this.roleDate.length > 1) {
                          SymbolGlyph($r('sys.symbol.minus'))
                            .fontSize(33)
                            .margin({ right: 5, left: 5 })
                          Text(this.roleDate[1]).fontSize(12).lineHeight(18).fontWeight(700)
                        }
                      }
                    }
                    .alignSelf(ItemAlign.Start)
                    .height(this.currentBreakpoint === 'sm' ? '88lpx' : 44)
                  }
                  .width('100%')
                  .backgroundColor(Color.White)
                  .border({ radius: { bottomLeft: 16, bottomRight: 16 } })
                  .padding({ left: 12, right: 12 })
                }
                .width('100%')
                .height(this.currentBreakpoint === 'sm' ? '382lpx' : 191)
                .padding(new BreakpointType<Padding>({
                  sm: {
                    top: 15,
                    left: $r('sys.float.padding_level8'),
                    right: $r('sys.float.padding_level8'),
                  },
                  md: {
                    top: 15,
                    left: $r('sys.float.padding_level12'),
                    right: $r('sys.float.padding_level12'),
                  },
                  lg: {
                    top: 15,
                    left: $r('sys.float.padding_level16'),
                    right: $r('sys.float.padding_level16'),
                  },
                }).getValue(this.currentBreakpoint))
                .margin({ top: 6 })
                .onClick(() => {
                  this.pageStack.pushPath({
                    name: 'Ticket'
                  })
                })
              }
            }

            // 展示个性推荐
            if (this.isRecommendation) {
              // 大会议程
              Column() {
                HomeTitle({
                  name: '大会议程',
                  isShowMore: true,
                  moreClickFun: () => {
                    this.currentTabIndex = 1
                    this.getUIContext().getHostContext()!.eventHub.emit('switchTab', this.currentTabIndex);
                  }
                })
                HomeAgenda()
              }
            }

            // 精彩活动
            Column() {
              HomeTitle({ name: '精彩活动' })
              HomeActivities()
                .margin({ top: 7 })
            }

            // 精彩视频
            Column() {
              HomeTitle({ name: '精彩视频' })
              ExcitingVideos()
            }

            // 合作伙伴
            Column() {
              HomeTitle({
                name: '合作伙伴',
                isShowMore: true,
                moreClickFun: () => {
                  this.pageStack.pushPath({ name: 'Partner' })
                }
              })

              HomePartner()
            }

            // 卡片
            Column() {
              HomeTitle({ name: '卡片上桌，信息秒Get' })
                .padding({
                  bottom: 20
                })

              Row() {
                Column() {
                  Stack({ alignContent: Alignment.Bottom }) {
                    Image(`${MyConfig.URL}%E5%8D%A1%E7%89%872%2FcardBg.png?token=2ee6b88f-4af5-41d3-984c-305337567f10`)
                      .height(300)
                      .height(new BreakpointType<number>({
                        sm: 300,
                        md: 350,
                        lg: 400,
                      }).getValue(this.currentBreakpoint))
                      .width(new BreakpointType<string>({
                        sm: '100%',
                        md: '70%',
                        lg: '70%',
                      }).getValue(this.currentBreakpoint))

                    Column() {
                      Column() {
                      }
                      .alignItems(HorizontalAlign.Start)
                      .justifyContent(FlexAlign.Center)
                      .width(this.currentBreakpoint === 'sm' ? '262lpx' : 131)
                      .height(this.currentBreakpoint === 'sm' ? '262lpx' : 131)
                      .margin({
                        left: this.currentBreakpoint === 'sm' ? '322lpx' : 161,
                        top: this.currentBreakpoint === 'sm' ? '94lpx' : 47
                      })
                      .rotate({
                        x: 0,
                        y: 0,
                        z: 1,
                        angle: -10
                      })
                    }
                    .alignItems(HorizontalAlign.Start)
                    .width(this.currentBreakpoint === 'sm' ? '720lpx' : 360)
                    .height(this.currentBreakpoint === 'sm' ? '602lpx' : 301)

                    Column() {
                    }
                    .width(this.currentBreakpoint === 'sm' ? '720lpx' : 360)
                    .height(this.currentBreakpoint === 'sm' ? '602lpx' : 301)
                    .id(this.compId)
                    .onClick(() => {
                      this.getCountDownCardTime()
                      this.isShowCardViewSheet = true;
                    })
                    .bindSheet($$this.isShowCardViewSheet, this.CardViewBuilder(), {
                      height: this.isSmallHeight ? '90%' : '82%',
                      dragBar: true,
                      preferType: SheetType.BOTTOM,
                      showClose: true,
                      title: { title: '' },
                      onDisappear: () => {
                        this.isShowCardViewSheet = false;
                      }
                    })
                  }
                  .padding({
                    bottom: 50
                  })
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }
              .justifyContent(FlexAlign.Center)
              .width('100%')
            }
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Start)
            .padding({
              top: 24,
              bottom: 40
            })

          }
          .width('100%')
        }
        .onDidScroll(() => {
          this.isScrolling = true
        })
        .onScrollStop(() => {
          this.isScrollingTimer && clearTimeout(this.isScrollingTimer)
          this.isScrollingTimer = setTimeout(() => {
            this.isScrolling = false
          }, 500)
        })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }

    }.padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
    .backgroundColor('#F1F3F5')
  }

  @Builder
  cardTitle(title: string) {
    Text(title)
      .fontSize(20)
      .margin({
        bottom: 20
      })
      .fontWeight(500)
  }

  @Builder
  cardTicketItem() {
    Column() {
    }
    .padding(12)
    .borderRadius(20)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundImage(`${MyConfig.URL}%E5%8D%A1%E7%89%872%2FcardTicket.png?token=fa5f6331-d181-4556-a125-7914bd74445e`)
    .backgroundImageSize(ImageSize.Cover)
    .width(140)
    .height(140)
    .shadow(ShadowStyle.OUTER_DEFAULT_MD)
    .margin({
      bottom: 136,
      top: 86
    })
  }

  @Builder
  bigAgendaWidget() {
    Column() {
    }
    .backgroundImage(`${MyConfig.URL}%E5%8D%A1%E7%89%872%2FcardLarge.png?token=347daa33-c57d-44b0-ac8a-8e262a3cfe6e`)
    .backgroundImageSize(ImageSize.Cover)
    .width(300)
    .height(312)
    .shadow(ShadowStyle.OUTER_DEFAULT_MD)
    .borderRadius(20)
    .margin({
      bottom: 50
    })
  }

  @Builder
  mediumAgendaWidget() {
    Column() {
    }
    .backgroundImage(`${MyConfig.URL}%E5%8D%A1%E7%89%872%2FcardMid.png?token=52aa8523-c36b-4092-a8bc-35232dac6d7c`)
    .backgroundImageSize(ImageSize.Cover)
    .width(300)
    .height(140)
    .shadow(ShadowStyle.OUTER_DEFAULT_MD)
    .borderRadius(20)
    .margin({
      bottom: 136,
      top: 86
    })
  }

  @Builder
  smallAgendaWidget() {
    Column() {
    }
    .backgroundImage(`${MyConfig.URL}%E5%8D%A1%E7%89%872%2FcardSmall.png?token=c15d3e86-0445-453b-b921-fcbaa6b41f59`)
    .backgroundImageSize(ImageSize.Cover)
    .width(140)
    .height(140)
    .shadow(ShadowStyle.OUTER_DEFAULT_MD)
    .borderRadius(20)
    .margin({
      bottom: 136,
      top: 86
    })
  }

  @Builder
  bottomItem2(icon: string, name: string, backColor: string) {
    Column() {
      Image(icon).width(32)
      Text(name).fontColor('#606162').fontSize(10).lineHeight(13).textAlign(TextAlign.Center)
    }
    .backgroundColor(backColor)
    .width(54)
    .height(54)
    .borderRadius(8)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  itemOption(name: string) {
    Column() {
      if (name === 'ticket') {
        this.cardTitle('我的门票')
        this.cardTicketItem()
      } else if (name === 'bigAgendaWidget') {
        this.cardTitle('大会议程')
        this.bigAgendaWidget()
      } else if (name === 'mediumAgendaWidget') {
        this.cardTitle('大会议程')
        this.mediumAgendaWidget()
      } else if (name === 'smallAgendaWidget') {
        this.cardTitle('大会议程')
        this.smallAgendaWidget()
      }

      Column() {
        Image(`${MyConfig.URL}%E5%8D%A1%E7%89%87%2FaddCard.png?token=419a29b2-b356-4d44-b31a-a2aec1eef564`)
          .width(360)
      }.position({
        bottom: -72
      }).width('100%')
    }
    .width('100%')
  }

  @Builder
  CardViewBuilder() {
    Column() {
      Swiper() {
        ForEach(this.cardList, (item: CardObject, index: number) => {
          Column() {
            AddFormMenuItem(
              {
                bundleName: AppUtil.getBundleName(), // 包名
                abilityName: 'EntryFormAbility', // 模块ability名称
                parameters: {
                  'ohos.extra.param.key.form_dimension': item.formDimension,
                  'ohos.extra.param.key.form_name': item.formName,
                  'ohos.extra.param.key.module_name': 'phone' // 模块名称
                },
              },
              this.compId,
              {
                formBindingData: formBindingData.createFormBindingData({}),
                callback: (error, formId) => {
                  if (error?.code === 0) {
                    this.getUIContext().getPromptAction().showToast({
                      alignment: Alignment.Bottom,
                      message: '卡片已添加',
                      duration: 2000
                    });
                    // 触发完成任务
                    if (this.token) {
                      AvoidRepeatClick.avoidRepeatClick(() => {
                        completeTask({
                          activityId: MyConfig.ACTIVITYID,
                          token: this.token,
                          taskId: [MyConfig.ADDTODESKTOPTASKID],
                          qrCode: '',
                          hideToast: true
                        })
                      });
                    }
                    this.isShowCardViewSheet = false
                    this.isShowCardViewSheet2 = false
                  } else {
                    this.getUIContext().getPromptAction().showToast({
                      message: '添加失败，请尝试其它添加方式',
                      duration: 2000
                    });

                  }
                },
                style: {
                  options: {
                    content: '                          ',
                    // labelInfo: '一键加桌2',
                    builder: this.itemOption(item.compEnName),
                  },
                }
              }
            )
          }
        }, (item: CardObject) => JSON.stringify(item))
      }
      .height('100%')
      .width('100%')
      .indicator(true)
      .loop(false)
      .padding({
        bottom: 40
      })
    }
  }
}