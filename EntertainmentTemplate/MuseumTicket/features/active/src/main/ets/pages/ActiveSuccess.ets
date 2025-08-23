import { LengthMetrics } from '@kit.ArkUI';
import { TitleBuilder } from 'commonlib';
import { Contacts } from 'network';
import { ActiveCard } from '../components/ActiveCard';
import { ActiveSuccessVM } from '../viewModels/ActiveSuccessVM';

@Builder
export function ActiveSuccessBuilder() {
  ActiveSuccess();
}


@ComponentV2
struct ActiveSuccess {
  vm: ActiveSuccessVM = ActiveSuccessVM.instance;

  aboutToAppear(): void {
    this.vm.getActiveInfo();
  }

  build() {
    NavDestination() {
      if (this.vm.details){
        Scroll() {
          Column({ space: 12 }) {
            if (this.vm.activeInfo){
              ActiveCard({
                activeInfo: this.vm.activeInfo,
                isShowRemain:false
              });
            }
            Column() {
              Row({ space: 4 }) {
                Image($r('app.media.contact_person')).width(24).height(24);
                Text('参观人1').commonExtend();
              }.padding(12).width('100%').justifyContent(FlexAlign.SpaceBetween);

              Divider().width('100%');

              Column({ space: 12 }) {

                ForEach(this.vm.visitors, (item: Contacts, index) => {
                  Row() {
                    Text(item.name).commonExtend();
                    Text(item.cardID.substring(0, 6) + '********' + item.cardID.substring(14)).commonExtend();
                  }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                  if (this.vm.visitors.length - 1 !== index) {
                    Divider().width('100%');
                  }

                }, (item: Contacts) => item.name);

              }.padding(12).width('100%');

            }.width('100%').backgroundColor('#FFFFFF').borderRadius(16);


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

          }.constraintSize({ minHeight: '100%' }).padding({ left: 16, right: 16 });
        }.width('100%').scrollBar(BarState.Off).layoutWeight(1).edgeEffect(EdgeEffect.Spring);
      }
    }.title(TitleBuilder('确定活动'), { paddingStart: LengthMetrics.vp(16) })
    .backgroundColor('#F3F4F5');

  }
}


@Extend(Text)
function commonExtend() {
  .fontWeight(FontWeight.Medium).fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'));
}
