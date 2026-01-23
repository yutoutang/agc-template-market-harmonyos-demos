import { Title } from '../uicomponents/Title';
import { GlobalContext } from '../utils/GlobalContext';
import { User, VideoCardDetail, VideoDetail, VipRecord } from '@ohos_agcit/children_education_datasource';
import { display } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { TimeControl } from './common/util/TimeControl';
import { LogUtil } from '../utils/LogUtil';
import { CommonConstants } from '../constants/CommonConstants';
import { historyRecord } from './PlayControl';
import { MovieItem, PlayerComponent } from 'recorded_player';
import { SharePicker } from 'aggregated_share';
import { QuickLoginUtil } from '../quicklogin/QuickLoginUtil';
import { FinishStatus, MemberList, MemberParams, MemberSheetUtils,
  PRIVACY_CONTENT,
  ProductInfo, ProductsInfoOptions,
  PRODUCTS_INFO } from 'membership';
import { iap } from '@kit.IAPKit';
import { DateUtil } from '../utils/DateUtil';
import { DateConstants } from '../constants/DateConstants';


@ComponentV2
export struct VideoPlayPage {
  private videoDetailInfo = GlobalContext.getContext().getObject(CommonConstants.GLOBAL_VIDEO_LIST) as VideoDetail;
  private uiContext: UIContext = this.getUIContext() as UIContext;
  private hostContext: common.UIAbilityContext = this.uiContext.getHostContext() as common.UIAbilityContext;
  private windowClass = this.hostContext.windowStage.getMainWindowSync();
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Consumer(CommonConstants.USER_INFO) user: User = new User();
  @Consumer(CommonConstants.VIP_RECORD) userVipRecord: VipRecord = new VipRecord();
  @Local title: string = '';
  @Local index: number = 0;
  @Local totalTime: number = 0;
  @Local currentTime: number = 0;
  @Local aspect: number = 9 / 16; // default video height/width ratio value
  @Local xComponentWidth: number = this.getUIContext().px2vp(display.getDefaultDisplaySync().width);
  @Local xComponentHeight: number = this.getUIContext().px2vp(display.getDefaultDisplaySync().width * this.aspect);
  @Local isShowVip: boolean = false;
  @Local isLayoutFullScreen: boolean = false; // 是否横屏状态
  private videoInfo: VideoCardDetail = {
    id: '',
    cardId: '',
    title: '',
    imageUrl: '',
    videoNumber: 0,
    iconUrl: '',
    videoUrl: '',
    isVip: false,
  };
  shareEvent = () => {
    const picker = new SharePicker({
      title: this.videoInfo.title,
      coverUrl: this.videoInfo.imageUrl
    });
    picker.show();
  };

  aboutToAppear(): void {
    this.windowClass.on('windowSizeChange', (size) => {
      let viewWidth = this.getUIContext().px2vp(size.width);
      let viewHeight = this.getUIContext().px2vp(size.height);
      if (viewWidth > viewHeight) {
        this.xComponentWidth = viewHeight / this.aspect;
        this.xComponentHeight = viewHeight;
        this.isLayoutFullScreen = true;
        this.windowClass.setSpecificSystemBarEnabled('navigationIndicator', false);
      } else {
        this.xComponentHeight = viewWidth * this.aspect;
        this.xComponentWidth = viewWidth;
        this.windowClass.setSpecificSystemBarEnabled('navigationIndicator', true);
        this.isLayoutFullScreen = false;
      }
    });
  }

  setOrientation(orientation: number) {
    this.windowClass.setPreferredOrientation(orientation).then(() => {
      LogUtil.info('setWindowOrientation: ' + orientation + ' Succeeded.');
    }).catch((err: BusinessError) => {
      LogUtil.info('setWindowOrientation: ' + orientation + ' Failed. Cause: ' + JSON.stringify(err));
    });
  }

  aboutToDisappear(): void {
    this.isLayoutFullScreen = false;
  }

  build() {
    NavDestination() {
      Column() {
        Stack() {
          Column() {
            if (this.videoInfo.isVip && !this.userVipRecord.isVip) {
              VipPrompt(
                {
                  isLayoutFullScreen: this.isLayoutFullScreen,
                  xComponentWidth: this.xComponentWidth,
                  xComponentHeight: this.xComponentHeight,
                  shareEvent: this.shareEvent
                }
              )
            } else {
              PlayerComponent({
                movieItems: [new MovieItem('01', this.videoInfo.title, 0, this.videoInfo.videoUrl)],
                playerIndex: 0,
                fullScreen: (isLayoutFullScreen: boolean) => {
                  this.isLayoutFullScreen = isLayoutFullScreen
                },
                exitEvent: () => this.appPathStack.pop(),
                shareEvent: this.shareEvent,
                callbackTimeUpdate: (nol: number, total: number) => {
                  // 播放完成
                  if (nol === total) {

                  }
                }
              })
                .width('100%')
                .height(this.isLayoutFullScreen ? '100%' : 'auto')
                .clip(true)
            }
          };
        }
        .width(CommonConstants.FULL_PERCENT)
        .height(this.isLayoutFullScreen ? CommonConstants.FULL_PERCENT :
          this.xComponentHeight + (AppStorage.get<number>('statusBarHeight') ?? 0))
        .backgroundColor(Color.Black)
        .padding({ top: this.isLayoutFullScreen ? 0 : (AppStorage.get<number>('statusBarHeight') || 0) });


        Row() {
          Text(this.videoInfo.title)
            .fontSize(16)
            .fontWeight(500)
            .lineHeight(21)
        }
        .padding({ left: 16 })
        .height(48)
        .width(CommonConstants.FULL_PERCENT)

        Blank()
          .height(8)
          .width(CommonConstants.FULL_PERCENT)
          .backgroundColor($r('sys.color.background_secondary'));

        VideoCollection({
          globalVideoList: this.videoDetailInfo.videoCardDetailList,
        })
      };
    }
    .onReady((cxt: NavDestinationContext) => {
      let detail = cxt.pathInfo.param as VideoCardDetail;
      this.videoInfo.id = detail.id
      this.videoInfo.cardId = detail.cardId
      this.videoInfo.title = detail.title
      this.videoInfo.imageUrl = detail.imageUrl
      this.videoInfo.iconUrl = detail.iconUrl
      this.videoInfo.videoUrl = detail.videoUrl
      this.videoInfo.videoNumber = detail.videoNumber
      this.videoInfo.isVip = detail.isVip
    })
    .onHidden(() => {
    })
    .onShown(() => {
      if (TimeControl.timeControl(this.uiContext)) {
        this.appPathStack.pop();
        return;
      }
    })
    .hideTitleBar(true)
    .title(Title(this.videoInfo.title))
    .onBackPressed(() => {
      historyRecord(this.videoDetailInfo, this.videoInfo.videoNumber - 1);
      this.appPathStack.pop();
      return true;
    });
  }
}

@ComponentV2
struct VipPrompt {
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Consumer(CommonConstants.USER_INFO) user: User = new User();
  @Consumer(CommonConstants.VIP_RECORD) vipRecord: VipRecord = new VipRecord();
  @Param isLayoutFullScreen: boolean = false
  @Param xComponentWidth: number = 0
  @Param xComponentHeight: number = 0
  @Param shareEvent: () => void = () => {
  }
  // 购买会员商品结果回调函数
  private subscribeEvent = async (params: MemberParams): Promise<void> => {
    this.getUIContext().getPromptAction().showToast({ message: this.getSubscribeMsg(params) });
    if (params.type === iap.ProductType.NONRENEWABLE && params.status === FinishStatus.FINISHED) {

      let validTimeTmp = DateUtil.getTodayStr(DateConstants.DATE_FORMAT4);

      if (params.productId === '20254') {
        validTimeTmp = DateUtil.getAmountDayStr(validTimeTmp, 365, DateConstants.DATE_FORMAT4);
      } else if (params.productId === '20253') {
        validTimeTmp = DateUtil.getAmountDayStr(validTimeTmp, 92, DateConstants.DATE_FORMAT4);
      } else {
        validTimeTmp = DateUtil.getAmountDayStr(validTimeTmp, 31, DateConstants.DATE_FORMAT4);
      }

      let vipRecord: emitter.EventData = {
        data: {
          'isVip': true,
          'validTime': validTimeTmp,
        },
      };
      emitter.emit(CommonConstants.VIP_RECORD, vipRecord);

      this.queryExpireTime(params.productId, params.purchaseTime, validTimeTmp);
    }
  };
  // 查询用户开通的会员种类列表，沙盒场景下，已发货状态的非消耗型商品订单信息不返回
  private ownedMemberEvent = async (list: MemberList): Promise<void> => {
    if (list.renewList.length || list.nonRenewList.length) {
      this.getUIContext().getPromptAction().showToast({ message: `您已拥有会员` });
    }
  };
  // 购买非周期订阅商品后从开发者服务器查询商品到期时间
  private queryExpireTime = (productId: string, time?: number, validTime?: string): Promise<void> => {
    // 请求开发者服务器获取非周期订阅商品到期时间（涉及商品id、购买次数）
    return new Promise(() => {
      if (validTime !== undefined) {
        this.vipRecord.validTime = validTime
      }
    });
  };

  private getSubscribeMsg(param: MemberParams) {
    let message = '';
    if (param.status === FinishStatus.FINISHED) {
      message = '会员订阅成功';
    } else if (param.status === FinishStatus.UNFINISHED) {
      message = `会员订阅失败，订阅错误码为${param.errCode}，错误原因为${param.errMsg}`;
    }
    return message;
  }

  private readonly productsInfo: ProductsInfoOptions = {
    isSheet: true,
    themeColor: $r('app.color.color_member'),
    btnFontColor: $r('sys.color.font_on_primary'),
    linearColors: [['#FFFFFF', 0.0], ['#F5F1E5', 0.0], ['#F1D1A5', 1.0]],
    productsInfo: PRODUCTS_INFO,
    privacyContent: PRIVACY_CONTENT,
    lastPurchaseProductExpireTime: this.vipRecord.validTime,
    subscribeCallBack: this.subscribeEvent,
    queryExpireTime: this.queryExpireTime,
    ownedMemberCallBack: this.ownedMemberEvent,
  };

  build() {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(40)
            .height(40)
            .fill($r('sys.color.comp_background_tertiary'))

          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_on_primary')])
        }
        .margin({ left: 16, top: 8 })
        .onClick(() => {
          this.appPathStack.pop();
        })

        Stack({ alignContent: Alignment.Center }) {
          Circle()
            .width(40)
            .height(40)
            .fill($r('sys.color.comp_background_tertiary'))

          SymbolGlyph($r('sys.symbol.share'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_on_primary')])
        }
        .margin({ right: 16, top: 8 })
        .onClick(() => {
          this.shareEvent()
        })
      }
      .height(56)
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)

      Text('该视频内容为VIP会员专享，查看请先开通会员')
        .fontSize(14)
        .fontColor(Color.White)
        .lineHeight(19)

      Blank().height(12)

      Button('开通会员')
        .width(this.isLayoutFullScreen ? 120 : 90)
        .aspectRatio(2.57)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .backgroundColor('#D3B685')
        .borderRadius(14)
        .onClick(() => {
          if (!this.user.isLogin) {
            QuickLoginUtil.getQuickLoginAnonymousPhone(this.getUIContext(), this.appPathStack)
            return
          }
          // 半模态弹窗
          MemberSheetUtils.open(this.productsInfo, this.getUIContext());
        })

      Blank().height(12)

      if (!this.user.isLogin) {
        Text('已是会员？点击登录查看')
          .fontSize(14)
          .fontColor('#D3B685')
          .onClick(() => {
            QuickLoginUtil.getQuickLoginAnonymousPhone(this.getUIContext(), this.appPathStack)
          })
      }
    }
    .width(this.xComponentWidth)
    .height(this.xComponentHeight)
    .backgroundColor($r('sys.color.comp_foreground_primary'))
    .zIndex(1)
    .visibility(Visibility.Visible);
  }
}

@ComponentV2
struct VideoCollection {
  @Param @Once @Require globalVideoList: Array<VideoCardDetail>;
  @Consumer(CommonConstants.APP_PATH_STACK) appPathStack: NavPathStack = new NavPathStack();
  @Consumer(CommonConstants.USER_INFO) user: User = new User();
  @Consumer(CommonConstants.VIP_RECORD) vipRecord: VipRecord = new VipRecord();

  build() {
    Column() {
      Row() {
        Text('选集')
          .fontWeight(FontWeight.Bold)
          .fontSize(24);
      }
      .margin({
        top: 20,
        left: 10,
      })
      .alignSelf(ItemAlign.Start);

      List({ space: '16vp' }) {
        ForEach(this.globalVideoList, (item: VideoCardDetail) => {
          ListItem() {
            VideoCardDetailItem({
              title: item.title,
              imageUrl: item.imageUrl,
              isVip: item.isVip,
            });
          }
          .padding({
            left: '4%',
            right: '4%',
          })
          .onClick(() => {
            if (!item.isVip) {
              let pathInfo: NavPathInfo = new NavPathInfo(CommonConstants.VIDEO_PLAY_PAGE, item);
              this.appPathStack.replacePath(pathInfo, true);
              return
            }
            let pathInfo: NavPathInfo = new NavPathInfo(CommonConstants.VIDEO_PLAY_PAGE, item);
            this.appPathStack.replacePath(pathInfo, true);
          });
        }, (item: VideoCardDetail) => JSON.stringify(item));
      }
      .scrollBar(BarState.Off)
      .width(CommonConstants.FULL_PERCENT)
      .lanes(2)
      .alignListItem(ListItemAlign.Center)
      .padding({
        top: 20,
      });
    }
    .padding({
      left: '3%',
      right: '3%',
    });
  }
}

@ComponentV2
struct VideoCardDetailItem {
  @Param @Require title: string;
  @Param @Require imageUrl: string;
  @Param @Require isVip: boolean;

  build() {
    Column({ space: 10 }) {
      Stack({ alignContent: Alignment.TopStart }) {
        Image(this.imageUrl)
          .aspectRatio(1.78)
          .borderRadius(10);
        Image(this.isVip ? $r('app.media.icon_vip_top_start') : $r('app.media.icon_free_top_start'))
          .width('20%');
      };

      Text(this.title)
        .fontWeight(FontWeight.Medium)
        .fontSize(16);
    }
    .alignItems(HorizontalAlign.Start);
  }
}