import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { FlexLayout, FlexLayoutEngine, LayoutSetting } from 'module_flexlayout';
import { BreakpointModel, SettingModel } from 'lib_common';
import { NewsResponse } from 'lib_news_api';
import { RendNewsInfo } from '../model/Model';
import { CardRegisterEngine } from 'lib_native_components';


/*
 * 动态布局组件
 * 核心逻辑参考FrameNodeFactory.ets/NativeNodeFactory.ets
 * */
@ComponentV2
export struct FlexLayoutPage {
  @Param channelItem: RendNewsInfo | undefined = undefined
  @Param setting: LayoutSetting = new LayoutSetting()
  @Param articles: NewsResponse[] = []
  @Param flowIndex: number = 0
  @Param extraInfo: Record<string, number | string | boolean | Record<string, string | boolean>[]> = {}
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!
  @Local flexLayoutEngine: FlexLayoutEngine = new FlexLayoutEngine()
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Monitor('settingInfo.darkSwitch')
  darkSwitch() {
    /*
     * 调用rebuild接口通知NodeContainer组件重新回调makeNode方法，更新子节点。
     * */
    this.flexLayoutEngine.frameController.rebuild();
  }

  aboutToAppear(): void {
    this.extraInfo.flowIndex = this.flowIndex
    this.extraInfo.channelId = this.channelItem?.id ?? ''
    // 注册本地卡片
    CardRegisterEngine.CardRegister()
    // 初始化断点
    this.flexLayoutEngine.setBreakpointModel(this.breakpointModel)
    // 初始化本地数据
    this.flexLayoutEngine.createJsonLoader(this.setting, this.articles, this.extraInfo)
  }

  build() {
    FlexLayout({
      flexLayoutEngine: this.flexLayoutEngine,
    })
  }
}