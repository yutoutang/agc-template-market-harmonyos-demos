import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { LoginPageBuilder, ProtocolRouterParams } from 'aggregated_login';
import { SharePicker } from 'aggregated_share';
import {
  BarVM,
  CommonHeader,
  getPositionById,
  JobApplicationData,
  PositionInfo,
  RouterMap,
  TValueType,
  updatePositionCommunicatedStatus,
  UserInfo
} from 'common';
import { phoneRouterControl } from 'oh_router';
import { CompanyDetailPageBuilder } from './CompanyDetailPage';
import { ChatJumpManager } from 'message';
import { ResumeSheetComponent } from 'file_management';
import { PositionInfoCard } from '../comp/PositionInfoCard';
import { PositionDescription } from '../comp/PositionDescription';

@Builder
export function PositionDetailPageBuilder(params: TValueType) {
  PositionDetailPage({
    pageParams: params
  })
}

@ComponentV2
export struct PositionDetailPage {
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local jobAppData: JobApplicationData = AppStorageV2.connect(JobApplicationData, () => new JobApplicationData())!;
  @Param pageParams: TValueType = null;
  @Local positionData?: PositionInfo;
  @Local isExpanded: boolean = false;
  @Local showResumeSheet: boolean = false;

  build() {
    NavDestination() {
      Column() {
        this.buildHeader()
        this.buildContent()
        this.buildBottomActions()
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
    .onReady((context: NavDestinationContext) => {
      this.handlePageReady(context);
    })
    .bindSheet($$this.showResumeSheet, this.ResumeSheetBuilder(), {
      height: 400,
      showClose: false,
      dragBar: true,
      backgroundColor: '#FFFFFF',
      onDisappear: () => {
        this.showResumeSheet = false;
      }
    })
  }

  @Builder
  buildHeader() {
    Stack({ alignContent: Alignment.End }) {
      CommonHeader({
        title: '职位详情',
        backgroundColorParam: '#fff',
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
      })

      Row({ space: 16 }) {
        this.buildFavoriteButton()
        this.buildShareButton()
      }.justifyContent(FlexAlign.End)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  buildFavoriteButton() {
    Image(this.positionData?.isFavorite ? $r('app.media.collected_icon') : $r('app.media.collect_icon'))
      .width(24)
      .height(24)
      .onClick(() => {
        this.handleFavoriteClick();
      })
  }

  @Builder
  buildShareButton() {
    Image($r('app.media.share_icon'))
      .width(24)
      .height(24)
      .onClick(() => {
        this.handleShareClick();
      })
  }

  @Builder
  buildContent() {
    Scroll() {
      Column() {
        this.buildPositionInfo()
        this.buildHRInfo()
        PositionDescription({
          descriptionTitleColor: 'rgba(0,0,0,0.6)'
        })
        this.buildCompanyInfo()
      }
      .width('100%')
    }
    .layoutWeight(1)
    .backgroundColor('#EFEFEF')
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
  }

  @Builder
  buildPositionInfo() {
    PositionInfoCard({
      jobTitle: this.positionData?.jobTitle,
      salary: this.positionData?.salary,
      location: this.positionData?.location,
      experience: this.positionData?.experience,
      education: this.positionData?.education,
    })
  }

  @Builder
  buildHRInfo() {
    Row() {
      Image($r('app.media.hr_avatar'))
        .width(40)
        .height(40)
        .borderRadius(20)

      Column() {
        Text(`${this.positionData?.hrName || '吴先生'}·${this.positionData?.hrTitle || 'HRBP'}`)
          .fontSize(16)
          .fontColor('#000000')
          .fontWeight(700)

        Text(this.positionData?.companyName || 'XX软件技术有限公司')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
  }

  @Builder
  buildCompanyInfo() {
    Row() {
      Row() {
        Text('logo')
          .fontSize(14)
          .fontColor('#999999')
      }
      .width(48)
      .height(48)
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)

      Column() {
        Text(this.positionData?.companyName || 'XX软件技术有限公司')
          .fontSize(16)
          .fontColor('#000000')
          .fontWeight(700)

        Text(`${this.positionData?.getCompanyInfo()?.companySize}·${this.positionData?.getCompanyInfo()?.industry}`)
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })

      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(24)
        .height(24)
        .fillColor('#CCCCCC')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .onClick(() => {
      this.handleCompanyClick();
    })
  }

  @Builder
  buildBottomActions() {
    Row({ space: 12 }) {
      this.buildApplyButton()
      this.buildChatButton()
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 12,
      bottom: 12
    })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  buildApplyButton() {
    Text(this.positionData?.isApplied ? '已投递' : '一键投递')
      .textAlign(TextAlign.Center)
      .fontSize(16)
      .fontColor(this.positionData?.isApplied ? 'rgba(0, 0, 0, 0.1)' : '#5B6FFF')
      .backgroundColor(this.positionData?.isApplied ? 'rgba(0, 0, 0, 0.1)' : '#E8EBFF')
      .layoutWeight(1)
      .height(48)
      .borderRadius(24)
      .onClick(() => {
        this.handleApplyClick();
      })
  }

  @Builder
  buildChatButton() {
    Text('立即沟通')
      .textAlign(TextAlign.Center)
      .fontSize(16)
      .fontColor('#FFFFFF')
      .backgroundColor('#5B6FFF')
      .layoutWeight(1)
      .height(48)
      .borderRadius(24)
      .onClick(() => {
        this.handleChatClick();
      })
  }

  private handleFavoriteClick() {
    if (!this.userInfo?.isLogin) {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.LOGIN_PAGE,
        builder: wrapBuilder(LoginPageBuilder)
      })
      return
    }
    if (this.positionData) {
      this.positionData.isFavorite = !this.positionData.isFavorite
      this.jobAppData.updateData()
    }
  }

  private handleShareClick() {
    if (!this.userInfo?.isLogin) {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.LOGIN_PAGE,
        builder: wrapBuilder(LoginPageBuilder)
      })
      return
    }
    const picker: SharePicker = new SharePicker({
      title: 'HarmonyOS官方模板集成创新活动',
    });
    picker.show();
  }

  private handleCompanyClick() {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.COMPANY_DETAIL_PAGE,
      param: {
        content: this.positionData?.companyId,
        isSheet: false,
      } as ProtocolRouterParams,
      builder: wrapBuilder(CompanyDetailPageBuilder),
    })
  }

  private handleApplyClick() {
    if (!this.userInfo?.isLogin) {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.LOGIN_PAGE,
        builder: wrapBuilder(LoginPageBuilder)
      })
      return
    }
    this.showResumeSheet = true;
  }

  private handleChatClick() {
    if (!this.userInfo?.isLogin) {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.LOGIN_PAGE,
        builder: wrapBuilder(LoginPageBuilder)
      })
      return
    }
    if (this.positionData?.hrUserId) {
      if (this.positionData) {
        updatePositionCommunicatedStatus(this.positionData.id)
        this.jobAppData.updateData();
      }
      ChatJumpManager.gotoC2CChatPage(this.positionData.hrUserId);
    } else {
    }
  }

  private handlePageReady(context: NavDestinationContext) {
    const params = context.pathInfo.param as ProtocolRouterParams;
    if (params && params.content) {
      const positionId = params.content;
      this.positionData = getPositionById(positionId);
    }
  }

  @Builder
  ResumeSheetBuilder() {
    ResumeSheetComponent({
      positionData: this.positionData,
      onClose: () => {
        this.showResumeSheet = false;
      },
      onUpdateJobData: () => {
        this.jobAppData.updateData();
      }
    })
  }
}