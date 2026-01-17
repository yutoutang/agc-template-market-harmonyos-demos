import { AppStorageV2, curves, SymbolGlyphModifier, window } from '@kit.ArkUI';
import { bundleManager, common } from '@kit.AbilityKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { SelectStore, SelectStoreController, StoreCard, StoreInfo } from 'select_store';
import { BreakpointModel, RouterModule, StoreInfoModel, UIEmpty } from 'foundation';

@Builder
export function SelectStorePageBuilder() {
  SelectStorePage()
}

const TAG = '[SelectStorePage]'

@ComponentV2
struct SelectStorePage {
  @Local storeInfoList: Array<StoreInfo> = [];
  @Local packageName: string = ''
  @Local topPadding: number = 38.77;
  @Local storeModel: StoreInfoModel = AppStorageV2.connect(StoreInfoModel, () => new StoreInfoModel())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  // 控制弹出的搜索页的显隐
  @Local isSearchPageShow: boolean = false;
  // 在转场时设置非空值，在转场完成后设置为空字符串
  @Local geometryId: string = '';
  // 记录动画计数，用来在onFinish判断是否还有后续的接续动画，有的话就不在onFinish里设值，否则会有跳变问题
  @Local animationCount: number = 0;
  // 控制蒙板的上下树，在点击卡片和返回主页动画之外，需要保持蒙板下树，否则可能会一直绘制全屏大小的Column引起性能问题
  @Local isMaskEnabled: boolean = false;
  // 门店选择控制器
  @Local selectStoreController: SelectStoreController = new SelectStoreController()
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
    // 开启全屏模式沉浸页面
    this.setWindowLayoutFullScreen(true);
    // 获取顶部避让高度
    this.getTopPadding()
    // 获取应用包名
    this.getPackageName()
    this.storeInfoList = this.storeModel.storeList.map((item) => {
      const store = new StoreInfo();
      store.id = item.id.toString();
      store.name = item.storeName;
      store.address = item.address;
      store.time1 = '08:00';
      store.time2 = '20:00';
      store.tel = item.mobile;
      store.coordinates = item.coords;
      store.distanceStr = item.distance ?? '0m'
      return store;
    })
  }

  private async setWindowLayoutFullScreen(isLayoutFullScreen: boolean): Promise<void> {
    try {
      const win: window.Window = await window.getLastWindow(this.context);
      await win.setWindowLayoutFullScreen(isLayoutFullScreen);
    } catch (e) {
      UtilLog.error(TAG, `Failed to set window layout. ${JSON.stringify(e)}`)
    }
  }

  async getTopPadding() {
    try {
      const win: window.Window = await window.getLastWindow(this.context);
      const area = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      this.topPadding = this.getUIContext().px2vp(area.topRect.height);
    } catch (e) {
      UtilLog.error(TAG, `Failed to get window avoid area. ${JSON.stringify(e)}`)
    }
  }

  getPackageName() {
    try {
      let bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE |
      bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_ABILITY |
      bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_REQUESTED_PERMISSION);
      this.packageName = bundleInfo.name;
    } catch (err) {
      UtilLog.error(TAG, `Failed to get package name. ${JSON.stringify(err)}`)
    }
  }

  onStartAnimate(isSearchPageShow: boolean) {
    this.geometryId = 'search';
    // 每次动画前将计数+1
    let animationCount = ++this.animationCount;
    this.getUIContext().animateTo({
      curve: curves.interpolatingSpring(0, 1, 342, 38),
      onFinish: () => {
        // 如果相等说明本次动画后没有接续的动画，可以做动画结束的处理，将geometryId设为空字符串
        if (animationCount === this.animationCount) {
          this.geometryId = '';
          // 整体动画结束后再隐藏蒙板，如果在200ms的动画结束后就隐藏，这个动画还没结束，会有跳变效果
          this.isMaskEnabled = false;
        }
      }
    }, () => {
      this.isSearchPageShow= isSearchPageShow;
    });
    // 添加蒙板的透明度动画
    this.isMaskEnabled = true;
    this.getUIContext().animateTo({
      duration: 200,
      curve: curves.cubicBezierCurve(0.33, 0, 0.67, 1)
    }, () => {
    });
  }

  onSearchClick() {
   this.onStartAnimate(true)
  }

  cancelSearch() {
    this.onStartAnimate(false)
  }

  build() {
    NavDestination() {
      Stack() {
        SelectStore({
          storeInfoList: this.storeInfoList,
          storeId: this.storeModel.storeId,
          controller: this.selectStoreController,
          packageName: this.packageName,
          geometryId: this.geometryId,
          onSearchClick: () => {
            this.onSearchClick()
          },
          selectedStore: (storeId: string) => {
            this.storeModel.storeId = storeId;
            RouterModule.pop();
          },
        })
        HeaderView({
          pagePadding: this.breakPointModel.pagePadding,
          topPadding: this.topPadding,
          onBack: () => {
            this.selectStoreController.closeSheet();
            RouterModule.pop();
          }
        })
      }.alignContent(Alignment.TopStart)
    }
    .hideTitleBar(true)
    .onShown(() => {
    })
    .onWillDisappear(() => {
      // 关闭全屏模式
      this.setWindowLayoutFullScreen(false);
    })
    .bindContentCover($$this.isSearchPageShow, this.SearchPageBuilder(), {
      modalTransition: ModalTransition.NONE,
      // 添加返回逻辑，否则侧滑退出会有问题,
      onWillDismiss: ((dismissAction: DismissContentCoverAction) => {
        if (dismissAction.reason === DismissReason.PRESS_BACK) {
          this.cancelSearch()
        }
        dismissAction.dismiss();
      }),
    })
  }

  @Builder
  SearchPageBuilder() {
    Column() {
      Row() {
        HeaderView({
          title: '搜索门店',
          pagePadding: this.breakPointModel.pagePadding,
          topPadding: this.topPadding,
          onBack: () => {
            this.cancelSearch()
          }
        })
      }
      StoreSearchPage({
        geometryId: this.geometryId,
        storeInfoList: this.storeInfoList,
        packageName: this.packageName,
        onSelectStore: (id: string) => {
          this.storeModel.storeId = id;
          this.cancelSearch();
        }
      })
    }
    .backgroundColor($r('sys.color.background_primary'))
    .width('100%')
    .height('100%')
    .transition(TransitionEffect.opacity(0))
  }
}

@ComponentV2
struct HeaderView {
  @Param title: string = ''
  @Param pagePadding: number = 16;
  @Param topPadding: number = 38.77;
  @Event onBack: () => void = () => {
    RouterModule.pop()
  }

  build() {
    Row({space: 10}) {
      Button() {
        SymbolGlyph($r('sys.symbol.chevron_backward'))
          .fontSize(24)
          .fontColor([$r('sys.color.icon_primary')])
      }
      .width(40).height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.onBack();
      })

      if (this.title) {
        Text(this.title)
          .fontSize(20)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(700)
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: this.pagePadding })
    .margin({ top: this.topPadding })
  }
}


@ComponentV2
struct StoreSearchPage {
  @Param geometryId: string = '';
  @Param packageName: string = '';
  @Param storeInfoList: StoreInfo[] = [];
  @Event onSelectStore: (storeId: string) => void = (storeId: string) => {}
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local searchStoreList: StoreInfo[] = [];
  @Local searchValue: string = '';
  @Local isShowEmpty: boolean = false;

  build() {
    Column() {
      Row() {
        Search({ placeholder: '搜索',value: this.searchValue })
          .geometryTransition(this.geometryId)
          .focusable(true)
          .defaultFocus(true)
          .focusable(true)
          .cancelButton({
            style: CancelButtonStyle.CONSTANT,
            icon: new SymbolGlyphModifier($r('sys.symbol.xmark')).fontColor([$r('sys.color.icon_secondary')])
          })
          .onChange((value: string) => {
            if (value) {
              this.searchStoreList = this.storeInfoList.filter((item: StoreInfo) => item.name.includes(value));
              this.isShowEmpty = this.searchStoreList.length === 0;
            } else {
              this.searchStoreList = [];
              this.isShowEmpty = false;
            }
          })
      }
      .width('100%')
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })

      if (this.searchStoreList.length) {
        List({ space: 12 }) {
          ForEach(this.searchStoreList, (item: StoreInfo, index: number) => {
            ListItem() {
              StoreCard({ storeInfo: item, packageName: this.packageName })
                .onClick(() => {
                  this.onSelectStore(item.id)
                })
            }
          }, (item: StoreInfo) => item.id)
        }
        .width('100%')
        .padding({
          left: this.breakPointModel.pagePadding,
          right: this.breakPointModel.pagePadding
        })
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      } else {
        Column() {
          UIEmpty({
            emptyDesc: '没有符合条件的内容',
            emptyIcon: $r('app.media.ic_search_empty'),
            imgSize: { width: 120, height: 120 }
          })
        }
        .height('80%')
        .justifyContent(FlexAlign.Center)
        .visibility(this.isShowEmpty ? Visibility.Visible : Visibility.None)
      }
    }
    .width('100%')
    .layoutWeight(1)
  }
}