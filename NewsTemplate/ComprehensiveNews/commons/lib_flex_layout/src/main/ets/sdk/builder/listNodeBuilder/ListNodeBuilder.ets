import { CommonConstants } from 'lib_common'
import { LayoutSetting, NewsResponse } from 'lib_news_api'
import { FlexLayoutBreakPointVM } from '../../../viewmodel/FlexLayoutBreakPointVM'
import { getNativeNodeController, NodeControllerFactory } from '../../factory/NativeNodeFactory'
import { FrameNodeParams } from '../../model/Model'

@Builder
export function ListNodeBuilder(frameNodeParams: FrameNodeParams) {
  ListBuilder({
    articles: frameNodeParams.articles,
    viewLayout: frameNodeParams.viewLayout,
    style: frameNodeParams.style,
    extraInfo: frameNodeParams.extraInfo,
    nodeControllerFactory:frameNodeParams.nodeControllerFactory
  })
}

@ComponentV2
export struct ListBuilder {
  @Param articles: NewsResponse[] = []
  @Param viewLayout: LayoutSetting = new LayoutSetting()
  @Param style: Record<string, string | number> = {}
  @Param extraInfo: Record<string, number | string | boolean | Record<string, string | boolean>[]> = {}
  @Param nodeControllerFactory:NodeControllerFactory = new NodeControllerFactory()

  @Builder
  viewVNodeBuilder(children: LayoutSetting [], nativeCardData: NewsResponse, scrollIndex: number) {
    if (children) {
      ForEach(children, (item: LayoutSetting, index: number) => {
        if (item.type === 'view') {
          this.viewVNodeBuilder(item.children as LayoutSetting [], nativeCardData, scrollIndex)
        }
        if (item.type === 'native') {
          NodeContainer(getNativeNodeController(this.getUIContext(), {
            type: item.showType,
            nativeCardData: nativeCardData,
            scrollIndex: scrollIndex,
            layout: item,
            extraInfo: this.extraInfo,
          },this.nodeControllerFactory))
        }
      }, (item: LayoutSetting) => JSON.stringify(item))
    }
  }

  @Builder
  viewBuilder(children: LayoutSetting []) {
    List({ space: CommonConstants.SPACE_M }) {
      ForEach(this.articles, (item: NewsResponse, index: number) => {
        ListItem() {
          this.viewVNodeBuilder(children, item, index)
        }
      }, (item: NewsResponse) => JSON.stringify(item.id))
    }
    .lanes(new FlexLayoutBreakPointVM(this.extraInfo).getLanes, 16)
  }

  build() {
    this.viewBuilder(this.viewLayout.children as LayoutSetting [])
  }
}
