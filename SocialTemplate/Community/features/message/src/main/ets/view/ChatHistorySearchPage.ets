/**
 * @usage: 聊天记录搜索页面，支持云端消息与联系人搜索
 * @layout: OHPage + 顶部占位 + ChatHistorySearchComponent
 * @constraints: 临时栏位复位；返回处理；SearchModelManager 模式设置
 * @isGen: false
 * @fileType: page
 * @domain: 社交交友
 * @zhName: 聊天记录搜索页
 * @subPage: ChatHistorySearchComponent
 * @component:
 * @image:
 */
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { BarVM, BreakpointModel, TempBarHeight, UserInfo } from 'common';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { ChatHistorySearchComponent, ContactSearchModel, SearchModelManager } from 'chat_history_search';
import { CMChatFactory } from 'instant_messaging';
import { ChatContentSingleModel } from 'chat_window';
import { chatParseMessageModel } from '../viewmodel/MessageChatModel';

@Builder
export function ChatHistorySearchPageBuilder(param: Object) {
  ChatHistorySearchPage({
    userId: (param as Record<string, string | undefined>).userId,
    groupId: (param as Record<string, string | undefined>).groupId
  });
}

@ComponentV2
export struct ChatHistorySearchPage {
  @Param @Require userId: string | undefined
  @Param @Require groupId: string | undefined
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
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  onCloudMessageSearch: (searchKey: string, userId?: string, groupId?: string,
    startDate?: number) => Promise<ChatContentSingleModel[]> =
    async (searchKey: string, userId?: string, groupId?: string,
      startDate?: number): Promise<ChatContentSingleModel[]> => {
      return new Promise<ChatContentSingleModel[]>((res, rej) => {
        let convertList: ChatContentSingleModel[] = [];
        CMChatFactory.instance.searchMessage(searchKey, userId, groupId, startDate).then((list) => {
          list.forEach((item) => {
            convertList.push(chatParseMessageModel(item, item.elemType, this.userInfo));
          })
          res(convertList);
        }).catch((_err: object) => {
          rej([]);
        })
      })
    };
  onCloudContactSearch: (searchKey: string) => Promise<ContactSearchModel[]> =
    async (searchKey: string): Promise<ContactSearchModel[]> => {
      return new Promise<ContactSearchModel[]>((res, rej) => {
        let newContactList: ContactSearchModel[] = [];
        CMChatFactory.instance.searchContact(searchKey).then((list) => {
          list.forEach((item) => {
            newContactList.push(SearchModelManager.parseContactSearchModel(item.userId, item.nickName, item.avatarUrl));
          })
          res(newContactList);
        }).catch(() => {
          rej([]);
        })
      })
    };

  @Builder
  render() {
    Column() {
      Blank().height(BarVM.instance.staBarH).backgroundColor($r('sys.color.white'));
      ChatHistorySearchComponent({
        userId: this.userId,
        groupId: this.groupId,
        onCloudMessageSearch: this.onCloudMessageSearch,
        onCloudContactSearch: this.onCloudContactSearch,
        onReturnClick: this.onReturnClick,
      });
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
