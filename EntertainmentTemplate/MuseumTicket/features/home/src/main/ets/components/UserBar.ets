import { RouterModule } from 'commonlib';
import { PersonManage, SelectMode } from 'module_person_manage';
import { HomePageVM } from '../viewModels/HomePageVM';

@ComponentV2
export struct UserBar {
  vm: HomePageVM = HomePageVM.instance;

  build() {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row({ space: 8 }) {
        Image(this.vm.userInfo.avatar).width(44).height(44).borderRadius(22).alt($r('app.media.icon_avatar'));
        Text(this.vm.userInfo.nickname ? this.vm.userInfo.nickname : '华为用户')
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_M'));
      };

      PersonManage({
        navPathStack: RouterModule.getStack(),
        selectMode: SelectMode.NO_SELECT,
      }) {
        Row({ space: 4 }) {
          Text('常用参观人').fontSize($r('sys.float.Body_M')).fontColor('#603C00');
          Image($r('app.media.ic_brown_arrow_right')).width(12).height(24);
        }
        .backgroundColor('#D1B380')
        .width(112)
        .height(32)
        .padding({ left: 15, right: 11 })
        .borderRadius(33);
      };

    }
    .height(72)
    .padding({ left: 20, right: 15 })
    .borderRadius(16)
    .backgroundColor('#FFFFFF');
  }
}