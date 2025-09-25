import { BaseHeader, RouterModule } from 'commonlib';
import { MyBookVM } from '../viewModels/MyBookVM';
import { MenuItem } from '../types/Index';


@Builder
export function MyBookBuilder() {
  MyBook();
}


@ComponentV2
struct MyBook {
  vm: MyBookVM = MyBookVM.instance;

  build() {
    NavDestination() {
      BaseHeader('我的预订');
      Column() {
        Column({ space: 9 }) {
          ForEach(this.vm.menuList, (item: MenuItem, index) => {
            Row() {
              Text(item.label).fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'));
              Image($r('app.media.icon_public_arrow_right')).width(12).height(24);
            }.width('100%').justifyContent(FlexAlign.SpaceBetween)
            .onClick(() => {
              RouterModule.push({ url: item.routerUrl });
            });

            if (this.vm.menuList.length - 1 !== index) {
              Divider();
            }

          }, (item: MenuItem) => item.label);
        }.backgroundColor('#FFFFFF').borderRadius(16).padding(12);
      }.padding({ left: 16, right: 16 });

    }
    .backgroundColor('#F3F4F5')
    .hideTitleBar(true);

  }
}


