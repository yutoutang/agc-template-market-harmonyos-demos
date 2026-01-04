import { MapComponent } from '../components/MapComponent';
import { StopDetailView } from './StopDetailView';
import { SameStopDetailModel } from '../models/SameStopDetailModel';
import { StopDetailModel, StopLinesBundle } from '../models/StopDetailModel';
import { StopNavigation } from '../models/StopNavigation';
import { StopEventDispatcher } from '../utils/EventDispatcher';
import { PromptAction } from '@kit.ArkUI';
import { StopCommonConstants } from '../common/StopCommonConstants';
import { LineDetailModel } from '../line/models/LineDetailModel'
import { BusSubwaySetting } from '../line/models/BusSubwaySetting'

@ComponentV2
export struct MapStopDetailView {
  // 外部传入的初始参数
  @Param initialSiteId?: string = undefined
  @Param sameStopDetailModel: SameStopDetailModel = new SameStopDetailModel()
  @Param sameNameLinesMap?: Map<string, StopLinesBundle> = new Map<string, StopLinesBundle>()
  // 当前站点详情数据
  @Param @Require stopDetailModel: StopDetailModel
  // 收藏相关参数
  @Param collectionStationTags?: string[] = []
  // 还有多少站台需要提醒
  @Param arrivalReminderStations: number = 0
  @Event collectStation?: (tag: string) => void
  @Consumer() isStopDetailPanelVisible: boolean = true
  @Consumer() isFavoriteSheetVisible: boolean = false // 从父组件消费收藏弹窗显示状态
  @Event routeLineDetailPage: (lineDetailModel: LineDetailModel) => void
  @Event onFavoriteClick?: () => void // 收藏按钮点击事件用于登录校验
  @Event onInterceptLogin?: (cb: (isLogin: boolean) => void) => void // 登录拦截事件
  @Event addCollectionStopTag?: (tagName: string) => void
  @Param routerMap: NavPathStack = new NavPathStack()
  // 导航功能
  @Event onNavigate: (stopNavigation: StopNavigation) => void
  @Param setting: BusSubwaySetting = new BusSubwaySetting();
  @Local addTagName: string = ''
  promptAction: PromptAction = this.getUIContext().getPromptAction();
  private addTagDialogComponentId: number = 0;

  // 获取过滤后的收藏标签，只返回"家"和"公司"
  getFilteredCollectionTags(): string[] {
    let allTags = this.collectionStationTags || []
    let filteredTags = allTags.filter((tag: string) => tag === '家' || tag === '公司')
    return filteredTags.length > 0 ? filteredTags : ['家', '公司']
  }

  aboutToAppear(): void {
    StopEventDispatcher.interceptLogin = (cb: (isLogin: boolean) => void) => {
      if (this.onInterceptLogin) {
        this.onInterceptLogin(cb)
      }
    }
  }

  // 底部半模态内容
  @Builder
  bottomSheetContent() {
    StopDetailView({
      stopDetailModel: this.stopDetailModel,
      sameStopDetailModel: this.sameStopDetailModel,
      collectionStationTags: this.collectionStationTags,
      arrivalReminderStations: this.arrivalReminderStations,
      setting: this.setting,
      onNavigate: this.onNavigate,
      collectStation: (tag: string) => {
        if (this.collectStation) {
          this.collectStation(tag)
        }
      },
      routeLineDetailPage: this.routeLineDetailPage,
      onFavoriteClick: () => {
        if (this.onFavoriteClick) {
          this.onFavoriteClick()
        }
      }
    })
      .width('100%')
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: 16, topRight: 16 })
      .padding(12)
  }

  @Builder
  collectionSheet() {
    Column() {
      ForEach(this.collectionStationTags, (tag: string) => {
        Row() {
          if (tag === '家') {
            Image($r('app.media.collection_home'))
              .width(24)
              .height(24)
          } else if (tag === '公司') {
            Image($r('app.media.collection_company'))
              .width(24)
              .height(24)
          } else {
            Image($r('app.media.collection_other'))
              .width(24)
              .height(24)
          }
          Text(tag).fontColor(16).fontWeight(FontWeight.Medium)
            .margin({ left: 16 })
        }
        .justifyContent(FlexAlign.Start)
        .width(StopCommonConstants.FULL_PERCENT)
        .height(48)
        .onClick(() => {
          // 收藏站点
          if (this.collectStation) {
            this.collectStation(tag)
            // 立即更新UI状态
            this.stopDetailModel.isFavorited = true
          }
          this.isFavoriteSheetVisible = false
          this.promptAction.showToast({ message: '收藏成功' })
        })
      }, (v: string) => v)

      Row() {
        Image($r('app.media.collection_add'))
          .width(24)
          .height(24)
        Text('添加').fontColor(16).fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
      }
      .justifyContent(FlexAlign.Start)
      .width(StopCommonConstants.FULL_PERCENT)
      .height(48)
      .onClick(() => {
        this.promptAction.openCustomDialog({
          builder: () => {
            this.addTagDialog()
          },
          width: 328,
          height: 192,
          cornerRadius: 32,
          backgroundColor: 'C8FFFFFF'
        }).then((dialogId: number) => {
          this.addTagDialogComponentId = dialogId;
        })
      })
    }
    .padding({ left: 16, right: 16, bottom: 20 })
  }

  @Builder
  addTagDialog() {
    Column() {
      Text('添加标签')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .height(56)
        .lineHeight(24)

      TextInput({ text: $$this.addTagName, placeholder: '请输入标签名称' })
        .height(48)
        .margin({ top: 12 })
        .placeholderColor($r('sys.color.font_secondary'))
        .maxLength(20)
        .enterKeyType(EnterKeyType.Done)
        .backgroundColor($r('sys.color.comp_background_primary'))

      Row() {
        Row() {
          Text('取消')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .opacity(0.6)
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
        .onClick(() => {
          this.addTagName = ''
          this.promptAction.closeCustomDialog(this.addTagDialogComponentId)
        })

        Row() {
          Text('确定')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#0A59F7')
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
        .onClick(() => {
          if (this.addTagName === '') {
            this.promptAction.showToast({
              message: '请输入标签名称',
              duration: 1000
            })
          } else {
            if (this.addCollectionStopTag) {
              this.addCollectionStopTag(this.addTagName)
            }
            this.addTagName = ''
            this.promptAction.closeCustomDialog(this.addTagDialogComponentId)
          }
        })
      }
      .width('100%')
      .height(40)
      .margin({ top: 20 })
    }
    .padding({ left: 24, right: 24 })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        // 1. 地图层：占据整个背景
        MapComponent({
          sameStopDetailModel: this.sameStopDetailModel,
          stopDetailModel: this.stopDetailModel,
          showStopDetailPannel: () => {
            if (!this.isStopDetailPanelVisible) {
              this.isStopDetailPanelVisible = true
            }
          },
        })
      }
      .width('100%')
      .height('100%')
      .bindSheet($$this.isStopDetailPanelVisible, this.bottomSheetContent(), {
        enableOutsideInteractive: true,
        height: 350,
        preferType: SheetType.CENTER,
        showClose: false,
        onWillDismiss: (action: DismissSheetAction) => {
          // 禁止手势/外部/返回键导致的收起半模态
          if (action.reason === DismissReason.SLIDE_DOWN || action.reason === DismissReason.TOUCH_OUTSIDE) {
            return;
          }
          // 系统侧键关闭半模态
          if (action.reason === DismissReason.PRESS_BACK) {
            action.dismiss();
          }
        }
      })
      .gesture(
        // 解决长按存在长按属性的控件超过800ms，长按手势无对应事件响应
        LongPressGesture({ duration: 400 })
          .onAction(() => {
          })
      )
    }
    .bindSheet($$this.isFavoriteSheetVisible, this.collectionSheet(), {
      height: SheetSize.FIT_CONTENT,
      showClose: true,
      title: { title: '收藏站点' },
      preferType: SheetType.CENTER
    })
  }
}
