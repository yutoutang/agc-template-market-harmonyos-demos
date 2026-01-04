import { BaseViewModel, CommonConstants } from 'lib_common';
import { NavHeaderBar, WallpaperController, WallpaperList } from 'lib_widget';
import { ImageInfo } from 'module_wallpaper_details';
import { WallPaperLocalApi } from 'lib_wallpaper_api';

interface NavPathStackEvent {
  pathStack: NavPathStack;
}

@ObservedV2
class LatestVM extends BaseViewModel {
  @Trace sortBy: string = 'hot'; // hot热度-last时间
  @Trace wallpaperList: ImageInfo[] = []; // 壁纸列表数据
}

@Builder
export function LatestPageBuilder() {
  LatestPage()
}

@ComponentV2
export struct LatestPage {
  @Local sortText: string = '按热度';
  private vm: LatestVM = new LatestVM();
  private stack: NavPathStack = new NavPathStack();
  private flowController: WallpaperController = new WallpaperController();
  private limit: number = 12;
  private page: number = 0;

  aboutToAppear(): void {
    this.page = 1;
    this.vm.wallpaperList.push(...WallPaperLocalApi.getWallpaperListBySort(this.vm.sortBy, this.limit, this.page))
  }

  // 排序方式切换
  handleSortChange(): void {
    this.vm.sortBy = this.vm.sortBy === 'hot' ? 'last' : 'hot';
    this.sortText = this.vm.sortBy === 'hot' ? '按热度' : '按最新';
    if (this.vm.sortBy === 'hot') {
      // 热度降序
      this.vm.wallpaperList = [...this.vm.wallpaperList].sort((a, b) => b.hotValue - a.hotValue);
    } else {
      // 时间降序
      this.vm.wallpaperList = [...this.vm.wallpaperList].sort((a, b) => b.time - a.time);
    }
  }

  // 榜单页面
  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '最新榜单',
        })
        this.buildSortSection()
        this.buildWallpaperList()
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('sys.color.background_secondary'))
      .padding({ bottom: this.vm.windowModel.windowBottomPadding })
    }
    .hideTitleBar(true)
    .onReady((event: NavPathStackEvent) => {
      this.stack = event.pathStack;
    });
  }

  // 排序区域
  @Builder
  buildSortSection() {
    Row() {
      Image($r('app.media.icon_text_and_arrow_down'))
        .width(20)
        .height(20)
        .fillColor($r('sys.color.icon_secondary'))
      Text(this.sortText)
        .fontColor($r('sys.color.font_secondary'))
        .fontSize(16)
        .lineHeight(19)
        .margin({ left: 8 })
        .fontWeight(FontWeight.Bold);
    }
    .width('100%')
    .height(48)
    .justifyContent(FlexAlign.Start)
    .padding({ left: 16 })
    .onClick(() => this.handleSortChange())
  }

  // 壁纸列表
  @Builder
  buildWallpaperList() {
    WallpaperList({
      controller: this.flowController,
      dataSource: this.vm.wallpaperList, onLoad: (async () => {
        this.page++
        const result = WallPaperLocalApi.getWallpaperListBySort(this.vm.sortBy, this.limit, this.page)
        this.vm.wallpaperList.push(...WallPaperLocalApi.getWallpaperListBySort(this.vm.sortBy, this.limit, this.page))
        this.flowController.refreshData()
        return result.length < this.limit
      })
    }).layoutWeight(1)
  }
}