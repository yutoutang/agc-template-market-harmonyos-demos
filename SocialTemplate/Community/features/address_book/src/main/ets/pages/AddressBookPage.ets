/**
 * @usage: 通讯录主页面，展示置顶功能项（新的朋友/群聊/标签等）与好友分组列表，支持字母索引快速定位与页内跳转至“我的群列表”或联系人详情。
 * @layout: Top/Content/Bottom 结构：
 *  - 顶部（Top）：Row 渐变背景栏，固定高度 `104 + BarVM.instance.staBarH`，铺满宽度；随后为导航标题组件 AddressBookNavigationBar。
 *  - 内容（Content）：List 纵向列表，包含两部分：
 *     · ListItemGroup1：置顶功能项（Repeat ContactToppingItem），每项为 FriendInfoRow；点击跳转 MyGroupListPage。
 *     · ListItemGroup2-n：好友分组（Repeat CMChatFriendInfo），每项为 FriendInfoRow；点击跳转联系人详情。
 *    列表右侧叠加 AlphabetIndexer（alphaIndexBuilder），用于字母快速定位。
 *  - 底部（Bottom）：占位 ListItem 保留 AI Bar 高度 `BarVM.instance.aiBarH`，保障底部安全区与交互空间。
 * @constraints: 导航栏固定，头部三个列表元素固定，右边筛选列表固定
 * @isGen: false
 * @fileType: page
 * @domain: 社交交友
 * @zhName: 通讯录主页面
 * @subPage: MyGroupListPage
 * @subPage: AddressBookNavigationBar, FriendInfoRow
 * @component: MyGroupListPage, AvatarUrlView
 * @image: screenshots/addressbook.png
 */
import { AppStorageV2 } from '@kit.ArkUI';
import { BarVM, BreakpointModel, MessageJumpManager, RouterMap } from 'common';
import { CMChatFriendInfo } from 'instant_messaging';
import { AddressBookPageViewModel, ContactToppingItem, FriendGroup } from '../viewmodel/AddressBookPageViewModel';
import { AddressBookNavigationBar } from '../components/AddressBookNavigationBar';
import { FriendInfoRow } from '../components/FriendInfoRow';
import { phoneRouterControl } from 'oh_router';
import { MyGroupListPageBuilder } from './MyGroupListPage';

@Builder
export function AddressBookPageBuilder() {
  AddressBookPage()
}

@ComponentV2
struct AddressBookPage {
  addressbookVM: AddressBookPageViewModel = new AddressBookPageViewModel()
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  build() {
    RelativeContainer() {
      Row()
        .height(104 + BarVM.instance.staBarH)
        .linearGradient({
          angle: 0,
          colors: [['#00b8d1fe', 0.0], ['#ffcfd2ff', 1.0]]
        })
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          right: { anchor: '__container__', align: HorizontalAlign.End },
          left: { anchor: '__container__', align: HorizontalAlign.Start }
        })

      Column() {
        AddressBookNavigationBar()

        List({ scroller: this.addressbookVM.scroller }) {
          ListItemGroup() {
            Repeat<ContactToppingItem>(this.addressbookVM.toppingItems)
              .each((ri: RepeatItem<ContactToppingItem>) => {
                ListItem() {
                  FriendInfoRow({ imgSrc: ri.item.image, title: ri.item.title })
                    .onClick(() => {
                      phoneRouterControl.jumpPage({
                        pageName: RouterMap.MY_GROUP_LIST_PAGE,
                        builder: wrapBuilder(MyGroupListPageBuilder),
                        param: ri.index
                      })
                    })
                }
              })
              .key((item: ContactToppingItem, index: number): string => item.title + index)
              .virtualScroll({
                totalCount: 3
              })
              .templateId((_groupInfoVM: ContactToppingItem): string => {
                return '';
              })
          }
          .divider({ strokeWidth: '1px', color: $r('sys.color.comp_divider') })

          ForEach(this.addressbookVM.friendGroupList, (group: FriendGroup) => {
            ListItemGroup({
              header: this.headerBuilder(group.name)
            }) {
              Repeat<CMChatFriendInfo>(group.list)
                .each((ri: RepeatItem<CMChatFriendInfo>) => {
                  ListItem() {
                    FriendInfoRow({
                      imgSrc: $r('app.media.' + ri.item.avatarUrl),
                      title: (ri.item.friendRemark.length > 0) ? ri.item.friendRemark : ri.item.nickName
                    })
                      .onClick(() => {
                        MessageJumpManager.gotoContactInfo(ri.item.userId)
                      })
                  }
                })
                .key((item: CMChatFriendInfo, index: number): string => item.userId.toString() + index)
                .virtualScroll({
                  totalCount: group.list.length
                })
                .templateId((_groupInfoVM: CMChatFriendInfo): string => {
                  return '';
                })
            }
            .divider({ strokeWidth: '1px', color: $r('sys.color.comp_divider') })
          }, (group: FriendGroup, index: number) => group.name + '_' + index)

          ListItem().height(BarVM.instance.aiBarH)
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .width('100%')
        .layoutWeight(1)
        .onScrollIndex((start: number) => {
          this.addressbookVM.handleScrollIndex(start - 1)
        })
      }
      .alignRules({
        top: { anchor: '__container__', align: VerticalAlign.Top },
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
        right: { anchor: '__container__', align: HorizontalAlign.End },
        left: { anchor: '__container__', align: HorizontalAlign.Start }
      })

      this.alphaIndexBuilder()
    }
    .height('100%')
    .width('100%')
  }

  @Builder
  headerBuilder(title: string) {
    Text(title)
      .textAlign(TextAlign.Start)
      .fontSize($r('sys.float.Body_M'))
      .fontColor($r('app.color.color_99000000'))
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .height($r('app.float.vp_46'))
      .width('100%')
      .padding({
        left: this.breakPointModel.pagePadding,
        right: this.breakPointModel.pagePadding
      })
  }

  @Builder
  alphaIndexBuilder() {
    AlphabetIndexer({ arrayValue: this.addressbookVM.alphaIndexList, selected: this.addressbookVM.selectIndex })
      .alignRules({
        center: { anchor: '__container__', align: VerticalAlign.Center },
        right: { anchor: '__container__', align: HorizontalAlign.End },
      })
      .onSelect((tabIndex: number) => {
        this.addressbookVM.handleAlphaSelect(tabIndex + 1);
      })
  }
}
