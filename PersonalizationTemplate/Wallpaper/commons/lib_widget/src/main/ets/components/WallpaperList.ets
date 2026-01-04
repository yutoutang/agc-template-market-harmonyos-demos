import { ImageInfo } from 'module_wallpaper_details';
import { WallpapreListVm } from '../viewmodels/WallpapreListVm';
import { Adapter } from './adapter/Adapter';
import { WallpaperListItem } from './WallpaperListItem';


export class WallpaperController {
  private flowComponent?: WallpaperList;

  attachComponent(component: WallpaperList) {
    this.flowComponent = component;
  }

  refreshData() {
    this.flowComponent?.dataSourceChange();
    this.reloadState();
  }


  reloadState() {
    this.flowComponent?.reloadState();
  }

  loadNoData() {
    this.flowComponent?.setLoadState(false);
    this.flowComponent?.setFinishState(true);
  }
}

@ComponentV2
export struct WallpaperList {
  @Param @Require dataSource: ImageInfo[];
  @Local finishView: Visibility = Visibility.None
  @Local loadView: Visibility = Visibility.None
  @Local finished: boolean = false
  @Local loading: boolean = false
  @Local vm: WallpapreListVm = new WallpapreListVm();
  scroller: Scroller = new Scroller()
  @Param controller: WallpaperController = new WallpaperController();
  private adapter: Adapter<ImageInfo> = new Adapter();

  @Monitor('dataSource')
  dataSourceChange() {
    this.adapter.reloadData(this.dataSource)
  }

  @Event
  onLoad?: () => Promise<boolean>

  reloadState() {
    this.setFinishState(false)
    this.setLoadState(false)
  }

  async onReachEnd() {
    if (this.loading || this.finished) {
      return
    } else {
      this.setLoadState(true)
      setTimeout(() => {
        this.onLoad?.().then(res => {
          if (res) {
            this.setFinishState(true)
          }
        })
        this.setLoadState(false)
      }, 1500);
    }
  }

  public setFinishState(state: boolean): void {
    this.finished = state;
    this.finishView = state ? Visibility.Visible : Visibility.None
  }

  public setLoadState(state: boolean): void {
    this.loading = state;
    this.loadView = state ? Visibility.Visible : Visibility.None
  }

  aboutToAppear(): void {
    this.dataSourceChange();
    this.controller.attachComponent(this);
  }

  build() {
    WaterFlow({ scroller: this.scroller, footer: (): void => this.itemFoot() }) {
      LazyForEach(this.adapter, (item: ImageInfo) => {
        FlowItem() {
          WallpaperListItem(item, this.dataSource)
        }
      }, (item: object, index: number) => `${index}_${JSON.stringify(item)}}`)
    }
    .columnsTemplate(this.vm.breakpointModel.currentBreakpoint !== 'md' ? '1fr 1fr 1fr' : '1fr 1fr 1fr 1fr 1fr')
    .columnsGap(8)
    .rowsGap(8)
    .width('100%')
    .height('100%')
    .padding({ right: 16, left: 16 })
    .edgeEffect(EdgeEffect.Spring)
    .layoutDirection(FlexDirection.Column)
    .onReachEnd(async () => {
      this.onReachEnd()
    })
    .onAreaChange((oldValue: Area, newValue: Area) => {
      if (newValue.height > oldValue.height) {
        this.onReachEnd()
      }
    })
  }

  @Builder
  itemFoot() {
    Row({ space: 10 }) {
      Text('已经到底了')
        .fontSize(14)
        .fontColor($r('sys.color.font_secondary'))
        .visibility(this.finishView)
      Text('正在加载中')
        .fontSize(14)
        .fontColor($r('sys.color.font_secondary'))
        .visibility(this.loadView)
      LoadingProgress()
        .width(20)
        .aspectRatio(1)
        .color($r('sys.color.icon_on_primary'))
        .visibility(this.loadView)
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height(50)
  }
}