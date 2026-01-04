import { AppStorageV2 } from '@kit.ArkUI';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { BarVM, BreakpointModel, CommonHeader, TempBarHeight, TValueType } from 'common';
import { CMChatGroupInfo } from 'instant_messaging';
import { SearchContactRow } from '../components/SearchContactRow';
import { SearchContactModel } from '../viewmodel/AddFriendModel';
import { ForwardChatModel } from '../viewmodel/ForwardChatModel';
import { ChatContentSingleModel } from 'chat_base';

@Builder
export function ForwardChatPageBuilder(valueVM: TValueType) {
  ForwardChatPage({ valueVM: valueVM })
}

@ComponentV2
export struct ForwardChatPage {
  @Param @Require valueVM: TValueType;
  @Local forwardChatVM: ForwardChatModel = new ForwardChatModel();
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage()
  }
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageShow: () => {
      this.tempBarHeight.topValue = this.tempBarHeight.topTempValue;
      this.tempBarHeight.bottomValue = 0;
    }
  })
  @Local onGroupClick: (groupInfoVM: CMChatGroupInfo) => void =
    (groupInfoVM: CMChatGroupInfo) => {
      this.forwardChatVM.selectGroupOrContact(groupInfoVM.groupId, undefined);
    }
  @Local onContactClick: (contactVM: SearchContactModel) => void =
    (contactVM: SearchContactModel) => {
      this.forwardChatVM.selectGroupOrContact(undefined, contactVM.userId);
    }

  aboutToAppear(): void {
    try {
      let vm = this.valueVM as ChatContentSingleModel;
      this.forwardChatVM.chatModel = vm;
    } catch (err) {
    }
  }

  @Builder
  render() {
    CommonHeader({
      title: this.forwardChatVM.pageTitle,
      onReturnClick: this.onReturnClick
    })
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })

    Column() {
      List({ scroller: this.forwardChatVM.scroller }) {

        Repeat<SearchContactModel>(this.forwardChatVM.contactList)
          .each((ri: RepeatItem<SearchContactModel>) => {
            ListItem() {
              SearchContactRow({
                contactVM: ri.item,
                onContactClick: this.onContactClick
              });
            }
          })
          .key((item: SearchContactModel, index: number): string => item.userId.toString() + index)
          .virtualScroll({
            totalCount: this.forwardChatVM.contactList.length
          })
          .templateId((_friendInfoVM: SearchContactModel): string => {
            return '';
          })

        ListItem().height(BarVM.instance.aiBarH)
      }
      .height('100%')
      .width('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .layoutWeight(1)
    .width('100%')
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


