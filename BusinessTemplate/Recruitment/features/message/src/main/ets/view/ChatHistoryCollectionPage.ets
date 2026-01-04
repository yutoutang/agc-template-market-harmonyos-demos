import { AppStorageV2 } from '@kit.ArkUI';
import { BarVM, BreakpointModel, CommonHeader, RouterMap, TempBarHeight, TValueType } from 'common';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { ChatHistoryCollectionComponent } from 'chat_history_collection';
import { ChatContentSingleModel, ChatTypeEnum } from 'chat_base';
import { ViewLocationPageBuilder } from './ViewLocationPage';

@Builder
export function ChatHistoryCollectionPageBuilder() {
  ChatHistoryCollectionPage()
}

@ComponentV2
export struct ChatHistoryCollectionPage {
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
  // 消息点击回调
  @Local onChatBubbleClick: (chatVM: ChatContentSingleModel) => void =
    (chatVM: ChatContentSingleModel) => {
      if (chatVM.chatType === ChatTypeEnum.CHAT_TYPE_LOCATION) {
        this.gotoViewLocation(chatVM);
      }
    }

  @Builder
  render() {
    Column() {
      Blank().height(BarVM.instance.staBarH);

      CommonHeader({
        title: '收藏',
        onReturnClick: this.onReturnClick
      })
        .padding({
          left: this.breakPointModel.pagePadding,
          right: this.breakPointModel.pagePadding
        })
      ChatHistoryCollectionComponent({
        onChatBubbleClick: this.onChatBubbleClick,
      })
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

  gotoViewLocation(chatVM: ChatContentSingleModel) {
    phoneRouterControl.jumpPage({
      pageName: RouterMap.VIEW_LOCATION_PAGE,
      builder: wrapBuilder(ViewLocationPageBuilder),
      param: chatVM as TValueType
    })
  }
}
