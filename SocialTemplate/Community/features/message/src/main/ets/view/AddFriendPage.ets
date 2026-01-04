/**
 * @usage: 添加朋友/群聊，支持本地搜索与扫码
 * @layout: Column + 搜索栏 + 功能入口 + 结果分组列表
 * @constraints: 输入态控制导航显隐；联系人/群聊跳转；虚拟滚动与模板
 * @isGen: false
 * @fileType: page
 * @domain: 社交交友
 * @zhName: 添加好友页
 * @subPage: AddFriendRow,SearchGroupRow,SearchContactRow
 * @component: PhoneContactPage
 * @image: screenshots/addFriend.png
 */
import { AppStorageV2 } from '@kit.ArkUI';
import { BarVM, BreakpointModel, CommonHeader, RouterMap, TCLogger, TempBarHeight } from 'common';
import { OHPage, OHPageConfig, phoneRouterControl } from 'oh_router';
import {
  AddFriendModel
} from '../viewmodel/AddFriendModel';
import { ADD_FRIEND_LIST } from '../constants/Constants';
import { AddFriendRow } from '../components/AddFriendRow';
import { CMChatGroupInfo } from 'instant_messaging';
import { SearchGroupRow } from '../components/SearchGroupRow';
import { SearchContactRow } from '../components/SearchContactRow';
import { PhoneContactPageBuilder } from './PhoneContactPage';
import { ChatJumpManager } from '../utils/ChatJumpManager';
import { AddFriendTypeEnum } from '../utils/MessageEnum';
import { AddFriendSingleModel } from '../viewmodel/AddFriendSingleModel';
import { SearchContactModel } from '../viewmodel/SearchContactModel';
import { SearchGroupInfoModel } from '../viewmodel/SearchGroupInfoModel';

@Builder
export function AddFriendPageBuilder() {
  AddFriendPage()
}

const TAG = 'AddFriendPage';

@ComponentV2
export struct AddFriendPage {
  @Local addFriendVM: AddFriendModel = new AddFriendModel();
  @Local tempBarHeight: TempBarHeight = AppStorageV2.connect(TempBarHeight, () => new TempBarHeight())!;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local searchContent: string = '';
  @Local isShowNav: boolean = true;
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage();
  }
  @Local pageConfig: OHPageConfig = new OHPageConfig({
    onPageShow: () => {
      this.tempBarHeight.topValue = 0;
      this.tempBarHeight.bottomValue = 0;
    }
  })
  @Local onFriendTypeClick: (friendVM: AddFriendSingleModel) => void =
    (friendVM: AddFriendSingleModel) => {
      if (friendVM.type === AddFriendTypeEnum.CHAT_TYPE_Contact) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.PHONE_CONTACT_PAGE,
          builder: wrapBuilder(PhoneContactPageBuilder)
        })
      } else {
        this.addFriendVM.startScanForResult();
      }
    }
  @Local onGroupClick: (groupInfoVM: CMChatGroupInfo) => void =
    (groupInfoVM: CMChatGroupInfo) => {
      ChatJumpManager.gotoGroupChatPage(groupInfoVM.groupId);
    }
  @Local onContactClick: (contactVM: SearchContactModel) => void =
    (contactVM: SearchContactModel) => {
      ChatJumpManager.gotoContactInfo(contactVM.userId);
    }

  @Builder
  setHeaderBuilder(title: ResourceStr) {
    Text(title)
      .fontSize($r('sys.float.Body_M'))
      .fontColor($r('app.color.color_99000000'))
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .textAlign(TextAlign.Start)
      .width('100%')
      .height($r('app.float.vp_46'))
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })
  }

  @Builder
  searchComponent() {
    Search({
      placeholder: '搜索账号/手机号'
    })
      .placeholderFont({
        size: $r('sys.float.Body_L'),
      })
      .placeholderColor($r('sys.color.font_secondary'))
      .margin({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })
      .onChange((value: string) => {
        // 输入内容发生变化时，触发该回调。
        TCLogger.info(TAG, 'onChange ' + value);
        this.searchContent = value.trim();
        this.addFriendVM.searchContentChange(this.searchContent);
      })
      .onCopy((value: string) => {
        // 进行复制操作时，触发该回调。
        TCLogger.info(TAG, 'onCopy ' + value);
        this.searchContent = value;
        if (this.searchContent.length > 0) {
          this.isShowNav = false;
        } else {
          this.isShowNav = true;
        }
      })
      .onEditChange((isEdit: boolean) => {
        // 输入状态变化时，触发该回调。有光标时为编辑态，无光标时为非编辑态。
        TCLogger.info(TAG, 'onEditChange ' + isEdit);
        if (isEdit) {
          this.isShowNav = false;
        } else {
          if (this.searchContent.length > 0) {
            this.isShowNav = false;
          } else {
            this.isShowNav = true;
          }
        }
      })
  }

  @Builder
  addFriendComponent() {
    Repeat<AddFriendSingleModel>(ADD_FRIEND_LIST)
      .each((ri: RepeatItem<AddFriendSingleModel>) => {
        ListItem() {
          AddFriendRow({
            friendVM: ri.item,
            onFriendClick: this.onFriendTypeClick
          });
        }
      })
      .key((item: AddFriendSingleModel, index: number): string => item.title.toString() + index)
      .virtualScroll({
        totalCount: ADD_FRIEND_LIST.length
      })
      .templateId((_friendInfoVM: AddFriendSingleModel): string => {
        return '';
      })
  }

  @Builder
  searchGroupResultComponent() {
    ListItemGroup({
      header: this.setHeaderBuilder('群聊')
    }) {
      Repeat<SearchGroupInfoModel>(this.addFriendVM.searchGroupList)
        .each((ri: RepeatItem<SearchGroupInfoModel>) => {
          ListItem() {
            SearchGroupRow({
              groupInfoVM: ri.item,
              onGroupClick: this.onGroupClick
            });
          }
        })
        .key((item: SearchGroupInfoModel, index: number): string => item.groupId.toString() + index)
        .virtualScroll({
          totalCount: this.addFriendVM.searchGroupList.length
        })
        .templateId((_groupInfoVM: SearchGroupInfoModel): string => {
          return '';
        })
    }
    .divider({
      strokeWidth: '1px',
      color: $r('sys.color.comp_divider'),
      startMargin: this.breakPointModel.pagePadding,
      endMargin: this.breakPointModel.pagePadding
    })
  }

  @Builder
  searchContactResultComponent() {
    ListItemGroup({
      header: this.addFriendVM.isPhoneInput ? undefined : this.setHeaderBuilder('账号')
    }) {
      Repeat<SearchContactModel>(this.addFriendVM.searchContactList)
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
          totalCount: this.addFriendVM.searchContactList.length
        })
        .templateId((_contactVM: SearchContactModel): string => {
          return '';
        })
    }
    .divider({
      strokeWidth: '1px',
      color: $r('sys.color.comp_divider'),
      startMargin: this.breakPointModel.pagePadding,
      endMargin: this.breakPointModel.pagePadding
    })
  }

  @Builder
  render() {
    Blank().height(BarVM.instance.staBarH);

    CommonHeader({
      title: this.addFriendVM.pageTitle,
      onReturnClick: this.onReturnClick
    })
      .visibility(this.isShowNav ? Visibility.Visible : Visibility.None)
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })

    Blank().height($r('app.float.vp_8'));
    this.searchComponent();

    Blank().height($r('app.float.vp_20'));

    Column() {
      List() {
        if (this.isShowNav) {
          this.addFriendComponent();
        } else {
          if (this.addFriendVM.searchGroupList.length > 0) {
            this.searchGroupResultComponent();
          }

          if (this.addFriendVM.searchGroupList.length > 0 &&
            this.addFriendVM.searchContactList.length > 0) {
            ListItem() {
              Row().width('100%').height('100%').backgroundColor($r('sys.color.background_secondary'))
            }.height($r('app.float.vp_16'))
          }

          if (this.addFriendVM.searchContactList.length > 0) {
            this.searchContactResultComponent();
          }

          ListItem().height(BarVM.instance.aiBarH)
        }
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
      pageConfig: this.pageConfig,
      pageBackgroundColor: this.isShowNav ? $r('sys.color.background_secondary') : Color.White
    })
  }
}
