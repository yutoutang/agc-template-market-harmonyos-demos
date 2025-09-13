import { FlexLayoutBreakPointVM } from '../model/FlexLayoutBreakPointVM'
import { LayoutSetting } from '../model/Model'
import { FlexLayoutEngine } from '../viewmodel/FlexLayoutEngine'

/*
 * 动态布局组件
 * 核心逻辑参考FrameNodeFactory.ets/NativeNodeFactory.ets
 * */
@ComponentV2
export struct FlexLayout {
  @Local firstLevelClassificationData: LayoutSetting = new LayoutSetting()
  @Local count: number = 0
  @Param flexLayoutEngine: FlexLayoutEngine = new FlexLayoutEngine()

  aboutToAppear(): void {
    this.settingDataHandler()
    FlexLayoutBreakPointVM.breakpointModel = this.flexLayoutEngine.breakpointModel
  }

  aboutToDisappear(): void {
    /*
     * 组件销毁的时候需要手动解除绑定关系，否则可能出现内存泄漏
     * 立即释放当前BuilderNode对象对实体节点的引用关系。
     * */
    this.flexLayoutEngine.frameController.disposeFrameNode()
  }

  getAreaQueryVos(children: LayoutSetting[]) {
    let result: LayoutSetting[] = []
    if (children) {
      for (let index = 0; index < children.length; index++) {
        if (children[index].type === 'swiper') {
          this.getNativeCount(children[index].children as LayoutSetting[])
        }
        result.push({
          type: children[index].type,
          showType: children[index].showType ?? null,
          style: children[index].style,
          children: this.getAreaQueryVos(children[index].children),
        })
      }
    } else {
      return []
    }
    return result
  }

  settingDataHandler() {
    let result: LayoutSetting = new LayoutSetting()
    result.type = this.flexLayoutEngine.setting.type
    result.children = this.getAreaQueryVos(this.flexLayoutEngine.setting.children as LayoutSetting[])
    result.style = this.flexLayoutEngine.setting.style
    // 拿到第一层的数据，判断DSL第一层是否是容器组件view，否则视为不合法DSL
    this.firstLevelClassificationData = result
    this.flexLayoutEngine.frameController.initFrameNode(this.firstLevelClassificationData,
      this.flexLayoutEngine.articles, this.flexLayoutEngine.extraInfo)
  }

  getNativeCount(children: LayoutSetting []) {
    if (children) {
      for (let i = 0; i < children.length; i++) {
        if (children[i].type === 'native') {
          this.count++
        }
        this.getNativeCount(children[i].children as LayoutSetting [])
      }
    }
  }

  @Builder
  buildVNode() {
    if (this.firstLevelClassificationData.type === 'view') {
      /*
       * 使用NodeContainer挂载自定义节点
       * FrameController工厂函数返回的是根据布局信息解析好的FrameNode
       * */
      NodeContainer(this.flexLayoutEngine.frameController)
    }
  }

  build() {
    this.buildVNode()
  }
}