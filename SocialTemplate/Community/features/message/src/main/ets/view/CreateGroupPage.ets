import { AppStorageV2 } from '@kit.ArkUI';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import { CreateGroupModel } from '../viewmodel/CreateGroupModel';
import { BarVM, BreakpointModel, CommonHeader, RouterMap, TempBarHeight, TValueType } from 'common';
import { GroupSingleRow } from '../components/GroupSingleRow';
import { CMChatGroupInfo } from 'instant_messaging';
import { ContactSingleRow } from '../components/ContactSingleRow';
import { StartGroupChatRow } from '../components/StartGroupChatRow';
import { CreateGroupFromOldGroupPageBuilder } from './CreateGroupFromOldGroupPage';
import { MessageContactModel } from '../viewmodel/MessageContactModel';
import { MessageGroupInfoModel } from '../viewmodel/MessageGroupInfoModel';

@Builder
export function CreateGroupPageBuilder() {
  CreateGroupPage()
}

@ComponentV2
export struct CreateGroupPage {
  @Local createGroupVM: CreateGroupModel = new CreateGroupModel();
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
      phoneRouterControl.jumpPage({
        pageName: RouterMap.CREATE_GROUP_FROM_OLD_GROUP_PAGE,
        builder: wrapBuilder(CreateGroupFromOldGroupPageBuilder),
        param: groupInfoVM as TValueType
      })
    }
  @Local onFriendClick: (friendInfoVM: MessageContactModel) => void =
    (friendInfoVM: MessageContactModel) => {
      this.createGroupVM.selectContactCreateGroup(friendInfoVM);
    }
  @Local onStartGroupChatClick: () => void = () => {
    this.createGroupVM.startGroupChat();
  }

  @Builder
  setHeaderBuilder(title: ResourceStr) {
    Text(title)
      .fontSize($r('sys.float.Body_M'))
      .fontColor($r('app.color.color_99000000'))
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .textAlign(TextAlign.Start)
      .width('100%')
      .height($r('app.float.vp_42'))
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })
  }

  @Builder
  render() {
    CommonHeader({
      title: this.createGroupVM.pageTitle,
      onReturnClick: this.onReturnClick
    })
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })

    Column() {
      List({ scroller: this.createGroupVM.scroller }) {
        ListItemGroup({
          header: this.setHeaderBuilder('从群聊里选择')
        }) {
          Repeat<MessageGroupInfoModel>(this.createGroupVM.groupList)
            .each((ri: RepeatItem<MessageGroupInfoModel>) => {
              ListItem() {
                GroupSingleRow({
                  groupInfoVM: ri.item,
                  onGroupClick: this.onGroupClick
                });
              }
            })
            .key((item: MessageGroupInfoModel, index: number): string => item.groupId.toString() + index)
            .virtualScroll({
              totalCount: this.createGroupVM.groupList.length
            })
            .templateId((_groupInfoVM: MessageGroupInfoModel): string => {
              return '';
            })
        }
        .divider({
          strokeWidth: '1px',
          color: $r('sys.color.comp_divider')
        })

        ListItemGroup({
          header: this.setHeaderBuilder('从联系人里选择')
        }) {
          Repeat<MessageContactModel>(this.createGroupVM.contactList)
            .each((ri: RepeatItem<MessageContactModel>) => {
              ListItem() {
                ContactSingleRow({
                  friendInfoVM: ri.item,
                  onFriendClick: this.onFriendClick
                });
              }
            })
            .key((item: MessageContactModel, index: number): string => item.userId.toString() + index)
            .virtualScroll({
              totalCount: this.createGroupVM.contactList.length
            })
            .templateId((_friendInfoVM: MessageContactModel): string => {
              return '';
            })
        }
        .divider({
          strokeWidth: '1px',
          color: $r('sys.color.comp_divider')
        })
        ListItem().height(this.createGroupVM.isShowBottom ? $r('app.float.vp_12') : BarVM.instance.aiBarH)
      }
      .height('100%')
      .width('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    }
    .layoutWeight(1)
    .width('100%')

    StartGroupChatRow({
      onStartGroupChatClick: this.onStartGroupChatClick
    })
      .visibility(this.createGroupVM.isShowBottom ? Visibility.Visible : Visibility.None)
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

