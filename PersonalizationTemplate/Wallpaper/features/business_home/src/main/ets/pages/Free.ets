import { BaseViewModel, CommonConstants, RouterMap, RouterUtils } from 'lib_common';
import { WallPaperLocalApi } from 'lib_wallpaper_api';
import { NavHeaderBar, WallpaperController, WallpaperList } from 'lib_widget';
import { ImageInfo, ImageInfos } from 'module_wallpaper_details';

interface NavPathStackEvent {
  pathStack: NavPathStack;
}

@ObservedV2
class PopularVM extends BaseViewModel {
  @Trace sortBy: string = 'hot'; // hot热度-last时间
  @Trace wallpaperList: ImageInfo[] = []; // 壁纸列表数据
}

@Builder
export function FreePageBuilder() {
  FreePage()
}

@ComponentV2
export struct FreePage {
  @Local sortText: string = '按热度';
  private wallpaperController: WallpaperController = new WallpaperController();
  private stack: NavPathStack = new NavPathStack();
  private limit: number = 12;
  private page: number = 0;
  private vm: PopularVM = new PopularVM();

  // 排序方式切换
  handleSortChange(): void {
    this.page = 1;
    this.vm.sortBy = this.vm.sortBy === 'hot' ? 'last' : 'hot';
    this.sortText = this.vm.sortBy === 'hot' ? '按热度' : '按最新';
    this.vm.wallpaperList = WallPaperLocalApi.getWallpaperListBySort(this.vm.sortBy, this.limit, this.page);
  }

  aboutToAppear(): void {
    this.page = 1;
    this.vm.wallpaperList.push(...WallPaperLocalApi.getWallpaperListBySort(this.vm.sortBy, this.limit, this.page))
  }

  // 壁纸卡片
  @Builder
  WallpaperItemCard(item: ImageInfo, list: ImageInfo[]) {
    Column() {
      Image(item.url)
        .borderRadius(6)
        .objectFit(ImageFit.Cover)
        .onClick(async () => {
          try {
            const imageInfos: ImageInfos = {
              url: item.url,
              list
            };

            // 跳转到详情页
            RouterUtils.pushPathByName(RouterMap.NEW_ROUTER_MAP_WALLPAPER_DETAIL, imageInfos);
          } catch (error) {
          }
        })

      Row() {
        Image(item.userAvatar)
          .margin({ right: 4 })
          .objectFit(ImageFit.Cover)
          .borderRadius(90)
          .width(16)
          .height(16)

        Text(item.userName)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(10)
          .fontColor($r('sys.color.font_secondary'))
          .layoutWeight(1)
      }
      .height(16)
      .margin({ top: 2 })
    }
  }

  // 榜单页面
  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '免费榜单',
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

  // 顶部导航栏
  @Builder
  buildTopBar() {
    Row() {
      Image($r('app.media.ic_back'))
        .height(40)
        .width(40)
        .onClick(() => {
          if (this.stack.size() > 0) {
            this.stack.pop();
          }
        });

      // 页面标题
      Text('免费榜单')
        .fontSize(20)
        .margin({ left: 8 })
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(56)
    .padding({
      left: 16,
      bottom: 12,
      right: 16,
      top: 12
    })
  }

  // 排序区域
  @Builder
  buildSortSection() {
    Row() {
      Image($r('app.media.icon_text_and_arrow_down'))
        .height(20)
        .width(20)
        .fillColor($r('sys.color.icon_secondary'))
      Text(this.sortText)
        .fontColor($r('sys.color.font_secondary'))
        .lineHeight(19)
        .fontWeight(FontWeight.Bold)
        .fontSize(16)
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
      controller: this.wallpaperController,
      dataSource: this.vm.wallpaperList, onLoad: (async () => {
        this.page++
        const result = WallPaperLocalApi.getWallpaperListBySort(this.vm.sortBy, this.limit, this.page)
        this.vm.wallpaperList.push(...WallPaperLocalApi.getWallpaperListBySort(this.vm.sortBy, this.limit, this.page))
        this.wallpaperController.refreshData()
        return result.length < this.limit
      })
    }).layoutWeight(1)
  }
}