import { CardItem, ComponentDetailTitle } from '../models/DataSource'
import { ListDataSource } from '../viewmodels/datasource'
import { FlowItemComponent } from './FlowItemComponent'

@ComponentV2
export struct WaterFlowComponent {
  @Param @Require dataSource: object[]
  @Param finished: boolean = true
  @Param isLazy: boolean = true
  @Param lanes: number = 1
  @Local loading: boolean = false
  private lazyDataSource: ListDataSource<object> = new ListDataSource()
  @Event
  onLoad: () => void = () => {
  }
  @Event
  toComponentDetail: (params: ComponentDetailTitle) => void = (params: ComponentDetailTitle) => {
  }

  aboutToAppear(): void {
    this.dataSourceChange();
  }

  @Monitor('dataSource')
  dataSourceChange() {
    this.lazyDataSource.reloadData(this.dataSource)
  }

  onReachEnd() {
    if (!this.finished && !this.loading) {
      this.loading = true
      this.onLoad()
      this.loading = false
    }
  }

  @Builder
  getBottomDisPlay() {
    Row({ space: 10 }) {
      if (this.finished) {
        Text('已经到底了')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
      } else {
        Text('正在加载中')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
        LoadingProgress()
          .width(20)
          .aspectRatio(1)
          .color($r('sys.color.icon_secondary'))
      }
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height(50)
  }

  build() {
    List() {
      LazyForEach(this.lazyDataSource, (item: CardItem) => {
        ListItem() {
          FlowItemComponent({
            item: item,
            toComponentDetail: async (params: ComponentDetailTitle) => {
              this.toComponentDetail(params)
            }
          })
            .backgroundColor('#ccc')
        }
      }, (item: object, index: number) => `${index}_${JSON.stringify(item)}}`)
    }
    .scrollBar(BarState.Off)
    .lanes(this.lanes)
    .height('100%')
    .edgeEffect(EdgeEffect.Spring,{alwaysEnabled:true})
    .onReachEnd(() => {
      this.onReachEnd()
    })
  }
}