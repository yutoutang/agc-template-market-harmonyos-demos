import { jumpDetailPage, ParamsModel } from '@agctemplate/detail'
import { VideoSeries } from '@agctemplate/mine'
import { getMedia, getString } from '@agctemplate/resources'
import { MyFollowDramaData, MyFollowDramaRes, RequestAPI } from '@agctemplate/server'
import { GET } from '@agctemplate/server/src/main/ets/api/Decorators'
import {
  getDramaInfo,
  setFavorite,
  unsetFavorite
} from '@agctemplate/server/src/main/ets/api/mock/mockData/mockDramaFactory'
import { container, WindowManager } from '@agctemplate/utils'
import { AiBarHeight, AppStorageKeys, BreakPointType, MainTitleModifier, StatusBarHeight } from '@agctemplate/widgets'
import { AlertDialog, AppStorageV2 } from '@kit.ArkUI'
import { emitter } from '@kit.BasicServicesKit'

@ComponentV2
export struct FavorMainPage {
  @Local isDeleting: boolean = false
  @Local selectCount: number = 0
  @Local selectedIds: string[] = []
  @Local deletePromptMsg: string | Resource = '此条'
  @Local myFollowDramaRes: MyFollowDramaRes = new MyFollowDramaRes();
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  @Local aiBarHeight: AiBarHeight = AppStorageV2.connect(AiBarHeight, AppStorageKeys.AI_BAR_HEIGHT,
    () => new AiBarHeight(0))!;
  @Consumer('tabState') tabState: boolean = true;
  @Consumer('curTabIndex') currentIndex: number = 0;
  modifier: MainTitleModifier = new MainTitleModifier();
  deleteDialogController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: getString('app.string.delete_favor_prompt', this.deletePromptMsg.toString()),
      primaryButton: {
        value: '取消',
        action: () => {
          this.deleteDialogController.close()
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: $r('sys.color.ohos_id_color_warning'),
        action: () => {
          if (this.selectCount > 0) {
            // 删除选中
            this.selectedIds.map(item => unsetFavorite(item))
            this.updateFavorites()
            this.deleteDialogController.close()
            this.isDeleting = !this.isDeleting
            this.tabState = true
            this.selectedIds = []
            this.selectCount = 0
            this.sendDeleteFavoriteEmitter()
          }
        },
      },
    }),
  })

  @Monitor('currentIndex')
  onChange() {
    if (this.currentIndex === 3) {
      this.updateFavorites()
    }
  }

  aboutToAppear(): void {
    this.sendDeleteFavoriteEmitter()
    this.updateFavorites()
  }

  sendDeleteFavoriteEmitter() {
    let event: emitter.InnerEvent = {
      eventId: 6
    };
    let eventData: emitter.EventData = {
      data: {
        id: 6
      }
    };
    emitter.emit(event, eventData);
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部
        this.topBuilder()
        Column() {
          if (this.myFollowDramaRes.myFollowDramas.length > 0) {
            this.favorBuilder()
          } else {
            Text('暂无追剧')
              .height('100%')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.icon_secondary'))
          }
        }
        .width('100%')
      }
      .width('100%')
      .height(this.isDeleting ? '92.5%' : '100%')
      .padding({
        left: 16,
        right: 16,
        bottom: this.isDeleting ? 80 : 0
      })
      .backgroundColor($r('sys.color.background_secondary'))

      Column() {
        if (this.isDeleting) {
          this.footItemBuilder()
        }
      }.layoutWeight(1)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({
      top: `${px2vp(this.statusBarHeight.value)}vp`,
      bottom: this.isDeleting ? 0 : 70
    })
    .hideTitleBar(true)
  }

  @Builder
  topBuilder() {
    Row() {
      Text('追剧')
        .attributeModifier(this.modifier)

      Button(this.isDeleting ? '取消' : '编辑')
        .margin({ left: 8 })
        .height(40)
        .borderRadius(20)
        .fontSize(16)
        .fontColor($r('sys.color.font_primary'))
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          if (this.myFollowDramaRes.myFollowDramas.length > 0) {
            this.isDeleting = !this.isDeleting
            this.tabState = !this.tabState
            this.selectedIds = []
            this.selectCount = 0
            this.myFollowDramaRes.myFollowDramas.forEach(item => {
              item.isSelect = false;
            })
          }
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .height(56)
    .width('100%')
  }

  @Builder
  favorBuilder() {
    Grid() {
      Repeat<MyFollowDramaData>(this.myFollowDramaRes.myFollowDramas)
        .each((ri: RepeatItem<MyFollowDramaData>) => {
          GridItem() {
            VideoSeries({
              title: ri.item.name,
              currentEpisode: ri.item.currentWatch + 1,
              totalCount: ri.item.totalCount,
              cover: ri.item.coverUrl,
              isDeleting: this.isDeleting,
              likeCount: ri.item.likeCount,
              isLike: false,
              isSelectBack: (isSelect) => {
                ri.item.isSelect = isSelect
                this.getSelectedIds()
              },
              isVip: ri.item.isVip,
              onContinueWatch: () => {
                jumpDetailPage(ri.item, ri.item.currentWatch, 0, (params) => {
                  WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
                  const paramsInfo = params.result as ParamsModel
                  const drama = getDramaInfo(paramsInfo.id)
                  drama.curIndex = paramsInfo.curIndex
                  this.updateFavorites()
                })
              }
            })
          }
        })
        .key((item: MyFollowDramaData, index: number): string => item.id)// 键值生成函数
        .virtualScroll({
          totalCount: this.myFollowDramaRes.myFollowDramas.length
        }) // 打开virtualScroll模式，totalCount为期望加载的数据长度
    }
    .edgeEffect(EdgeEffect.Spring)
    .columnsTemplate('1fr 1fr 1fr')
    .scrollBar(BarState.Off)
    .cachedCount(4) // 容器组件的预加载区域大小
  }

  @Builder
  footItemBuilder() {
    Row() {
      Column() {
        Image(getMedia('app.media.ic_public_delete_all'))
          .width(22)
          .height(22)
        Text('一键清空')
          .height(14)
          .fontSize(13)
          .margin({ top: 5.36 })
      }
      .width('50%')
      .onClick(() => {
        this.getAllIds()
        this.deleteDialogController.open()
      })

      Column() {
        Image(getMedia('app.media.ic_public_delete'))
          .width(22)
          .height(22)
        Text('删除')
          .height(14)
          .fontSize(13)
          .margin({ top: 5.36 })
      }
      .width('50%')
      .opacity(this.selectCount > 0 ? 1 : 0.4)
      .enabled(this.selectCount > 0)
      .onClick(() => {
        this.getSelectedIds()
        this.deleteDialogController.open()
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.comp_background_gray'))
    .padding({
      top: 8,
      bottom: 8,
    })
  }

  // 更新观看记录数据
  updateFavorites(): void {
    container.resolve(RequestAPI).getMyFollowDrama({
      pageSize: 1,
      pageNum: 20
    }).then((res) => {
      this.myFollowDramaRes = new MyFollowDramaRes(res.getBody());
    })
  }

  // 获取列表id
  getSelectedIds() {
    this.selectedIds = this.myFollowDramaRes.myFollowDramas
      .filter(item => item.isSelect)
      .map(item => item.id)
    this.selectCount = this.selectedIds.length
    this.getSelectCount()
  }

  // 获取所有id
  getAllIds() {
    this.selectedIds = this.myFollowDramaRes.myFollowDramas
      .map(item => item.id);
    this.selectCount = this.selectedIds.length
    this.getSelectCount()
  }

  // 获取所有id
  getSelectCount() {
    if (this.selectCount < 1) {
      return
    }
    if (this.selectCount === 1) {
      this.deletePromptMsg = '此条'
    } else if (this.selectCount === this.myFollowDramaRes.myFollowDramas.length) {
      this.deletePromptMsg = '全部'
    } else {
      this.deletePromptMsg = this.selectCount + '条'
    }
  }
}


@Builder
export function FavorMainPageBuilder(index: number) {
  FavorMainPage();
}