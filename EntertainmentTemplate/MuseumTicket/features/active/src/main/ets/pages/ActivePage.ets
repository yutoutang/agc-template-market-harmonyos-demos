import { LengthMetrics } from '@kit.ArkUI';
import { RouterMap, RouterModule, TitleBuilder } from 'commonlib';
import { ActiveInfo } from 'network';
import { ActiveCard } from '../components/ActiveCard';
import { ActiveType } from '../types/Index';
import { ActivePageVM } from '../viewModels/ActivePageVM';


@Builder
export function ActivePageBuilder() {
  ActivePage();
}


@ComponentV2
struct ActivePage {
  vm: ActivePageVM = ActivePageVM.instance;

  aboutToAppear(): void {
    this.vm.getActiveInfo();
  }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        Row({ space: 12 }) {
          ForEach(this.vm.activeTypes, (item: ActiveType, index) => {
            Text(item.label)
              .height(40)
              .padding({ left: 8, right: 8 })
              .borderRadius(20)
              .backgroundColor(this.vm.curIndex === index ? '#D1B380' : '#FFFFFF')
              .fontColor('#603C00')
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(this.vm.curIndex === index ? FontWeight.Medium : FontWeight.Regular)
              .onClick(() => {
                this.vm.curIndex = index;
              });
          }, (item: ActiveType) => item.label);
        }.width('100%');

        List({ space: 12 }) {
          if (!this.vm.activeData.length) {
            ListItem() {
              Row() {
                Divider().width(40);
                Text('没有更多了').fontColor($r('sys.color.font_tertiary')).fontSize(14);
                Divider().width(40);
              }.margin({ top: 15 }).width('100%').justifyContent(FlexAlign.Center);
            };
          }

          ForEach(this.vm.activeData, (item: ActiveInfo, index) => {
            ListItem() {
              ActiveCard({
                activeInfo: item,
                isShowAddress:false
              });
            }.onClick(() => {
              RouterModule.push({ url: RouterMap.ACTIVE_DETAIL, param: { activeInfo: item } });
            });
          }, (item: ActiveInfo) => item.activeId);
        }.scrollBar(BarState.Off);

      }.padding({ left: 16, right: 16, top: 7 }).height('100%');
    }
    .title(TitleBuilder('活动列表'), { paddingStart: LengthMetrics.vp(16) })
    .backgroundColor('#F3F4F5');

  }
}



