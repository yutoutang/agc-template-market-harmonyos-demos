import { LengthMetrics } from '@kit.ArkUI';
import { TitleBuilder, RouterModule, RouterMap } from 'commonlib';
import { ActiveCard } from '../components/ActiveCard';
import { ActiveDetailVM } from '../viewModels/ActiveDetailVM';
import { ActiveStatus } from '../types/Index';

@Builder
export function ActiveDetailBuilder() {
  ActiveDetail();
}


@ComponentV2
struct ActiveDetail {
  vm: ActiveDetailVM = ActiveDetailVM.instance;

  aboutToAppear(): void {
    this.vm.getActiveInfo();
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 12 }) {
          ActiveCard({
            activeInfo: this.vm.activeInfo,
          });

          Column({ space: 8 }) {
            Text('活动详情')
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor('#000000');
            Text(this.vm.activeInfo?.detail ?? '')
              .fontSize(14)
              .lineHeight(25)
              .fontColor($r('sys.color.font_secondary'))
              .lineHeight(25);

          }
          .borderRadius(16)
          .padding(12)
          .backgroundColor('#FFFFFF')
          .alignItems(HorizontalAlign.Start)
          .width('100%');

        }.constraintSize({ minHeight: '100%' }).padding({ left: 16, right: 16 });
      }.width('100%').scrollBar(BarState.Off).layoutWeight(1);

      if (this.vm.activeInfo && this.vm.activeInfo.type === ActiveStatus.PROCEED) {
        Column() {
          Button('立即预约')
            .height(40)
            .backgroundColor('#D1B380')
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .fontColor($r('sys.color.background_primary'));
        }.backgroundColor($r('sys.color.background_secondary'))
        .padding({
          left: 28,
          right: 28,
          top: 10,
          bottom: 12,
        }).onClick(() => {
          RouterModule.push({ url: RouterMap.Join_Active_Page, param: { activeInfo: this.vm.activeInfo } });
        });
      }


    }.title(TitleBuilder('活动详情'), { paddingStart: LengthMetrics.vp(16) })
    .backgroundColor('#F3F4F5');

  }
}

