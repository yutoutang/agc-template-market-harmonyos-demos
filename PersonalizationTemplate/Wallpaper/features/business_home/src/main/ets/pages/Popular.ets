import { BaseViewModel, CommonConstants } from 'lib_common';
import { NavHeaderBar, WallpaperController, WallpaperList } from 'lib_widget';
import { ImageInfo } from 'module_wallpaper_details';
import { WallPaperLocalApi } from 'lib_wallpaper_api';

interface NavPathStackEvent {
  pathStack: NavPathStack;
}

@ObservedV2
class PopularVM extends BaseViewModel {
  @Trace wallpaperList: ImageInfo[] = []; // 壁纸列表数据
  @Trace sortBy: string = 'hot'; // hot热度-last时间
}

@Builder
export function PopularBuilder() {
  Popular()
}

@ComponentV2
export struct Popular {
  @Local sortText: string = '按热度';
  private vm: PopularVM = new PopularVM();
  private stack: NavPathStack = new NavPathStack();
  private controller: WallpaperController = new WallpaperController();
  private page: number = 0;
  private limit: number = 12;

  aboutToAppear(): void {
    this.page = 1
    this.vm.wallpaperList.push(...WallPaperLocalApi.getWallpaperListBySort(this.vm.sortBy, this.limit, this.page))
  }

  // 排序方式切换
  handleSortChange(): void {
    this.vm.sortBy = this.vm.sortBy === 'hot' ? 'last' : 'hot';
    this.sortText = this.vm.sortBy === 'hot' ? '按热度' : '按最新';

    if (this.vm.sortBy !== 'hot') {
      // 时间
      this.vm.wallpaperList = [...this.vm.wallpaperList].sort((a, b) => b.time - a.time);
    } else {
      // 热度
      this.vm.wallpaperList = [...this.vm.wallpaperList].sort((a, b) => b.hotValue - a.hotValue);
    }
  }

  // 榜单页面
  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '热门榜单',
        })
        this.buildSortSection()
        this.buildWallpaperList()
      }
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
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
        .fillColor($r('sys.color.icon_secondary'))
        .width(20)
        .height(20)
      Text(this.sortText)
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(FontWeight.Bold)
        .fontSize(16)
        .lineHeight(19)
        .margin({ left: 8 })
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
      dataSource: this.vm.wallpaperList, onLoad: (async () => {
        this.page++
        const result = WallPaperLocalApi.getWallpaperListBySort(this.vm.sortBy, this.limit, this.page)
        this.vm.wallpaperList.push(...WallPaperLocalApi.getWallpaperListBySort(this.vm.sortBy, this.limit, this.page))
        this.controller.refreshData()
        return result.length < this.limit
      }),
      controller: this.controller,
    }).layoutWeight(1)
  }
}