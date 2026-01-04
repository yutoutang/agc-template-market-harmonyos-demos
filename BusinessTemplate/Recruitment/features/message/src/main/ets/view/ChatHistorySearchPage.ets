import { AppStorageV2 } from '@kit.ArkUI';
import { BarVM, BreakpointModel, TempBarHeight } from 'common';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { ChatHistorySearchComponent } from 'chat_history_search';

@Builder
export function ChatHistorySearchPageBuilder() {
  ChatHistorySearchPage()
}

@ComponentV2
export struct ChatHistorySearchPage {
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageShow: () => {
      this.tempBarHeight.topValue = 0;
      this.tempBarHeight.bottomValue = 0;
    },
    onPageHide: () => {
      this.tempBarHeight.topValue = this.tempBarHeight.topTempValue;
      this.tempBarHeight.bottomValue = this.tempBarHeight.bottomTempValue;
    }
  })
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage()
  }

  @Builder
  render() {
    Column() {
      Blank().height(BarVM.instance.staBarH).backgroundColor($r('sys.color.white'));
      ChatHistorySearchComponent();
    }
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      pageConfig: this.pageConfig
    })
  }
}
