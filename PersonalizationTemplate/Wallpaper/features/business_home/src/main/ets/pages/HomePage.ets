// 首页
import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { DialogResult } from 'upload_recipe';
import { HotSearchItem, SearchController, SearchMockData, SearchPageParams } from 'lib_product_search';
import { Classification } from './Classification';
import {
  BaseViewModel,
  BreakpointModel,
  CommonConstants,
  Logger,
  PreferencesHelper,
  RouterMap,
  RouterUtils
} from 'lib_common';

const TAG = '[HomePageVM]';

@ObservedV2
class HomePageVM extends BaseViewModel {
  @Trace currentHotSearchIndex: number = 0; // 热搜轮播当前索引
  @Trace hotSearchList: HotSearchItem[] = []; // 热搜数据列表
  public searchController: SearchController = SearchController.instance; // 搜索控制器
  public timerId: number = -1; // 轮播定时器
  @Trace breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
}

@Builder
export function HomePageBuilder() {
  HomePage()
}

@ComponentV2
struct HomePage {
  private vm: HomePageVM = new HomePageVM();

  aboutToAppear(): void {
    this.loadHotSearchData(); // 加载热搜数据
    this.startCarousel();
  }

  aboutToDisappear(): void {
    this.stopCarousel();
  }

  // 搜索热搜mock数据
  async loadHotSearchData(): Promise<void> {
    try {
      // 使用本地mock数据替代网络请求
      this.vm.hotSearchList = SearchMockData.hotSearchList;
      // 同步到搜索控制器
      this.vm.searchController.generateHotSearch(this.vm.hotSearchList);
    } catch (error) {
    }
  }

  // 启动定时器
  startCarousel(): void {
    this.vm.timerId = setInterval(() => {
      if (this.vm.searchController.hotSearch.length > 0) {
        const newIndex = (this.vm.currentHotSearchIndex + 1) % this.vm.searchController.hotSearch.length;
        this.vm.currentHotSearchIndex = newIndex;
      }
    }, 3000);
  }

  // 停止
  stopCarousel(): void {
    if (this.vm.timerId !== -1) {
      clearInterval(this.vm.timerId);
      this.vm.timerId = -1;
    }
  }

  // 获取热搜显示文本
  getCurrentHotSearch(): string {
    if (this.vm.searchController.hotSearch.length === 0) {
      return '大家都在搜:';
    }
    const currentItem = this.vm.searchController.hotSearch[this.vm.currentHotSearchIndex];
    return `大家都在搜: ${currentItem || ''}`;
  }

  // 获取当前轮播的热搜词 传递到搜索页
  getCurrentHotSearchText(): string {
    if (this.vm.searchController.hotSearch.length === 0) {
      return '';
    }
    return this.vm.searchController.hotSearch[this.vm.currentHotSearchIndex] || '';
  }

  // 搜索框点击-跳搜索页
  handleSearchClick(): void {
    const currentKeyword = this.getCurrentHotSearchText();
    const params: SearchPageParams = {
      initialKeyword: currentKeyword,
      fromCarousel: true // 标记来自轮播点击
    };
    RouterUtils.pushPathByName(RouterMap.SEARCH_PAGE, params);
  }

  // 榜单按钮点击处理
  handleRankingClick(type: string): void {
    switch (type) {
      case 'popular':
        RouterUtils.pushPathByName(RouterMap.POPULAR);
        break;
      case 'latest':
        RouterUtils.pushPathByName(RouterMap.LATEST);
        break;
      case 'free':
        RouterUtils.pushPathByName(RouterMap.FREEPAGE);
        break;
    }
  }

  // 榜单按钮组件
  @Builder
  RankingButton(icon: Resource, text: string, type: string) {
    Column({ space: 8 }) {
      Image(icon)
        .width(40)
        .height(40)
      Text(text)
        .fontSize(12)
        .lineHeight(14)
        .fontColor($r('sys.color.font_tertiary'))
    }
    .onClick(() => {
      this.handleRankingClick(type);
    })
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部搜索栏
        this.buildSearchBar()

        // 榜单按钮区域
        this.buildRankingSection()

        // 分类内容区域
        Classification()
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor(Color.White)
      .alignItems(HorizontalAlign.Center)
    }
    .padding({ top: this.vm.windowModel.windowTopPadding })
    .hideTitleBar(true)
  }

  @Builder
  buildSearchBar() {
    Row({ space: 8 }) {
      // 搜索框区域
      Row() {
        // 搜索图标
        Image($r('app.media.icon_search'))
          .width(16)
          .height(16)
          .margin({
            left: 12,
            right: 8,
            top: 12,
            bottom: 12
          })
          .fillColor($r('sys.color.icon_tertiary'))
          .objectFit(ImageFit.Contain)

        // 热搜文本轮播显示
        Text(this.getCurrentHotSearch())
          .fontSize(16)
          .fontColor($r('sys.color.font_tertiary'))
          .layoutWeight(1)
      }
      .layoutWeight(1)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_gray'))
      .borderRadius(20)
      .onClick(() => {
        this.handleSearchClick();
      })

      // 上传按钮
      Row() {
        Image($r('app.media.icon_upload'))
          .width(24)
          .height(24)
      }
      .padding(8)
      .borderRadius(20)
      .backgroundColor($r('sys.color.comp_background_gray'))
      .onClick(async () => {
        if (!this.vm.userInfoModel.isLogin) {
          RouterUtils.pushPathByName(RouterMap.HUAWEI_LOGIN_PAGE, null, () => {
            this.vm.userInfoModel.isLogin = true;
            this.checkAlbumPermission();
          })
        } else {
          this.checkAlbumPermission();
        }
      })
    }
    .padding({
      left: 16,
      right: 16,
      top: 16,
      bottom: 8
    })
    .width(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  async checkAlbumPermission(): Promise<void> {
    let permission: boolean = await PreferencesHelper.getInstance().checkAlbumPermission(getContext());
    if (!permission) {
      this.requestAlbumPermission();
    } else {
      RouterUtils.pushPathByName(RouterMap.NEW_UPLOAD_PAGE);
    }
  }

  requestAlbumPermission(): void {
    try {
      promptAction.showDialog({
        message: '是否允许"壁纸"访问您设备上的照片？',
        buttons: [
          { text: '取消', color: '#99000000' },
          { text: '确定', color: '#0A59F7' }
        ]
      }).then((result: DialogResult) => {
        if (result.index === 1) {
          PreferencesHelper.getInstance().saveAlbumPermission(getContext())
          RouterUtils.pushPathByName(RouterMap.NEW_UPLOAD_PAGE); // 跳转上传页
        }
      });
    } catch (error) {
      Logger.error(TAG, 'open dialog failed. error:' + JSON.stringify(error));
    }
  }

  // 榜单按钮区域
  @Builder
  buildRankingSection() {
    Row() {
      this.RankingButton($r('app.media.icon_popular'), '热门榜单', 'popular')
      this.RankingButton($r('app.media.icon_latest'), '最新榜单', 'latest')
      this.RankingButton($r('app.media.icon_free'), '免费榜单', 'free')
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({
      left: 28,
      right: 28,
      top: 8,
      bottom: 8
    })
    .justifyContent(this.vm.breakpointModel.currentBreakpoint !== 'md' ? FlexAlign.SpaceBetween : FlexAlign.SpaceAround)
  }
}