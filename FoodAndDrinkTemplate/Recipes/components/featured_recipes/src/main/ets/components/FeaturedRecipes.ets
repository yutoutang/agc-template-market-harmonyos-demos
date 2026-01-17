import { RecipeBriefInfo } from '../types/Index';
import { BreakpointModel, BreakpointType } from 'base_ui';
import LazyDataSource from '../utils/LazyDataSource';
import { RecommendedCard } from './RecommendedCard';
import { AppStorageV2 } from '@kit.ArkUI';

/**
 * @usage: 精选推荐组件，用于展示菜谱卡片瀑布流
 * @layout: 组件为列排列。顶部是标题栏；底部是瀑布流，左右和上下排列
 */
@ComponentV2
export struct FeaturedRecipes {
  @Param dishesList: LazyDataSource<RecipeBriefInfo> = new LazyDataSource();
  @Param showTitle: boolean = false;
  @Param canDelete: boolean = false;
  @Param isToDelete: boolean = false;
  @Param isLoading: boolean = false;
  @Event onClickCb: (id: number) => void = () => {
  }
  @Event jumpBloggerInfo: (id: number) => void = () => {
  }
  @Event deleteRecipes: (ids: number[]) => void = () => {
  }
  @Event changeSelect: (id: number, flag: boolean) => void = () => {
  }
  @Event changeDeleteState: (isToDelete: boolean) => void = () => {
  }
  @Event loadMore: () => void = () => {
  }
  @BuilderParam uploadBuilderParam: () => void = this.uploadBuilder;
  private lastTriggerTime: number = 0;
  private readonly DEBOUNCE_DELAY: number = 1100; // 防抖时间500ms
  // 新增参数
  scroller: Scroller = new Scroller();
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 2,
    md: 4,
    lg: 4,
    xl: 4,
  });

  @Computed
  get gridCount() {
    return this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
  }

  @Builder
  uploadBuilder() {
  }

  @Builder
  itemFoot(params:Record<string,boolean>) {
    Row({ space: 8 }) {
      LoadingProgress()
        .height(32)
        .width(48)
      Text('正在加载')
        .fontSize(14)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Regular)
    }
    .width('100%')
    .height(params.isLoading ? 40 : 0)
    .justifyContent(FlexAlign.Center)
    .visibility(params.isLoading ? Visibility.Visible : Visibility.Hidden)
  }


  build() {
    Column() {
      Text('精选推荐')
        .margin({ bottom: 12 })
        .fontColor($r('sys.color.font_primary'))
        .fontSize(16)
        .width('100%')
        .visibility(this.showTitle ? Visibility.Visible : Visibility.None)
      WaterFlow({scroller: this.scroller, footer: this.itemFoot({ 'isLoading': this.isLoading })}) {
        this.uploadBuilderParam()
        LazyForEach(this.dishesList, (item: RecipeBriefInfo) => {
          FlowItem() {
            RecommendedCard({
              recipe: item,
              canDelete: this.canDelete,
              isToDelete: this.isToDelete,
              jumpBloggerInfo: () => {
                this.jumpBloggerInfo(item.authorId)
              },
              changeDeleteState: (isToDelete: boolean) => {
                this.changeDeleteState(isToDelete)
              },
              onClickCb: (id: number) => {
                this.onClickCb(id)
              },
              changeSelect: (id: number, flag: boolean) => {
                this.changeSelect(id, flag)
              },
            })
          }
        }, (item: RecipeBriefInfo) => item.id.toString())
      }
      .cachedCount(25)
      .columnsGap(8)
      .rowsGap(8)
      .height('100%')  //影响其他页面
      .columnsTemplate(Array(this.gridCount).fill('1fr').join(' '))
      .nestedScroll({scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST})
      .onReachEnd(() => {
        // 防止回弹时额外触发
        const now = Date.now()
        // 检查是否在防抖时间内
        if (now - this.lastTriggerTime < this.DEBOUNCE_DELAY) {
          return
        }
        if (this.isLoading) {
          return
        }
        this.lastTriggerTime = now
        this.loadMore()
      })
    }
  }
}

