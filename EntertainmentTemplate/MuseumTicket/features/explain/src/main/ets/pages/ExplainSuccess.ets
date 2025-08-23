import { LengthMetrics } from '@kit.ArkUI';
import { TitleBuilder, FormatUtil } from 'commonlib';
import { Contacts } from 'network';
import { ExplainSuccessVM } from '../viewModels/ExplainSuccessVM';

@Builder
export function ExplainSuccessBuilder() {
  ExplainSuccess();
}


@ComponentV2
struct ExplainSuccess {
  vm: ExplainSuccessVM = ExplainSuccessVM.instance;

  aboutToAppear(): void {
    this.vm.getParams();
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 12 }) {
          if (this.vm.details) {
            Row({ space: 12 }) {
              Image(this.vm.details.img).width(88).height(114).borderRadius(8);
              Column({ space: 12 }) {
                Text(this.vm.details.title).commonTextExtend();
                Text(`${FormatUtil.dateAsISOCN(new Date(this.vm.details.time))} ${this.vm.details.timeSegment}`)
                  .commonTextExtend();
                Text(this.vm.details.explainType).commonTextExtend();
                Row() {
                  Text(this.vm.details.language).commonTextExtend();
                  Text(`¥${this.vm.details.price}/人`)
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.multi_color_08'));
                }.width('100%').justifyContent(FlexAlign.SpaceBetween);
              }.layoutWeight(1).padding({ top: 3 }).alignItems(HorizontalAlign.Start);
            }.commonWrapperExtend();

            Column() {
              Row({ space: 4 }) {
                Image($r('app.media.contact_person')).width(24).height(24);
                Text('参观人')
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('sys.float.Body_M'))
                  .fontColor($r('sys.color.font_primary'));

              }.padding(12).width('100%');

              Divider().width('100%');

              Column({ space: 12 }) {
                ForEach(this.vm.details.visitors, (item: Contacts, index) => {
                  if (index !== 0) {
                    Divider().width('100%');
                  }
                  Row() {
                    Text(item.name).commonTextExtend();
                    Text(item.cardID.substring(0, 6) + '********' + item.cardID.substring(14)).commonTextExtend();
                  }.width('100%').justifyContent(FlexAlign.SpaceBetween);
                }, (item: Contacts) => JSON.stringify(item));

              }.padding(12).width('100%');

            }.width('100%').backgroundColor('#FFFFFF').borderRadius(16);
          }

          Column({ space: 8 }) {
            Row({ space: 4 }) {
              Image($r('app.media.active_success')).width(24).height(24);
              Text('参加成功！')
                .fontWeight(FontWeight.Bold)
                .fontSize($r('sys.float.Title_S'))
                .fontColor($r('sys.color.background_primary'))
                .lineHeight(27);
            };

            Text('请于活动前确认时间地点，以免错过～')
              .fontWeight(FontWeight.Regular)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.background_primary'))
              .lineHeight(19);

          }
          .padding(12)
          .width('100%')
          .backgroundColor('#25C330')
          .borderRadius(16)
          .alignItems(HorizontalAlign.Start);

        }.padding({ bottom: 10 });

      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .align(Alignment.Top)
      .padding({ left: 16, right: 16 })
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false });

    }
    .title(TitleBuilder('预约成功'), { paddingStart: LengthMetrics.vp(16) })
    .backgroundColor($r('sys.color.background_secondary'));

  }
}


@Extend(Row)
function commonWrapperExtend() {
  .padding(12).borderRadius(16).backgroundColor('#FFFFFF');
}

@Extend(Text)
function commonTextExtend() {
  .fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary')).fontWeight(FontWeight.Regular);
}

