import { AppStorageV2 } from '@kit.ArkUI';
import { phoneRouterControl } from 'oh_router';
import {
  BarVM,
  CommonHeader,
  CompanyCard,
  CompanyInfo,
  getAppliedPositions,
  getCommunicatedPositions,
  getFavoriteCompanies,
  getFavoritePositions,
  getMockPositionList,
  InterviewCard,
  JobApplicationData,
  PositionCard,
  PositionInfo,
  RouterMap,
  TabItem,
  TValueType
} from 'common';
import { ProtocolRouterParams } from 'aggregated_login';
import { CompanyDetailPageBuilder, PositionDetailPageBuilder } from 'position';
import { DeliveryProgressPageBuilder } from './DeliveryProgressPage';
import { PendingInterviewPageBuilder } from './PendingInterviewPage';

@Builder
export function JobApplicationPageBuilder(params: TValueType) {
  JobApplicationPage({ pageParams: params })
}

@ComponentV2
export struct JobApplicationPage {
  @Param pageParams: TValueType = null;
  @Local selectedTab: number = 0;
  @Local jobAppData: JobApplicationData = AppStorageV2.connect(JobApplicationData, () => new JobApplicationData())!;
  @Local positionList: PositionInfo[] = getMockPositionList();
  @Local progressTab: string[] = ['已接受', '未接受']
  @Local favoritesTab: string[] = ['职位', '公司']
  @Local progressCurrent: string = '已接受'
  @Local favoritesCurrent: string = '职位'

  aboutToAppear() {
    this.jobAppData.updateData()
  }

  @Builder
  HeaderSection() {
    Row() {
      CommonHeader({
        title: '求职经历',
        backgroundColorParam: '#fff',
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
      })
    }.padding({ left: 16 })
  }

  @Builder
  TitleSection() {
    Column() {
      Text('求职经历')
        .fontSize(24)
        .fontColor('#333333')
        .fontWeight(FontWeight.Bold)
        .width('100%')

      Text('当前求职记录仅自己可见，招聘者无法查看您的求职经历/投递过的其他职位')
        .fontSize(14)
        .fontColor('#999999')
        .lineHeight(20)
        .margin({ top: 8 })
        .width('100%')
    }
    .padding(16)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#fff')
  }

  @Builder
  TabStatistics() {
    Row() {
      ForEach(this.jobAppData.tabList, (item: TabItem, index: number) => {
        Column() {
          Text(item.num.toString())
            .fontSize(20)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)

          Text(item.text)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })

          Row()
            .width(40)
            .height(3)
            .backgroundColor('#5B6FFF')
            .borderRadius(2)
            .margin({ top: 8 })
            .opacity(this.selectedTab === index ? 1 : 0)
        }
        .layoutWeight(1)
        .padding({ top: 16, bottom: 16 })
        .onClick(() => {
          this.selectedTab = index;
        })
      }, (item: TabItem) => JSON.stringify(item))
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  CommunicatedTab() {
    List({ space: 12 }) {
      ForEach(getCommunicatedPositions(), (item: PositionInfo) => {
        ListItem() {
          PositionCard({ positionInfoData: item })
            .onClick(() => {
              phoneRouterControl.jumpPage({
                pageName: RouterMap.POSITION_DETAIL_PAGE,
                param: {
                  content: item.id,
                  isSheet: false,
                } as ProtocolRouterParams,
                builder: wrapBuilder(PositionDetailPageBuilder),
              })
            })
        }
      }, (item: PositionInfo) => item.id)
    }
    .layoutWeight(1)
    .padding({ top: 12, left: 16, right: 16 })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
  }

  @Builder
  AppliedTab() {
    Row() {
      ForEach(this.progressTab, (item: string) => {
        Column() {
          Text(`${item}(${item === this.progressTab[0] ? getAppliedPositions().length : 0})`)
            .fontSize(12)
            .fontColor(this.progressCurrent === item ? '#FF564AF7' : '#E5000000')
        }
        .width('48%')
        .height(32)
        .backgroundColor('#FFFFFFFF')
        .borderStyle(BorderStyle.Solid)
        .borderWidth(1)
        .borderColor(this.progressCurrent === item ? '#FF564AF7' : '#1A000000')
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.progressCurrent = item
        })
      }, (item: string) => item)
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left: 16, right: 16 }).margin({ top: 8 })

    if (this.progressCurrent === this.progressTab[0]) {
      List({ space: 12 }) {
        ForEach(getAppliedPositions(), (item: PositionInfo) => {
          ListItem() {
            PositionCard({ positionInfoData: item })
              .onClick(() => {
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.DELIVERY_PROGRESS_PAGE,
                  param: {
                    content: item.id,
                    isSheet: false,
                  } as ProtocolRouterParams,
                  builder: wrapBuilder(DeliveryProgressPageBuilder),
                })
              })
          }
        }, (item: PositionInfo) => item.id)
      }
      .layoutWeight(1)
      .padding({ top: 12, left: 16, right: 16 })
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
  }

  @Builder
  InterviewTab() {
    List({ space: 12 }) {
      ForEach(getAppliedPositions(), (item: PositionInfo) => {
        ListItem() {
          InterviewCard({ positionInfoData: item })
            .onClick(() => {
              phoneRouterControl.jumpPage({
                pageName: RouterMap.PENDING_INTERVIEW_PAGE,
                param: {
                  content: item.id,
                  isSheet: false,
                } as ProtocolRouterParams,
                builder: wrapBuilder(PendingInterviewPageBuilder),
              })
            })
        }
      }, (item: PositionInfo) => item.id)
    }
    .layoutWeight(1)
    .padding({ top: 12, left: 16, right: 16 })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
  }

  @Builder
  FavoritesTab() {
    Row() {
      ForEach(this.favoritesTab, (item: string) => {
        Column() {
          Text(item)
            .fontSize(12)
            .fontColor(this.favoritesCurrent === item ? '#FF564AF7' : '#E5000000')
        }
        .width('48%')
        .height(32)
        .backgroundColor('#FFFFFFFF')
        .borderStyle(BorderStyle.Solid)
        .borderWidth(1)
        .borderColor(this.favoritesCurrent === item ? '#FF564AF7' : '#1A000000')
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.favoritesCurrent = item
        })
      }, (item: string) => item)
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left: 16, right: 16 }).margin({ top: 8 })

    if (this.favoritesCurrent === '职位') {
      List({ space: 12 }) {
        ForEach(getFavoritePositions(), (item: PositionInfo) => {
          ListItem() {
            PositionCard({ positionInfoData: item })
              .onClick(() => {
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.POSITION_DETAIL_PAGE,
                  param: {
                    content: item.id,
                    isSheet: false,
                  } as ProtocolRouterParams,
                  builder: wrapBuilder(PositionDetailPageBuilder),
                })
              })
          }
        }, (item: PositionInfo) => item.id)
      }
      .layoutWeight(1)
      .padding({ top: 12, left: 16, right: 16 })
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    } else if (this.favoritesCurrent === '公司') {
      List({ space: 12 }) {
        ForEach(getFavoriteCompanies(), (item: CompanyInfo) => {
          ListItem() {
            CompanyCard({ companyInfoData: item })
              .onClick(() => {
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.COMPANY_DETAIL_PAGE,
                  param: {
                    content: item.id,
                    isSheet: false,
                  } as ProtocolRouterParams,
                  builder: wrapBuilder(CompanyDetailPageBuilder),
                })
              })
          }
        }, (item: CompanyInfo) => item.id)
      }
      .layoutWeight(1)
      .padding({ top: 12, left: 16, right: 16 })
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }
  }

  build() {
    NavDestination() {
      Column() {
        this.HeaderSection()

        Column() {
          this.TitleSection()
          this.TabStatistics()

          if (this.selectedTab === 0) {
            this.CommunicatedTab()
          }

          if (this.selectedTab === 1) {
            this.AppliedTab()
          }

          if (this.selectedTab === 2) {
            this.InterviewTab()
          }

          if (this.selectedTab === 3) {
            this.FavoritesTab()
          }
        }
        .layoutWeight(1)
        .backgroundColor('#F8F8F8')
      }
      .width('100%')
      .height('100%')
      .padding({
        top: BarVM.instance.staBarH,
        bottom: BarVM.instance.aiBarH
      })
    }
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
    .hideTitleBar(true)
    .onShown(() => {
      this.jobAppData.updateData()
    })
    .onReady((context: NavDestinationContext) => {
      const params = context.pathInfo.param as ProtocolRouterParams;
      if (params && params.content) {
        this.selectedTab = Number(params.content);
      }
    })
  }
}
