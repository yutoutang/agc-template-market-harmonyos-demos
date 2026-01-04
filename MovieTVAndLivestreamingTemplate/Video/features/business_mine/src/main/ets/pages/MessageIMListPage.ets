import { CommonConstants, RouterUtils } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { BriefIMModel } from '../common/ObservedModel';
import { IMItem } from '../components/IMItem';
import { SetReadIcon } from '../components/SetReadIcon';
import { MsgIMViewModel } from '../viewmodels/MessageIMListVM';

@Builder
export function MsgIMPageBuilder() {
  MsgIMPage()
}

@ComponentV2
struct MsgIMPage {
  @Local vm: MsgIMViewModel = new MsgIMViewModel();

  aboutToAppear(): void {
    this.vm.createWeb(this.getUIContext());
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: '私信',
          rightPartBuilder: () => {
            this.rightPartBuilder()
          },
          onBack: () => {
            RouterUtils.pop('1');
          },
        })
        Column() {
          List({ space: CommonConstants.SPACE_M }) {
            ForEach(this.vm.chatList, (v: BriefIMModel) => {
              ListItem() {
                IMItem({
                  info: v,
                  fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
                })
              }
              .onClick(() => {
                this.vm.jumpChatPage(v);
              })
            }, (v: BriefIMModel) => JSON.stringify(v))
          }
          .width(CommonConstants.FULL_PERCENT)
          .height(CommonConstants.FULL_PERCENT)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .padding({
            left: CommonConstants.PADDING_PAGE,
            right: CommonConstants.PADDING_PAGE,
            top: CommonConstants.SPACE_S,
          })
        }
        .layoutWeight(1)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      RouterUtils.pop('1');
      return true;
    })
  }

  @Builder
  rightPartBuilder() {
    SetReadIcon({
      enable: this.vm.allowClean,
      confirm: () => {
        this.vm.setAllRead();
      },
    })
  }
}