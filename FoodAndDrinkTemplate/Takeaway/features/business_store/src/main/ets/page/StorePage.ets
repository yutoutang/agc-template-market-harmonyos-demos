import { CommonConfirmDialog, CommonConstants, RouterMap, RouterUtils, singleClick } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { StorePageViewModel } from '../viewModels/StorePageVM';
import { STORE_TABS } from '../common/Constants';
import { CommentListView } from 'module_store_comments';
import { CouponItem, CouponsServiceApi, MyCar, StoreEnum, StoreServiceApi } from 'lib_takeaway_api';
import { StoreGoodsListComp } from '../components/StoreGoodsListComp';
import { MyCarListComp } from '../components/MyCarListComp';
import { MemberGrade } from 'lib_takeaway_api/src/main/ets/database/AuthorType';
import { LoginSheetUtils } from 'lib_account';

@Builder
export function buildStorePage() {
  StorePage()
}

@ComponentV2
export struct StorePage {
  @Local vm: StorePageViewModel = new StorePageViewModel();
  @Provider() storeCar: MyCar = AppStorageV2.connect(MyCar, () => new MyCar())!;
  @Local commonCouponList: CouponItem[] = [];

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '店铺详情',
        onBack: () => {
          this.vm.customBack();
        },
      })
      Stack() {
        Column() {
          // 店铺基本信息
          this.buildStoreBasicInfo()
          // 店铺Tabs
          Tabs({ barPosition: BarPosition.Start, index: this.vm.currentIndex, controller: this.vm.tabController }) {
            ForEach(STORE_TABS, (item: string, index: number) => {
              TabContent() {
                // 点餐
                if (index === 0) {
                  StoreGoodsListComp({
                    vm: this.vm
                  })
                } else if (index === 1) {
                  // 评价
                  CommentListView({
                    updateCommentTotal: (totalNum: number) => {
                      this.vm.convertCommentTotalStr(totalNum)
                    },
                    windowBottomPadding: this.vm.windowModel.windowBottomPadding
                  })
                } else if (index === 2) {
                  // 商家
                  this.buildIntroduceStore()
                }
              }
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
              .tabBar(this.buildTabBarItem(item, index))
              .layoutWeight(1)
              .align(Alignment.Top)
              .width($r('app.string.size_percent_full'))
              .padding({
                left: index === 0 ? 0 : CommonConstants.PADDING_S,
                right: index === 0 ? 0 : CommonConstants.PADDING_S,
              })
            }, (item: string) => item)

          }
          .width($r('app.string.size_percent_full'))
          .layoutWeight(1)
          .vertical(false)
          .barHeight(42)
          .animationDuration(0)
          .barMode(BarMode.Fixed)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .onChange((index) => {
            this.vm.changeTab(index)
          })
        }

        // 店铺购物车列表
        MyCarListComp({
          close: () => {
            this.vm.showCarList = false
          },
          vm: this.vm
        }).visibility(this.vm.showCarList ? Visibility.Visible : Visibility.None)

        // 店铺购物车结算按钮
        this.buildCartRow()
      }
      .layoutWeight(1)
      .alignContent(Alignment.Bottom)

    }
    .hideTitleBar(true)
    .onReady((context) => {
      const storeId = context.pathInfo.param as string | undefined
      if (storeId) {
        // 初始化店铺信息
        this.vm.initStore(storeId)
        this.storeCar =
          this.storeCar = this.vm.myCar.myCar.find((item) => item.storeId === this.vm.storeId) || new MyCar()
        this.commonCouponList =
          CouponsServiceApi.getByStoreType(this.vm.storeInfo ? this.vm.storeInfo.type : StoreEnum.ALL)
        StoreServiceApi.addBrowsingHistory(storeId)
      }
    })
    .onShown(() => {
      this.vm.initStore(this.vm.storeId)
      this.storeCar =
        this.storeCar = this.vm.myCar.myCar.find((item) => item.storeId === this.vm.storeId) || new MyCar()
      this.commonCouponList =
        CouponsServiceApi.getByStoreType(this.vm.storeInfo ? this.vm.storeInfo.type : StoreEnum.ALL)
      StoreServiceApi.addBrowsingHistory(this.vm.storeId)
    })
    .linearGradient({
      colors: [['#FFF17D00', 0], ['#F1F3F5', 0.3]],
    })
  }

  @Builder
  buildCartRow() {
    // 购物车
    Row() {
      Row() {
        Badge({
          count: this.vm.storeCar?.num ? this.vm.storeCar.num : 0,
          style: {
            color: $r('sys.color.font_on_primary'),
            fontWeight: 500,
            fontSize: 10,
            badgeColor: $r('sys.color.warning'),
            borderColor: '#FE5509',
          },
          position: BadgePosition.RightTop,
        }) {
          Image(this.vm.storeCar && this.vm.storeCar?.num > 0 ? $r('app.media.cart_yellow') : $r('app.media.cart_gray'))
            .width(40)
            .objectFit(ImageFit.Fill);
        }
        .width(44);
      }
      .onClick(() => {
        if (this.vm.storeCar && this.vm.storeCar?.num > 0) {
          this.vm.showCarList = !this.vm.showCarList;
        }
      })
      .width(44)
      .height(44)
      .margin({
        right: CommonConstants.PADDING_S
      });

      Column() {
        Text(`￥${this.vm.storeCar?.money.toFixed(2) || 0}`)
          .fontColor('#121212')
          .fontSize(16)
          .fontWeight(500);
        Text(`需配送费${this.vm.storeInfo?.deliveryFee || 0}元/可自提`)
          .fontColor('#909399')
          .fontSize(11)
          .fontWeight(400);
      }
      .height(44)
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center);

      Button(this.vm.storeCar && this.vm.storeCar?.num > 0 ? '去结算' : '1元起送')
        .width(90)
        .height(40)
        .backgroundColor(this.vm.storeCar && this.vm.storeCar?.num > 0 ? $r('app.color.theme_color') : $r('sys.color.icon_fourth'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_on_primary'))
        .onClick(singleClick(() => {
          let onPop: Callback<PopInfo> = (pop: PopInfo) => {
            this.vm.initStore(this.vm.storeId)
            this.storeCar =
              this.storeCar = this.vm.myCar.myCar.find((item) => item.storeId === this.vm.storeId) || new MyCar()
            this.commonCouponList =
              CouponsServiceApi.getByStoreType(this.vm.storeInfo ? this.vm.storeInfo.type : StoreEnum.ALL)
          }
          this.vm.submitClick(onPop)
        }))

    }
    .alignItems(VerticalAlign.Top)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      top: 8,
      left: 16,
      right: 15,
    })
    .border({
      width: {
        top: 0.5
      },
      color: '#EBEBEB'
    })
    .visibility(this.vm.currentIndex === 0 ? Visibility.Visible : Visibility.None)
    .width(CommonConstants.FULL_WIDTH)
    .height(60 + this.vm.windowModel.windowBottomPadding / 2)
    .backgroundColor($r('app.color.font_color_level1_invert'))
  }

  @Builder
  buildIntroduceStore() {
    Column({ space: CommonConstants.SPACE_L }) {
      Column({ space: CommonConstants.SPACE_XXXL }) {
        Row({ space: 20 }) {
          Text('商家名称')
            .majorTextStyle()
            .width(64);
          Text(this.vm.storeInfo?.name)
            .commonTextStyle()
            .layoutWeight(1);
        }
        .alignItems(VerticalAlign.Top)
        .width(CommonConstants.FULL_PERCENT);

        Row({ space: 20 }) {
          Text('商家地址')
            .majorTextStyle()
          // .width(64);
          Text(this.vm.storeInfo?.address)
            .commonTextStyle()
            .layoutWeight(1);

        }
        .width(CommonConstants.FULL_PERCENT)
        .alignItems(VerticalAlign.Top);

        Row({ space: 20 }) {
          Text('营业时间')
            .majorTextStyle()
            .width(64);
          Text(this.vm.storeInfo?.openTime)
            .commonTextStyle()
            .layoutWeight(1);

        }
        .alignItems(VerticalAlign.Top)
        .width(CommonConstants.FULL_PERCENT);

      }
      .width(CommonConstants.FULL_PERCENT)
      .padding({
        left: CommonConstants.PADDING_M,
        right: CommonConstants.PADDING_M,
        top: CommonConstants.PADDING_XL,
        bottom: CommonConstants.PADDING_XL,
      })
      .height(184)
      .borderRadius(CommonConstants.BORDER_RADIUS_12)
      .backgroundColor($r('app.color.background_color_white'));

      Column({ space: CommonConstants.SPACE_S }) {
        Text('商家介绍')
          .majorTextStyle()
          .width(CommonConstants.FULL_PERCENT);
        Text(this.vm.storeInfo?.introduction)
          .commonTextStyle(TextAlign.JUSTIFY)
          .width(CommonConstants.FULL_PERCENT);
      }
      .justifyContent(FlexAlign.Start)
      .padding({
        left: CommonConstants.PADDING_M,
        right: CommonConstants.PADDING_M,
        top: CommonConstants.PADDING_XL,
        bottom: CommonConstants.PADDING_XL,
      })
      .borderRadius(CommonConstants.BORDER_RADIUS_12)
      .backgroundColor($r('app.color.background_color_white'));

    }
    .width(CommonConstants.FULL_PERCENT)
    .layoutWeight(1)
  }

  /**
   * 店铺基本信息
   */
  @Builder
  buildStoreBasicInfo() {
    Column({ space: CommonConstants.SPACE_L }) {
      // 店铺信息
      Row({ space: CommonConstants.SPACE_L }) {
        // 店铺图片
        Image($r(`app.media.${this.vm.storeInfo?.coverUrl}`))
          .width(70)
          .height(70)
          .borderRadius(CommonConstants.BORDER_RADIUS_6)

        // 店铺信息
        Column({ space: CommonConstants.SPACE_S }) {
          // 店铺名称和是否关注
          Row() {
            Text(this.vm.storeInfo?.name)
              .majorTextStyle()
              .layoutWeight(1)

            Image(this.vm.isFollow ? $r('app.media.store_follow') : $r('app.media.un_store_follow'))
              .width(16)
              .onClick(singleClick(() => {
                this.vm.clickFollow()
              }))
          }
          .height(19)

          // 评分和月销量
          Row() {
            Image($r('app.media.ic_star_yellow'))
              .width(12)
            Text(this.vm.storeInfo?.score.toString())
              .fontSize(11)
              .fontWeight(FontWeight.Regular)
              .fontColor('#888888')
              .margin({
                left: 2,
                right: 10
              })

            Text(`月销${this.vm.storeInfo?.monthlySales}`)
              .fontColor('#888888')
              .fontWeight(FontWeight.Regular)
              .fontSize(11)
          }
          .width(CommonConstants.FULL_PERCENT)

          // 配送时间
          Row() {
            Text(`配送时间 约${this.vm.storeInfo?.deliveryTime}分钟`)
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .fontColor('#888888')
          }
          .margin({
            top: 8
          })
          .width(CommonConstants.FULL_PERCENT)

        }
        .layoutWeight(1)
      }
      .height(70)

      // 优惠卷
      Row({ space: 6 }) {
        ForEach(this.commonCouponList, (item: CouponItem) => {
          Row() {
            Column() {
              Text('¥' + item.amountRule.discountAmount)
                .fontSize(12)
                .fontWeight(400)
                .fontColor('#8F3706')
                .width('100%')
            }
            .layoutWeight(1)
            .padding({ left: 10 })
            .alignItems(HorizontalAlign.Start)

            Column() {
              if (this.vm.userInfoModel.myCouponList.find(value => value === item.couponID)) {
                Text('已领')
                  .fontSize(12)
                  .fontWeight(400)
                  .fontColor('#8F3706')
              } else {
                Text(item.receiveStatus === '0' ? '领取' : '已领')
                  .fontSize(12)
                  .fontWeight(400)
                  .fontColor('#8F3706')
                  .onClick(() => {
                    if (!this.vm.userInfoModel.isLogin) {
                      LoginSheetUtils.open()
                      return
                    }
                    if (item.receiveStatus === '0') {
                      if (this.checkMemberGrade()) {
                        this.vm.userInfoModel.myCouponList.push(item.couponID)
                        item.receiveStatus = '1'
                        promptAction.showToast({ message: '已成功领取' })
                      } else {
                        CommonConfirmDialog.show({
                          primaryTitle: '',
                          content: '黄金会员可领取',
                          priBtnV: '取消',
                          secBtnV: '查看会员等级',
                          confirm: () => {
                            RouterUtils.pushPathByName(RouterMap.MINE_MEMBER_CENTER);
                          },
                        })
                      }
                    }
                  })
              }
            }.width(38)
            .alignItems(HorizontalAlign.Center)
          }
          .borderRadius(4)
          .justifyContent(FlexAlign.SpaceBetween)
          .height(22)
          .width(80)
          .backgroundImage($r('app.media.store_coupon'))
          .backgroundImageSize({ width: '100%', height: '100%' })
        })
      }
      .height(22)
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Start)
    }
    .height(132)
    .padding({
      left: 10,
      right: 10,
      top: 18,
      bottom: 10
    })
    .margin({
      left: 6,
      right: 6,
      bottom: 6
    })
    .borderRadius(CommonConstants.BORDER_RADIUS_12)
    .backgroundColor(Color.White)
  }

  @Builder
  buildTabBarItem(name: string, index: number) {
    Column() {
      Text() {
        Span(name)
        if (index === 1) {
          Span(this.vm.commentTotalStr)
            .fontSize($r('app.string.font_size_10'))
            .fontColor($r('app.color.common_color_second'));
        }
      }
      .fontColor(this.vm.currentIndex === index ? $r('app.color.theme_color_third') :
      $r('app.color.icon_color_grey_light'))
      .fontSize($r('app.float.font_size_14'))
      .fontWeight(this.vm.currentIndex === index ? 500 : 400)
      .lineHeight(22)
      .fontStyle(FontStyle.Normal)
      .margin({ top: $r('app.float.space_s'), bottom: $r('app.float.space_xs') });

      Row()
        .height(2)
        .width(15)
        .linearGradient({
          colors: [[$r('app.color.app_theme'), 0], [$r('app.color.orange_yellow'), 1]],
        })
        .borderRadius($r('app.float.border_radius_capsule'))
        .opacity(this.vm.currentIndex === index ? 1 : 0);
    }
    .height(40)
    .width(CommonConstants.FULL_PERCENT)
    .linearGradient({
      colors: [['#FFFDF9', 0], ['#F1F3F5', 1]],
    })
    .padding({
      left: $r('app.float.space_m'),
      right: $r('app.float.space_m'),
    })
  }

  checkMemberGrade(): boolean {
    if (this.vm.userInfoModel.authorMemberGrade === MemberGrade.LV1) {
      return false
    }
    return true
  }
}

@Extend(Text)
function majorTextStyle() {
  .fontSize(CommonConstants.FONT_SIZE_16)
  .fontColor('#333333')
  .fontWeight(500)
  .fontStyle(FontStyle.Normal)
  .textAlign(TextAlign.Start)
}

@Extend(Text)
function commonTextStyle(textAlign: TextAlign = TextAlign.End) {
  .fontSize(CommonConstants.FONT_SIZE_16)
  .fontColor('#999999')
  .fontWeight(400)
  .fontStyle(FontStyle.Normal)
  .textAlign(textAlign)
}