import { RouterModule, RouterMap } from 'commonlib';
import { RecommendListItem } from '../types/Index';
import { MinePageVM } from '../viewModels/MinePageVM';


@ComponentV2
export struct RecommendBar {
  vm: MinePageVM = MinePageVM.instance;

  build() {
    Column({ space: 8 }) {
      Text('推荐展览')
        .width('100%')
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Body_L'));
      ForEach(this.vm.recommendList, (item: RecommendListItem, index) => {
        Column() {
          Image(item.img).height(120).width('100%');
          Column({ space: 4 }) {
            Text(item.name).fontWeight(500).fontColor($r('sys.color.ohos_id_color_text_primary'));
            Text(item.detail)
              .fontColor('rgba(0,0,0,0.66)')
              .fontSize(14);
            Flex({ justifyContent: FlexAlign.SpaceBetween }) {
              Row() {
                Text('¥')
                  .fontSize($r('sys.float.ohos_id_text_size_caption'))
                  .fontColor($r('app.color.font_color_red'))
                  .margin({ top: 4 });
                Text(item.price.toString()).fontColor($r('app.color.font_color_red')).fontWeight(500).fontSize(20);
              };

              Button('预约')
                .borderRadius(14)
                .width(78)
                .height(24)
                .backgroundColor('#D1B380')
                .fontColor('#603C00')
                .fontSize($r('sys.float.Body_S'))
                .fontWeight(FontWeight.Regular);

            };
          }.padding(12).alignItems(HorizontalAlign.Start);

        }
        .height(214)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .clip(true)
        .onClick(() => {
          RouterModule.push({ url: RouterMap.PERFORMANCE_DETAIL, param: { id: item.id } });
        });
      }, (item: RecommendListItem, index) => item.id);
    }.margin({ bottom: 16 });
  }
}