import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { LoginPageBuilder, ProtocolRouterParams } from 'aggregated_login';
import {
  CompanyInfo,
  TValueType,
  getCompanyById,
  CommonHeader,
  JobApplicationData,
  BarVM,
  UserInfo,
  RouterMap
} from 'common';
import { phoneRouterControl } from 'oh_router';

@Builder
export function CompanyDetailPageBuilder(params: TValueType) {
  CompanyDetailPage({
    pageParams: params
  })
}

@ComponentV2
export struct CompanyDetailPage {
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local jobAppData: JobApplicationData = AppStorageV2.connect(JobApplicationData, () => new JobApplicationData())!;
  @Param pageParams: TValueType = null;
  @Local companyData?: CompanyInfo;
  @Local isExpanded: boolean = false;
  @Local showAllAddresses: boolean = false;

  @Builder
  buildHeader() {
    Stack({ alignContent: Alignment.End }) {
      CommonHeader({
        title: '公司介绍',
        backgroundColorParam: '#fff',
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
      })

      Row({ space: 16 }) {
        Image(this.companyData?.isFavorite ? $r('app.media.collected_icon') : $r('app.media.collect_icon'))
          .width(24)
          .height(24)
          .onClick(() => {
            if (!this.userInfo?.isLogin) {
              phoneRouterControl.jumpPage({
                pageName: RouterMap.LOGIN_PAGE,
                builder: wrapBuilder(LoginPageBuilder)
              })
              return
            }
            if (this.companyData) {
              this.companyData.isFavorite = !this.companyData.isFavorite
              this.jobAppData.updateData()
            }
          })
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  buildCompanyBasicInfo() {
    Column() {
      Row() {
        Column() {
          Text(this.companyData?.companyName || 'XX软件技术有限公司')
            .fontSize(20)
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)

          Text(`${this.companyData?.companySize || '1000-9999人'}·${this.companyData?.industry || '互联网'}`)
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Row() {
          Text('logo')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width(64)
        .height(64)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')

      Row({ space: 24 }) {
        Row({ space: 8 }) {
          Image($r('app.media.time_icon'))
            .width(20)
            .height(20)
          Text('9:00-18:00')
            .fontSize(14)
            .fontColor('#666666')
        }

        Row({ space: 8 }) {
          Image($r('app.media.calendar_icon'))
            .width(20)
            .height(20)
          Text('双休')
            .fontSize(14)
            .fontColor('#666666')
        }
      }
      .width('100%')
      .margin({ top: 16 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
  }

  @Builder
  buildCompanyAddress() {
    Column() {
      Row() {
        Text('公司地址')
          .fontSize(16)
          .fontColor('#333333')
          .fontWeight(700)

        Blank()

        Row() {
          Text('全部地址')
            .fontSize(14)
            .fontColor('#999999')
          Image($r('sys.media.ohos_ic_public_arrow_right'))
            .width(16)
            .height(16)
            .fillColor('#999999')
            .margin({ left: 4 })
        }.onClick(() => {
          this.showAllAddresses = true
        })
      }
      .width('100%')

      Row({ space: 8 }) {
        Image($r('app.media.address_icon_red'))
          .width(16)
          .height(16)
          .fillColor('#FF6B6B')

        Text(`XX省XX市XX区${this.companyData?.companyName}`)
          .fontSize(14)
          .fontColor('#666666')
          .layoutWeight(1)
      }
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .margin({ top: 8 })
  }

  @Builder
  buildCompanyIntroduction() {
    Column() {
      Text('公司介绍')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(700)
        .width('100%')

      Text(this.getCompanyDescription())
        .fontSize(14)
        .fontColor('#666666')
        .lineHeight(24)
        .margin({ top: 12 })
        .maxLines(this.isExpanded ? 999 : 10)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Row() {
        Text(this.isExpanded ? '' : '查看更多')
          .fontSize(14)
          .fontColor('#5B6FFF')
          .margin({ top: 8 })
          .onClick(() => {
            this.isExpanded = !this.isExpanded;
          })
      }.width('100%').justifyContent(FlexAlign.End)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
  }

  @Builder
  buildBusinessInfo() {
    Column() {
      Text('工商信息')
        .fontSize(16)
        .fontColor('#333333')
        .fontWeight(700)
        .width('100%')

      Column({ space: 16 }) {
        this.InfoRow('公司全称', this.companyData?.companyName || 'XX软件技术有限公司')
        this.InfoRow('法人代表', '李XX')
        this.InfoRow('成立日期', '2000年10月20日')
        this.InfoRow('注册资本', '3000万元')
        this.InfoRow('统一社会信用代码', 'XXXXXXXXXXXXXXXXXX')
      }
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .margin({ bottom: 16 })
  }

  @Builder
  buildScrollContent() {
    Scroll() {
      Column() {
        this.buildCompanyBasicInfo()

        Divider()
          .strokeWidth('1px')
          .width('100%')
          .margin({ top: 5 })
          .padding({ left: 16, right: 16 })

        this.buildCompanyAddress()

        Divider()
          .strokeWidth('1px')
          .width('100%')
          .margin({ top: 3 })
          .padding({ left: 16, right: 16 })

        this.buildCompanyIntroduction()

        Divider()
          .strokeWidth('1px')
          .width('100%')
          .padding({ left: 16, right: 16 })

        this.buildBusinessInfo()
      }
      .width('100%')
    }
    .layoutWeight(1)
    .backgroundColor('#FFFFFF')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
  }

  build() {
    NavDestination() {
      Column() {
        this.buildHeader()
        this.buildScrollContent()
      }
      .width('100%')
      .height('100%')
      .padding({
        top: BarVM.instance.staBarH,
        bottom: BarVM.instance.aiBarH
      })
      .bindSheet($$this.showAllAddresses, this.AllAddressesBuilder(), {
        height: 200,
        showClose: false,
        title: this.sheetTitleBuilder,
        dragBar: true,
        backgroundColor: '#FFFFFF',
        onDisappear: () => {
          this.showAllAddresses = false;
        }
      })
    }
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      const params = context.pathInfo.param as ProtocolRouterParams;
      if (params && params.content) {
        const companyId = params.content;
        this.companyData = getCompanyById(companyId);
      }
    })
  }

  @Builder
  AllAddressesBuilder() {
    Column() {
      Text(`XX省XX市XX区${this.companyData?.companyName}`).fontSize(14).fontColor('rgba(0, 0, 0, 0.60)')
    }.width('100%').alignItems(HorizontalAlign.Start)
    .padding({ left: 16, right: 16, bottom: 20 })
    .margin({
      top: 20
    })
  }

  @Builder
  sheetTitleBuilder() {
    Row() {
      Text('全部地址').fontSize(20).fontColor('#000000')
        .fontWeight(700)
      Image($r('app.media.sheet_close'))
        .width(40)
        .height(40)
        .onClick(() => {
          this.showAllAddresses = false
        })
    }.width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)

  }

  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#999999')
        .width(60)

      Text(value)
        .fontSize(14)
        .fontColor('#333333')
        .layoutWeight(1)
        .padding({ left: 16 })
    }
    .width('100%')
  }

  getCompanyDescription(): string {
    return '一、我们是谁 (公司定位) [公司名称] 成立于[成立年份]，是一家专注于[具体业务领域，如：企业级SaaS解决方案、智能硬件研发、新能源' +
      '科技]的[公司类型，如：高新技术企业/行业领先的供应商]。我们以“[一句响亮的核心使命或愿景，如：用科技让工作更智能]”为使命，始终致力于为' +
      '客户提供[概括性价值，如：卓越的产品与全方位的服务]。 自成立以来，公司便扎根[核心业务赛道]，从最初的[初创阶段核心业务/规模]逐步成长为' +
      '[当前行业地位，如：区域标杆企业/国内细分领域头部服务商]，总部设于[总部地址]，并在[重点布局区域，如：华东、华南地区/海外某国家]设立了' +
      '分支机构与服务中心，形成了覆盖[服务辐射范围]的高效服务网络。 二、我们的业务 (核心产品/服务) 我们的核心业务围绕[具体产品/服务线一，如' +
      '：智能协同办公SaaS平台]、[产品/服务线二，如：企业数据安全防护系统]及[产品/服务线三，如：定制化数字化转型咨询]展开。通过[核心技术或' +
      '方法，如：自主研发的AI算法、创新的商业模式、国际一流的生产工艺]，我们成功为[目标客户群体，如：金融、教育、制造业等领域的客户]解决了' +
      '[客户面临的痛点或挑战，如：运营效率低下、数据管理混乱、数字化转型无明确方向]等核心问题，助力客户实现[客户价值，如：降本增效30%以上、' +
      '业务流程优化升级、核心数据安全可控]。 核心产品/服务详解 - [产品/服务线一名称]：作为公司的旗舰产品，该产品具备[核心功能1，如：多终' +
      '端实时协同]、[核心功能2，如：智能数据统计分析]、[核心功能3，如：灵活的定制化模块]等优势，区别于行业同类产品，我们创新性地融入了[差' +
      '异化技术/设计，如：基于客户行业场景的专属模板库]，目前已服务[该产品客户数量，如：超2000家]企业，客户复购率达[复购率数据，如：85%]' +
      '以上。 - [产品/服务线二名称]：聚焦[细分需求，如：企业数据全生命周期防护]，构建了从[前期环节，如：数据采集加密]到[中期环节，如：传' +
      '输存储防护]再到[后期环节，如：异常行为监测]的全链条服务体系，已通过[行业权威认证，如：ISO27001信息安全管理体系认证]，成为[目标行' +
      '业，如：金融机构]的优选合作方案。 三、我们的未来 (发展愿景) 未来，我们将继续以“[核心使命或愿景]”为指引，聚焦[核心发展方向，如：核' +
      '心技术迭代、新业务领域拓展、海外市场布局]三大重点。一方面，加大研发投入，重点攻克[技术难点， 我们坚信，通过持续的创新与诚信的经营，' +
      '将与更多客户、合作伙伴携手共进，共创行业新价值。';
  }
}