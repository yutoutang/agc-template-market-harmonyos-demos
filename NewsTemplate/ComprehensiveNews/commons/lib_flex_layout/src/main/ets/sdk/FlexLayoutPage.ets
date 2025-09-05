import { SettingModel } from 'lib_common';
import { LayoutSetting, NewsResponse } from 'lib_news_api';
import { FrameController } from './factory/FrameNodeFactory';
import { RendNewsInfo } from './model/Model';
import { PersistenceV2 } from '@kit.ArkUI';

@ComponentV2
export struct FlexLayoutPage {
  @Param channelItem:RendNewsInfo | undefined = undefined
  @Param setting: LayoutSetting = new LayoutSetting()
  @Param articles: NewsResponse[] = []
  @Param flowIndex: number = 0
  @Param extraInfo: Record<string, number | string | boolean | Record<string, string | boolean>[]> = {}
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!
  @Local firstLevelClassificationData: LayoutSetting = new LayoutSetting()
  @Local count: number = 0
  @Local isSwiperDisabled: boolean = false
  @Local frameController:FrameController = new FrameController()

  @Monitor('settingInfo.darkSwitch')
  darkSwitch() {
    this.frameController.rebuild();
  }

  aboutToAppear(): void {
    this.settingDataHandler()
    this.extraInfo.flowIndex = this.flowIndex
    this.extraInfo.channelId = this.channelItem?.id ?? ''
  }

  aboutToDisappear(): void {
    this.frameController.disposeFrameNode()
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
    result.type = this.setting.type
    result.children = this.getAreaQueryVos(this.setting.children as LayoutSetting[])
    result.style = this.setting.style
    this.firstLevelClassificationData = result
    this.frameController.initFrameNode(this.firstLevelClassificationData, this.articles, this.extraInfo)
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
      NodeContainer(this.frameController)
    }
  }

  build() {
    this.buildVNode()
  }
}