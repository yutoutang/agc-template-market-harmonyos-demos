import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { BreakpointModel, SettingModel } from 'lib_common';
import { ChannelEdit, TabInfo } from 'module_channeledit';
import { FlexLayoutVM } from '../viewmodel/FlexLayoutVM';
import { RendNewsInfo } from '../sdk/model/Model';
import { NewsTabContent } from '../components/NewsTabContent';

@ComponentV2
export struct FlexLayout {
  @Local flexLayoutVm: FlexLayoutVM = new FlexLayoutVM()
  @Local pageIndex: number = 10;
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  aboutToAppear(): void {
    this.flexLayoutVm.init()
  }

  build() {
    Column() {
      Column() {
        ChannelEdit({
          channelsList: this.flexLayoutVm.channelsList,
          fontSizeRatio: this.settingInfo.fontSizeRatio,
          currentIndex: this.flexLayoutVm.tabIndex,
          onChange: (index: number, item: TabInfo) => {
            this.flexLayoutVm.tabIndexChange(index)
            this.flexLayoutVm.currentIndexChange(index)
          },
          onSave:() => {
            this.flexLayoutVm.channelConfirm()
          }
        })
      }

      Tabs({
        barPosition: BarPosition.Start,
        controller: this.flexLayoutVm.tabsController,
        index: this.flexLayoutVm.currentIndex,
      }) {
        ForEach(this.flexLayoutVm.rendNewsInfoList, (channelItem: RendNewsInfo,index:number) => {
          TabContent() {
            NewsTabContent({
              channelItem: channelItem,
              rendNewsInfoList: this.flexLayoutVm.rendNewsInfoList,
              bgColor: this.flexLayoutVm.bgColor,
            })
          }
        }, (item: RendNewsInfo, index: number) => index + JSON.stringify(item))
      }
      .barHeight(0)
      .layoutWeight(1)
      .animationDuration(100)
      .onAnimationStart((_index: number, targetIndex: number, _event: TabsAnimationEvent) => {
        this.flexLayoutVm.tabIndexChange(targetIndex)
      })
      .onChange((index: number) => {
        this.flexLayoutVm.currentIndexChange(index)
      })
    }
  }
}