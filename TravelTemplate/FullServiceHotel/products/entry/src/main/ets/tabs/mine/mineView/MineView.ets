import { MinePageVM } from '../viewModels/MinePageVM';
import { CommonHeader, CommonScroll } from 'componentlib';
import { MINE_PAGE_SETTING } from '../commons/Constants';
import { MineOperationItem, MineOperationType } from '../commons/Types';

@Builder
export function mineViewBuilder() {
  MineView()
}

@ComponentV2
struct MineView {
  vm: MinePageVM = MinePageVM.instance;

  build() {
    Column() {
      CommonHeader({ title: '我的', isSubTitle: false })
      CommonScroll() {
        this.headerBuilder()
        this.settingBuilder()
      }
    }
    .height('100%')
    .width('100%')
  }

  @Builder
  headerBuilder() {
    Row() {
      Image(this.vm.displayAvatar)
        .width(48)
        .borderRadius($r('app.string.border_radius_capsule'))
        .alt($r('app.media.ic_default_avatar'))
        .margin({
          right: $r('app.string.margin_l'),
        })
      Text(this.vm.displayName)
        .fontSize($r('app.string.font_size_18'))
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .margin({ right: $r('app.string.margin_l') })
      Image($r('app.media.ic_right_arrow'))
        .height(12)
        .fillColor($r('app.color.font_color_level3'))
    }
    .commonContainerStyle()
    .onClick(() => {
      this.vm.jumpToNext(MineOperationType.USER_INFO)
    })
  }

  @Builder
  settingBuilder() {
    List({ space: 12 }) {
      ForEach(MINE_PAGE_SETTING, (item: MineOperationItem) => {
        ListItem() {
          Row() {
            Image(item.icon)
              .width(20)
              .margin({ right: $r('app.string.margin_s') });
            Text(item.label)
              .fontSize($r('app.string.font_size_16'))
              .fontColor($r('app.color.font_color_level1'))
              .textAlign(TextAlign.Start)
              .layoutWeight(1)
            Image($r('app.media.ic_right_arrow'))
              .height(12)
              .fillColor($r('app.color.font_color_level3'))
          }
          .commonContainerStyle()
          .onClick(() => {
            this.vm.jumpToNext(item.type)
          })
        }
      }, (item: MineOperationItem) => JSON.stringify(item));
    };
  }
}

@Styles
function commonContainerStyle() {
  .width($r('app.string.width_percent_full'))
  .backgroundColor($r('app.color.background_color_white'))
  .borderRadius($r('app.string.border_radius_16'))
  .padding($r('app.string.padding_m'))
}