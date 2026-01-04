import { BreakpointModel, CommonConstants } from 'lib_common';
import { WallpaperChildTab, WallPaperLocalApi, WallpaperSuperTab } from 'lib_wallpaper_api';
import { AppStorageV2 } from '@kit.ArkUI';
import { WallpaperController, WallpaperList } from 'lib_widget';
import { ImageInfo } from 'module_wallpaper_details';

@ObservedV2
class ClassificationVM {
  @Trace selectedCategory: string = '推荐';
  @Trace selectedSubCategory: string = '';
  @Trace selectedId: string = '0';
  @Trace showPopup: boolean = false;
  @Trace hotOrLast: boolean = true;
  @Trace sortBy: string = 'hot';
  @Trace wallpaperList: ImageInfo[] = [];
  @Trace breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
}

@ComponentV2
export struct Classification {
  @Local sortText: string = '按热度';
  @Local isShowModal: boolean = false;
  @Local listCurrentIndex: number = 0;
  private vm: ClassificationVM = new ClassificationVM();
  private allCategories: WallpaperSuperTab[] = [];
  private subCategoryScroller: Scroller = new Scroller();
  private listScroller: ListScroller = new ListScroller();
  private flowController: WallpaperController = new WallpaperController();
  private limit: number = 12;
  private page: number = 0;
  private context: Context = getContext();

  aboutToAppear(): void {
    this.allCategories = WallPaperLocalApi.getWallPaperTabList();
    this.loadWallpapers(this.vm.selectedId);
    this.context.eventHub.on('updateWallpaper', () => {
      this.loadWallpapers(this.vm.selectedId);
    });
  }

  aboutToDisappear(): void {
    this.context.eventHub.off('updateWallpaper');
  }

  // 加载壁纸数据
  loadWallpapers(id: string) {
    this.page = 1;
    if (this.vm.breakpointModel.currentBreakpoint !== 'md') {
      this.limit = 12
    } else {
      this.limit = 10
    }
    this.vm.wallpaperList = WallPaperLocalApi.getWallpaperList(id, this.vm.sortBy, this.limit, this.page);

    if (this.vm.wallpaperList.length % this.limit !== 0) {
      this.flowController.loadNoData();
    } else {
      this.flowController.refreshData();
    }
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

  @Builder
  ModalContentBuilder() {
    Column() {
      Divider()
        .strokeWidth('1px')
        .color($r('sys.color.comp_divider'))
        .width('100%')
        .margin({ bottom: 16 })

      // 分类网格
      Grid() {
        ForEach(this.allCategories, (item: WallpaperSuperTab, index: number) => {
          GridItem() {
            this.PopupCategoryItem(item, index)
          }
        }, (item: WallpaperSuperTab, index: number) => JSON.stringify(item) + '_' + index)
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap(16)
      .columnsGap(16)
      .padding({ left: 20, right: 20, bottom: 24 })
      .layoutWeight(1)

      // 底部安全区域
      Blank().height(24)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_primary'))
  }

  build() {
    Column() {
      Column() {
        Row() {
          List({ space: 24, initialIndex: 0, scroller: this.listScroller }) {
            ForEach(this.allCategories, (item: WallpaperSuperTab, index: number) => {
              ListItem() {
                this.ClassificationItem(item, index)
              }
            }, (item: WallpaperSuperTab, index: number) => JSON.stringify(item) + '_' + index)
          }
          .listDirection(Axis.Horizontal)
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })

          Row() {
            Image($r('app.media.ic_classification'))
              .width(24)
              .height(24)
          }.padding(10)
          .offset({ bottom: 5 })
          .onClick(() => {
            this.isShowModal = true;
          })
          .bindSheet($$this.isShowModal, this.ModalContentBuilder(), {
            height: 400,
            backgroundColor: Color.White,
            preferType: SheetType.CENTER,
            dragBar: true,
            showClose: true,
            title: { title: '壁纸分类' }
          })
        }
        .width(CommonConstants.FULL_PERCENT)
        .height(64)
        .padding({ left: 16, right: 16 })

        ForEach(this.allCategories, (superTabItem: WallpaperSuperTab) => {
          if (superTabItem.child.length > 0 && superTabItem.text === this.vm.selectedCategory) {
            Row() {
              Scroll(this.subCategoryScroller) {
                Row() {
                  ForEach(superTabItem.child, (item: WallpaperChildTab, index?: number) => {
                    this.SubClassificationItem(item, index)
                  }, (item: WallpaperChildTab, index?: number) => JSON.stringify(item) + '_' + index)
                }
                .padding({ left: 16, right: 16 })
              }
              .edgeEffect(EdgeEffect.Spring)
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
            }
            .width('100%')
            .height(55)
          }
        }, (item: WallpaperChildTab, index?: number) => JSON.stringify(item) + '_' + index)
      }
      .borderRadius(8)
      .margin({ top: 8 })
      .shadow({
        radius: 4,
        color: '#00000010',
        offsetX: 0,
        offsetY: 2
      })

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

      this.buildWallpaperList()
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  ClassificationItem(tab: WallpaperSuperTab, index: number) {
    Column({ space: 7 }) {
      Text(tab.text)
        .fontSize(18)
        .lineHeight(21)
        .fontColor(index === this.listCurrentIndex ? '#E6000000' : '#99000000')
        .fontWeight(index === this.listCurrentIndex ? FontWeight.Bold : FontWeight.Normal)
        .onClick(() => {
          this.listCurrentIndex = index
          this.selectCategory(tab)
        });
      Text()
        .width(16)
        .height(2)
        .backgroundColor(index === this.listCurrentIndex ? '#0A59F7' : Color.Transparent)
    }
    .height(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  SubClassificationItem(tab: WallpaperChildTab, index?: number) {
    Text(tab.text)
      .height(40)
      .fontSize(14)
      .fontColor(this.isSubCategorySelected(tab.text, index) ? '#007DFF' : '#E6000000')
      .fontWeight(this.isSubCategorySelected(tab.text, index) ? FontWeight.Medium : FontWeight.Normal)
      .padding({
        left: 16,
        right: 16,
        top: 10,
        bottom: 10
      })
      .backgroundColor(this.isSubCategorySelected(tab.text, index) ? '#FFFFFF' : '#0D000000')
      .borderRadius(20)
      .margin({ right: 8 })
      .onClick(() => this.selectSubCategory(tab.text, tab.id));
  }

  @Builder
  PopupCategoryItem(tab: WallpaperSuperTab, index: number) {
    Text(tab.text)
      .fontSize(14)
      .fontColor(this.vm.selectedCategory === tab.text ? '#FFFFFF' : '#333333')
      .fontWeight(this.vm.selectedCategory === tab.text ? FontWeight.Medium : FontWeight.Normal)
      .textAlign(TextAlign.Center)
      .padding({
        left: 16,
        right: 16,
        top: 10,
        bottom: 10
      })
      .backgroundColor(this.vm.selectedCategory === tab.text ? '#007DFF' : '#F5F5F5')
      .borderRadius(20)
      .onClick(() => {
        this.listScroller.scrollToIndex(index)
        this.listCurrentIndex = index
        this.selectCategory(tab);
        this.isShowModal = false;
      });
  }

  // 壁纸列表
  @Builder
  buildWallpaperList() {
    Scroll() {
      WallpaperList({
        controller: this.flowController,
        dataSource: this.vm.wallpaperList, onLoad: (async () => {
          this.page++;
          const result = WallPaperLocalApi.getWallpaperList(this.vm.selectedId, this.vm.sortBy, this.limit, this.page)
          this.vm.wallpaperList.push(...result)
          this.flowController.refreshData()
          return result.length < this.limit
        })
      })
    }
    .layoutWeight(1)
    .edgeEffect(EdgeEffect.Spring)

  }

  private isSubCategorySelected(text: string, index?: number): boolean {
    return (index === 0 && this.vm.selectedSubCategory === '') || (this.vm.selectedSubCategory === text);
  }

  private selectCategory(tab: WallpaperSuperTab): void {
    this.vm.selectedCategory = tab.text;
    this.vm.selectedSubCategory = '';

    const firstChild = tab.child.find((item: WallpaperChildTab) => true);
    const targetId = firstChild ? firstChild.id : tab.id;
    this.vm.selectedId = targetId
    this.loadWallpapers(targetId);
  }

  private selectSubCategory(subCategory: string, id: string): void {
    this.vm.selectedSubCategory = subCategory;
    this.vm.selectedId = id
    this.loadWallpapers(id);
  }
}