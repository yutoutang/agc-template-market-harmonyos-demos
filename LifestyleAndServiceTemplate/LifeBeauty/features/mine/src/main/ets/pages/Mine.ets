import { AppStorageV2, CircleShape, PersistenceV2 } from '@kit.ArkUI';
import { common, Configuration, EnvironmentCallback } from '@kit.AbilityKit';
import { i18n } from '@kit.LocalizationKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import {
  CommonConstants,
  getGoodList,
  GetUserInfoResp,
  GoodCard,
  GoodInfo,
  GoodListInfo,
  CommonUtils,
  LoginButton,
  PopViewUtils,
  RouterMap,
  RouterModule,
  unbindPhone,
  BreakpointModel,
  closeLoading,
  BreakpointNameEnum,
} from 'foundation';
import { MineIconLabel } from '../components/MineIconLabel';
import { APPOINTMENT_MENUS, MineIconLabelItem } from '../common/Constant';

const TAG = '[Mine]';

@Extend(Column)
function barColumnStyle() {
  .width(CommonConstants.FULL_PERCENT)
  .padding({ left: 12, right: 12, top: 24, bottom: 16 })
  .alignItems(HorizontalAlign.Start)
  .backgroundColor(Color.White)
  .borderRadius(16)
}

@ComponentV2
export struct Mine {
  @Local goodList: GoodListInfo[] = [];
  @Local isRefreshing: boolean = false;
  @Local userInfo: GetUserInfoResp = PersistenceV2.connect(GetUserInfoResp, () => new GetUserInfoResp())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  // 注册订阅系统环境变化的ID
  private callbackId: number = 0;
  // 系统语言
  @Local systemLanguage: string = '';

  subscribeConfigurationUpdate(): void {
    // 获取系统当前语言
    this.systemLanguage = this.context.config.language || i18n.System.getFirstPreferredLanguage();

    // 1.获取ApplicationContext
    let applicationContext = this.context.getApplicationContext();

    // 2.通过applicationContext订阅环境变量变化
    let environmentCallback: EnvironmentCallback = {
      onConfigurationUpdated: (newConfig: Configuration) => {
        if (this.systemLanguage !== newConfig.language) {
          this.systemLanguage = newConfig.language || '';
        }
      },
      onMemoryLevel: (level) => {
      },
    }
    try {
      this.callbackId = applicationContext.on('environment', environmentCallback);
    } catch (err) {
      Logger.error(TAG, 'applicationContext.on(environment error: ' + JSON.stringify(err));
    }
  }

  unsubscribeConfigurationUpdate() {
    let applicationContext = this.context.getApplicationContext();
    try {
      applicationContext.off('environment', this.callbackId);
    } catch (err) {
      Logger.error(TAG, 'applicationContext.off(environment error: ' + JSON.stringify(err));
    }
  }

  @Monitor('userInfo.mobile')
  onChangeMobile() {
    PopViewUtils.closePopView()
  }

  aboutToAppear(): void {
    this.getGoodList();
  }

  getGoodList() {
    getGoodList().then((resp) => {
      this.goodList = resp as GoodListInfo[];
    })
  }

  isBindPhone() {
    return this.userInfo?.mobile !== '';
  }

  @Computed
  get userName() {
    return this.userInfo.nickName || $r('app.string.default_user_name');
  }

  @Computed
  get pointLabel() {
    if (this.userInfo.points) {
      return this.userInfo.points.toString();
    }
    return '0';
  }

  @Computed
  get memberLabel() {
    if (this.userInfo.memberId) {
      return '1';
    }
    return '0';
  }

  @Computed
  get maskPhoneNumber() {
    // 手机号脱敏
    if (this.userInfo.mobile) {
      return this.userInfo.mobile.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2');
    }
    return ''
  }

  @Computed
  get waterFlowLanes() {
    let lanesValue = 2
    switch (this.breakPointModel.currentBreakpoint) {
      case BreakpointNameEnum.SM:
        lanesValue = 2;
        break;
      case BreakpointNameEnum.MD:
        lanesValue = 4;
        break;
      case BreakpointNameEnum.LG:
      case BreakpointNameEnum.XL:
        lanesValue = 5;
        break;
    }

    return lanesValue
  }

  jumpToAppointment(url: string, state?: number) {
    RouterModule.push({ url: url, param: state });
  }

  @Builder
  WaterFlowBuilder() {
    WaterFlow() {
      ForEach(this.goodList[0].goods, (good: GoodInfo) => {
        FlowItem() {
          GoodCard({ goodInfo: good })
        }
        .width(CommonConstants.FULL_PERCENT)
      }, (v: GoodInfo) => JSON.stringify(v))
    }
    .cachedCount(10)
    .columnsTemplate(`repeat(${this.waterFlowLanes}, 1fr)`)
    .columnsGap(10)
    .rowsGap(6)
    .width(CommonConstants.FULL_PERCENT)
    .scrollBar(BarState.Off)
  }

  build() {
    NavDestination() {
      Column() {
        // 标题
        this.titleBuilder()
        Scroll() {
          Column({space: 12}) {
            // 用户信息
            this.UserBar()
            // 我的预约
            this.MyAppointmentBar()
            // 服务与工具
            this.ServiceBar()

            Column({ space: 8 }) {
              if (this.goodList.length) {
                Text('为您推荐')
                  .fontSize(18).fontWeight(700)
                  .width('100%').textAlign(TextAlign.Start)
                this.WaterFlowBuilder()
              }
            }
            .padding({ top: 16, bottom: 16 })
          }
          .padding({
            left: this.breakPointModel.pagePadding,
            right: this.breakPointModel.pagePadding,
          })
        }
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
        .width(CommonConstants.FULL_PERCENT)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.common_page_bg'))
  }

  @Builder
  titleBuilder() {
    Text('我的')
      .fontSize(26)
      .fontWeight(700)
      .padding({ left: 16 })
      .height(56)
      .alignSelf(ItemAlign.Start)
  }

  @Builder
  linkAccountBuilder() {
    Row({space: 4}) {
      SymbolGlyph(this.isBindPhone() ? $r('sys.symbol.link_slash') : $r('sys.symbol.link'))
        .fontSize(18)
        .fontColor([this.isBindPhone() ? Color.White : $r('sys.color.font_primary')])
      Text(this.isBindPhone() ? '取消关联' : '关联账户')
        .fontSize(14)
        .fontColor(this.isBindPhone() ? Color.White : $r('sys.color.font_primary'))
    }
    .padding({left: 8, right: 8, top: 4, bottom: 4})
    .backgroundColor(this.isBindPhone() ? '#E64566' : $r('sys.color.comp_background_tertiary'))
    .justifyContent(FlexAlign.Center)
    .borderRadius(20)
    .onClick(() => {
      if (this.isBindPhone()) {
        unbindPhone();
      }
    })
  }

  @Builder
  UserBar() {
    Row() {
      Image(CommonUtils.handleImgUrl(this.userInfo.avatar) || $r('app.media.ic_user_default'))
        .width(48)
        .height(48)
        .clipShape(new CircleShape({ width: 48, height: 48 }))
        .margin({right: 16})
        .onClick(() => {
          if (this.isBindPhone()) {
            RouterModule.push({ url: RouterMap.MY_PERSONAL_INFO });
          }
        })
      if (this.isBindPhone()) {
        Column({ space: 4 }) {
          Row({ space: 4 }) {
            Text(this.userName)
              .fontSize(18)
              .fontWeight(500)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .constraintSize({ maxWidth: 150 })
              .onClick(() => {
                RouterModule.push({ url: RouterMap.MY_PERSONAL_INFO });
              })

            if (this.userInfo.memberId) {
              Image($r('app.media.ic_member'))
                .width(24)
                .padding({ left: 4, right: 4 })
            }
          }
          Row({space: 8}) {
            Image($r('app.media.ic_public_mobilephone'))
              .width(16)
              .height(16)

            Text(this.maskPhoneNumber)
              .fontSize(12)
              .fontWeight(400)
          }
        }.alignItems(HorizontalAlign.Start).layoutWeight(1)
      } else {
        Text($r('app.string.default_user_name')).fontSize(18).fontWeight(500)
      }

      Blank()

      Column() {
        LoginButton({
          btnSize: { width: 92, height: 28 },
          showLoginBtn: this.userInfo?.mobile === '',
          contentView: () => {
            this.linkAccountBuilder()
          }
        })
      }
      .alignSelf(ItemAlign.Stretch)
      .justifyContent(FlexAlign.End)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({ left: 12, right: 12, top: 16, bottom: 16 })
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  @Builder
  appointAllBuilder() {
    Row({space: 4}) {
      Text('全部').fontSize(14).fontColor($r('sys.color.font_secondary'))
      SymbolGlyph($r('sys.symbol.chevron_right')).fontSize(22).fontColor([$r('sys.color.icon_tertiary')])
    }
    .onClick(() => {
      this.jumpToAppointment(RouterMap.MY_APPOINTMENT_LIST, 0);
    })
  }

  @Builder
  appointItemBuilder(item: MineIconLabelItem) {
    MineIconLabel({
      icon: item.icon,
      label: item.label,
      routeUrl: item.routeUrl,
      routeParam: item.routeParam,
    })
  }

  @Builder
  MyAppointmentBar() {
    Column({space: 16}) {
      Row() {
        Text('我的预约').fontSize(18).fontWeight(700)
        Blank()
        LoginButton({
          btnSize: { width: 60, height: 20 },
          isEffect: false,
          showLoginBtn: this.userInfo?.mobile === '',
          onBind: () => {
            // 关闭关联账户时的loading
            closeLoading();
            this.jumpToAppointment(RouterMap.MY_APPOINTMENT_LIST, 0);
          },
          contentView: () => {
            this.appointAllBuilder()
          }
        })
      }
      .width(CommonConstants.FULL_PERCENT)

      Row() {
        ForEach(APPOINTMENT_MENUS, (item: MineIconLabelItem) => {
          LoginButton({
            btnSize: { width: 36, height: 56 },
            isEffect: false,
            showLoginBtn: this.userInfo?.mobile === '',
            onBind: () => {
              // 关闭关联账户时的loading
              closeLoading();
              this.jumpToAppointment(item.routeUrl, item.routeParam as number);
            },
            contentView: () => {
              this.appointItemBuilder(item)
            }
          })
        }, (item: MineIconLabelItem) => JSON.stringify(item))
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceAround)
    }
    .barColumnStyle()
  }

  @Builder
  ServiceBar() {
    Column({space: 16}) {
      Text('服务与工具').fontSize(18).fontWeight(700).alignSelf(ItemAlign.Start)
      Row() {
        LoginButton({
          btnSize: { width: 36, height: 56 },
          isEffect: false,
          showLoginBtn: this.userInfo?.mobile === '',
          onBind: () => {
            // 关闭关联账户时的loading
            closeLoading();
            this.jumpToAppointment(RouterMap.MY_SINGLE_VISIT_LIST);
          },
          contentView: () => {
            this.appointItemBuilder({
              icon: $r('app.media.ic_bar_single_card'),
              label: '次卡',
              routeUrl: RouterMap.MY_SINGLE_VISIT_LIST,
              iconSize: { width: 32, height: 32 }
            } as MineIconLabelItem)
          }
        })

        LoginButton({
          btnSize: { width: 36, height: 56 },
          isEffect: false,
          showLoginBtn: this.userInfo?.mobile === '',
          onBind: () => {
            // 关闭关联账户时的loading
            closeLoading();
            this.jumpToAppointment(RouterMap.MY_GROUP_LIST);
          },
          contentView: () => {
            this.appointItemBuilder({
              icon: $r('app.media.ic_bar_group'),
              label: '团购',
              routeUrl: RouterMap.MY_GROUP_LIST,
              iconSize: { width: 32, height: 32 }
            } as MineIconLabelItem)
          }
        })
      }
      .width('50%')
      .justifyContent(FlexAlign.SpaceAround)
    }
    .barColumnStyle()
  }
}
