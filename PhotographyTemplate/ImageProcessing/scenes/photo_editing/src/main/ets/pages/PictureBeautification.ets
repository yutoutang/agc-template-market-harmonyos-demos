import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { iap } from '@kit.IAPKit';
import { RouterModule, RouterMap, WaterMark } from 'commonlib';
import { UserInfoRouter } from 'mine';
import { BeautyActionBar } from '../components/BeautyActionBar';
import { ImageProcessingUtil } from '../util/ImageProcessingUtil';
import { StickerModel } from '../model/BeautificationParam';
import { StickerComponent } from '../components/StickerComponent';
import { AddTextComponent } from '../components/AddTextComponent';
import { MosaicComponent } from '../components/MosaicComponent';
import { BeautyParam } from '../model/PageParams';
import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM';
import { DiscardDialog } from '../components/DiscardDialog';
import {
  FinishStatus,
  MemberList,
  MemberParams,
  MemberSheetUtils,
  MemberStatusUtil,
  ProductsInfoOptions,
} from 'membership';
import { WATERMARK_WIDTH } from '../constant/Constants';

@Builder
export function PictureBeautificationBuilder() {
  PictureBeautification();
}

@ComponentV2
export struct PictureBeautification {
  @Local isEdit: boolean = true;
  vm: PhotoBeautificationVM = PhotoBeautificationVM.instance;
  userInfoRouter: UserInfoRouter = UserInfoRouter.instance;
  ownedMemberEvent = async (list: MemberList): Promise<void> => {
    if (list.renewList.length || list.nonRenewList.length) {
      this.userInfoRouter.isVip = true;
      this.getUIContext().getPromptAction().showToast({ message: `您已拥有会员` });
    } else {
      this.userInfoRouter.isVip = false;
    }
  };
  discardDialogController: CustomDialogController = new CustomDialogController({
    builder: DiscardDialog(),
    alignment: DialogAlignment.Center,
    autoCancel: true, // 允许点击蒙层关闭
  });
  @Local lastPurchaseProductExpireTime: string = '';
  queryExpireTime = (productId: string, time?: number): Promise<void> => {
    // 请求开发者服务器获取非周期订阅商品到期时间（涉及商品id、购买次数）
    return new Promise(() => {
      // todo 替换自已的到期时间
      this.lastPurchaseProductExpireTime = '2026-08-01';
    });
  };
  // 通用会员组件
  subscribeEvent = async (params: MemberParams): Promise<void> => {
    this.getUIContext().getPromptAction().showToast({ message: '会员订阅成功' });
    if (params.type === iap?.ProductType.NONRENEWABLE && params.status === FinishStatus.FINISHED) {
      this.queryExpireTime(params.productId, params.purchaseTime);
    }
  };
  productsInfo: ProductsInfoOptions = {
    isSheet: true,
    themeColor: '#8981F7',
    linearColors: [['#C1BDF8', 0.5], ['#F1A5F0', 1.0]],
    btnFontColor: $r('sys.color.font_on_primary'),
    // todo: 替换为您配置的商品ID及对应的权益
    productsInfo: [
      {
        type: iap?.ProductType?.NONRENEWABLE,
        productId: '20253',
        privileges: [
          {
            id: 'privilege_1',
            icon: $r('app.media.privilege'),
            title: '海量素材资源，随意使用',
            des: '专属趣味贴纸，特殊文字',
          },
        ],
      },
      {
        type: iap?.ProductType?.NONRENEWABLE,
        productId: '20252',
        privileges: [
          {
            id: 'privilege_1',
            icon: $r('app.media.privilege'),
            title: '海量素材资源，随意使用',
            des: '专属趣味贴纸，特殊文字',
          },
        ],
      },
    ],
    privacyContent: '   欢迎您使用“xxxx”。“xxxx”采用收费与免费结合的方式。您须注册华为账号后，才能继续进行购买服务。通过购买程序支付费用后，您就可以使用会员所提供的收费服务。在开始购买程序之前，请您首先同意并接受以下服务条款。\n' +
      '   本协议是您与华为软件技术有限公司（以下统称“华为”）之间关于“xxxx"提供的各种付费服务签订的服务协议，描述了华为与xxxx付费服务用户之间关于软件许可以及服务使用及相关方面的权利义务。同意本协议，您可享受会员权益。 \n' +
      '   您同意本“xxxx"付费服务协议条款即表示同意遵守《xxxx用户协议》《关于xxxx与隐私的声明》（以下称“基础协议"），本协议未涉及事项以《xxxx用户协议》为准，若您拒绝接受本协议，不影响已同意的基础协议。 \n' +
      '   华为在此特别提醒，请事先仔细阅读本服务协议中各项条款，包括但不限于免除或者限制华为责任的免责条款以及对用户的权利限制条款。请您仔细审阅并决定接受或不接受本服务协议。',
    lastPurchaseProductExpireTime: '',
    subscribeCallBack: this.subscribeEvent,
    queryExpireTime: this.queryExpireTime,
    ownedMemberCallBack: this.ownedMemberEvent,
  };

  queryMemberStatus() {
    MemberStatusUtil.queryPurchase(this.getUIContext().getHostContext() as common.UIAbilityContext).then((res) => {
      let autoRenewPurchasedList = res.renewList;
      let nonAutoRenewPurchasedList = res.nonRenewList;
      if (autoRenewPurchasedList?.length || nonAutoRenewPurchasedList?.length) {
        this.userInfoRouter.isVip = true;
        this.getUIContext().getPromptAction().showToast({ message: '您已开通会员' });
      } else {
        MemberSheetUtils.open(this.productsInfo, this.getUIContext());
      }
    }).catch((err: BusinessError) => {
      hilog.error(0xFF00, 'MemberShip',
        `Failed to query purchase record. Code is ${err.code}, message is ${err.message}`);
    });
  }

  aboutToDisappear(): void {
    this.vm.pixelMapList = [];
  }

  getNavParam(ctx: NavDestinationContext) {
    // 清除滤镜名
    this.vm.filterName = '';
    let param = ctx?.pathInfo?.param as BeautyParam;
    this.vm.barIndex = param.barIndex;
    if (param.uris.length) {
      const uri = param.uris[0];
      if (param?.filterName) {
        this.vm.filterName = param.filterName;
      }
      this.vm.initData(uri);
    } else {
      if (param.pixelMap) {
        if (param?.filterName) {
          this.vm.filterName = param.filterName;
        }
        this.vm.pushPixelMap(param.pixelMap);
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        this.beautifyContentBuilder();
        BeautyActionBar()
          .margin({ top: 16 });
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor($r('sys.color.background_secondary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .layoutWeight(1);
    }
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onReady((ctx: NavDestinationContext) => {
      this.getNavParam(ctx);
    })
    .onBackPressed(() => {
      if (this.vm.totalPixelMapCount > 1) {
        this.discardDialogController.open();
        return true;
      } else {
        return false;
      }
    });
  }

  @Builder
  beautifyContentBuilder() {
    Column() {
      Row() {
        Image($r('app.media.chevron_left')).size({ width: 40, height: 40 }).onClick(() => {
          if (this.vm.totalPixelMapCount > 1) {
            this.discardDialogController.open();
          } else {
            RouterModule.pop();
          }
        });

        Row({ space: 10 }) {
          Row({ space: 10 }) {
            Image(this.vm.totalPixelMapCount > 1 && this.vm.currentPixelMapIndex !== 0 ?
              $r('app.media.ic_recall_enable') :
              $r('app.media.ic_recall_disable'))
              .height(40)
              .width(40)
              .onClick(() => {
                if (this.vm.currentPixelMapIndex !== 0) {
                  this.vm.currentPixelMapIndex--;
                  this.vm.currentPixelMap = this.vm.pixelMapList[this.vm.currentPixelMapIndex];
                  this.vm.getCurrentRatio();
                }
              });
            Image(this.vm.totalPixelMapCount - 1 !== this.vm.currentPixelMapIndex ? $r('app.media.ic_forward_enable') :
              $r('app.media.ic_forward_disable'))
              .height(40)
              .width(40)
              .onClick(() => {
                if (this.vm.currentPixelMapIndex !== this.vm.totalPixelMapCount - 1) {
                  this.vm.currentPixelMapIndex++;
                  this.vm.currentPixelMap = this.vm.pixelMapList[this.vm.currentPixelMapIndex];
                  this.vm.getCurrentRatio();
                }
              });
          };

          SaveButton({ icon: SaveIconStyle.FULL_FILLED, buttonType: ButtonType.Circle })
            .size({ width: 40, height: 40 })
            .iconColor($r('sys.color.font_primary'))
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .onClick(() => {
              ImageProcessingUtil.saveToAlbum('ImageContent', this.getUIContext());
            });
        };
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 12 })
      .visibility(this.vm.barIndex === -1 ? Visibility.Visible : Visibility.None);

      Stack() {
        Column() {
          Row({ space: 8 }) {
            Image($r('app.media.ic_wake'))
              .width(24);
            Text('会员专属效果，成为会员后可使用并保存')
              .fontSize(14)
              .fontColor(Color.White);
            Image($r('app.media.ic_to_vip'))
              .width(12)
              .height(24)
          }
          .width(328)
          .height(40)
          .backgroundColor($r('app.color.app_theme'))
          .borderRadius(20)
          .padding(8)
          .visibility(this.vm.showRemind && !this.userInfoRouter.isVip ? Visibility.Visible : Visibility.None)
          .onClick(() => {
            if (!this.vm.loginUser.isLogin) {
              RouterModule.push({ url: RouterMap.LOGIN_PAGE });
            } else {
              this.queryMemberStatus();
            }
          });
        }
        .width('100%')
        .position({ top: 30 })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .zIndex(10);


        Stack() {
          Image(this.vm.currentPixelMap);

          ForEach(this.vm.stickerList, (item: StickerModel) => {
            StickerComponent({ item: item, onDelete: this.vm.deleteSticker });
          }, (item: StickerModel) => item.id);

          if (this.vm.barIndex === 3 || this.vm.saveText) {
            AddTextComponent();
          }

          if (this.vm.barIndex === 4) {
            MosaicComponent();
          }


          if (this.vm.barIndex === 5) {
            Column() {
              WaterMark({ markId: this.vm.waterMarkId, isShowPosition: this.vm.isShowPosition }).margin(16);
            }
            .position({ bottom: 0 })
            .onAppear(() => {
              if (!this.vm.imageArea.width) {
                return;
              }
              if (this.vm.imageArea.width < WATERMARK_WIDTH) {
                this.getUIContext()
                  .getPromptAction()
                  .showToast({ message: '当前可能导致水印截断，您可以通旋转、裁剪等方式调整图片后再次添加水印' });
              }
            });
          }

        }.id('ImageContent')
        .aspectRatio(this.vm.rotateRatio ? this.vm.rotateRatio : this.vm.ratio)
        .onAreaChange(async (_value: Area, newVal: Area) => {
          // 获取图片位置xy
          const x = Math.round(newVal.position.x as number);
          const y = Math.round(newVal.position.y as number);
          const width = newVal.width as number;
          const height = newVal.height as number;
          this.vm.imageArea = {
            x: x,
            y: y,
            width: width,
            height: height,
          };

          this.vm.clipRect = {
            x: x,
            y: y,
            width: width,
            height: height,
          };
        });

        // 蒙层
        Canvas(this.vm.maskContext)
          .position({
            x: this.vm.imageArea.x,
            y: this.vm.imageArea.y,
          })
          .width(this.vm.imageArea.width)
          .height(this.vm.imageArea.height)
          .visibility(this.vm.barIndex === 1 && this.vm.carouselCutTabIndex === 0 ? Visibility.Visible :
            Visibility.None);
        // 裁剪框
        Canvas(this.vm.cropContext)
          .position({
            x: this.vm.clipRect.x - 2,
            y: this.vm.clipRect.y - 2,
          })
          .width(this.vm.clipRect.width! + 4)
          .height(this.vm.clipRect.height! + 4)
          .visibility(this.vm.barIndex === 1 && this.vm.carouselCutTabIndex === 0 ? Visibility.Visible :
            Visibility.None)
          .onReady(() => {
            this.vm.drawClipImage(this.getUIContext());
          })
          .onTouch(event => {
            if (event.type === TouchType.Down) {
              this.vm.isMove(event.target.area, event.touches[0]);
              this.vm.touchPosition = {
                x: event.touches[0].displayX,
                y: event.touches[0].displayY,
              };
            } else if (event.type === TouchType.Move) {
              let moveX = event.changedTouches[0].displayX - this.vm.touchPosition.x;
              let moveY = event.changedTouches[0].displayY - this.vm.touchPosition.y;
              this.vm.touchPosition = {
                x: event.changedTouches[0].displayX,
                y: event.changedTouches[0].displayY,
              };
              if (this.vm.cropRatio === 0) {
                this.vm.moveClipCanvasFreeType(moveX, moveY);
              } else {
                this.vm.moveClipCanvasRatioType(moveX, moveY);
              }
            }
          });

        Image($r('app.media.switch'))
          .width(40)
          .height(40)
          .position({ bottom: 16, right: 16 })
          .visibility(this.vm.barIndex === -1 ? Visibility.Visible : Visibility.None)
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.vm.currentPixelMapIndex = 0;
              this.vm.currentPixelMap = this.vm.pixelMapList[this.vm.currentPixelMapIndex];
              this.vm.getCurrentRatio();
            } else if (event.type === TouchType.Up) {
              this.vm.currentPixelMapIndex = this.vm.totalPixelMapCount - 1;
              this.vm.currentPixelMap = this.vm.pixelMapList[this.vm.currentPixelMapIndex];
              this.vm.getCurrentRatio();
            }
          });
      }
      .width('100%')
      .layoutWeight(1);

    }.padding({ left: 16, right: 16 }).layoutWeight(1);
  }
}