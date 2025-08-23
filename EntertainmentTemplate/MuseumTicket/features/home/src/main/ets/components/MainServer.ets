import { RouterModule, RouterMap } from 'commonlib';
import { HomePageVM } from '../viewModels/HomePageVM';
import { ServerListItem } from '../types/Index';

@ComponentV2
export struct MainServer {
  vm: HomePageVM = HomePageVM.instance;

  build() {
    Row() {
        ForEach(this.vm.serverList, (item: ServerListItem, index) => {
            Column({space:8}) {

                Image(item.icon).height(48).width(48);


              Text(item.name).fontColor('#603C00').fontSize($r('sys.float.Body_S')).fontWeight(FontWeight.Medium)

            }.onClick(() => {
            RouterModule.push({ url: item.url });
          });
        }, (item: ServerListItem, index) => item.name);
    }
    .width('100%')
    .padding(12)
    .borderRadius(16)
    .backgroundColor('#FFFFFF')
    .justifyContent(FlexAlign.SpaceBetween)

  }
}