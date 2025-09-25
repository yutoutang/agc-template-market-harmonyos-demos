import { LengthMetrics } from '@kit.ArkUI';
import { TitleBuilder, FormatUtil } from 'commonlib';
import { DetailHeader } from '../components/DetailHeader';
import { NoticeBar } from '../components/NoticeBar';
import { EXPLAIN_LABEL_MAP, ICON_MAP } from '../constants/Constants';
import { OrderStatus } from '../types/Index';
import { ActiveOrderDetailVM } from '../viewModels/ActiveOrderDetailVM';


@Builder
export function ActiveOrderDetailBuilder() {
  ActiveOrderDetail();
}


@ComponentV2
struct ActiveOrderDetail {
  vm: ActiveOrderDetailVM = ActiveOrderDetailVM.instance;

  aboutToAppear(): void {
    this.vm.getParm();
  }

  build() {
    NavDestination() {
      if (this.vm.detail) {
        Scroll() {
          Column({ space: 12 }) {
            DetailHeader({
              icon: ICON_MAP.get(this.vm.detail.status),
              label: EXPLAIN_LABEL_MAP.get(this.vm.detail.status),
              name: this.vm.detail.title,
              visitTime: this.vm.detail.activeTime,
            });
            NoticeBar();
            Column({ space: 12 }) {
              Text('订单信息')
                .fontSize($r('sys.float.Subtitle_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'));
              Row() {
                Text('活动名称').commonTextExtend();
                Text(this.vm.detail.title).commonTextExtend();
              }.width('100%').justifyContent(FlexAlign.SpaceBetween);

              Divider();
              Row() {
                Text('活动时间').commonTextExtend();
                Text(this.vm.detail.activeTime).commonTextExtend();
              }.width('100%').justifyContent(FlexAlign.SpaceBetween);

              Divider();
              Row() {
                Text('联系人').commonTextExtend();
                Text(this.vm.detail.contactName).commonTextExtend();
              }.width('100%').justifyContent(FlexAlign.SpaceBetween);

              Divider();
              Row() {
                Text('参观人').commonTextExtend();
                Text(this.vm.detail.visitors.map(item => item.name)
                  .join('、')).commonTextExtend();
              }.width('100%').justifyContent(FlexAlign.SpaceBetween);

              Divider();
              Row() {
                Text('预约时间').commonTextExtend();
                Text(FormatUtil.formatFullDate(new Date(this.vm.detail.orderTime), true)).commonTextExtend();
              }.width('100%').justifyContent(FlexAlign.SpaceBetween);

            }.backgroundColor('#FFFFFF').borderRadius(16).padding(12).alignItems(HorizontalAlign.Start);
          }.padding({ left: 16, right: 16 });
        }
        .backgroundColor('#F0F0F0')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        .align(Alignment.Top)
        .layoutWeight(1);


        if (this.vm.detail.status === OrderStatus.PENDING_PAY) {
          Row() {
            Button('前往支付')
              .width(64)
              .height(28)
              .backgroundColor('#D1B380')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_on_primary'))
              .fontWeight(500)
              .padding(0)
              .onClick(() => {
                if (this.vm.detail) {
                  this.vm.toPayOrder(this.vm.detail);
                }
              });
          }
          .height(56)
          .width('100%')
          .padding({ left: 10, right: 10 })
          .justifyContent(FlexAlign.End)
          .backgroundColor('#FFFFFF');
        }
      } else {
        LoadingProgress().width(40);
      }
    }.title(TitleBuilder('订单详情'), { paddingStart: LengthMetrics.vp(16) }).backgroundColor('#F3F4F5');
  }
}

@Extend(Text)
function commonTextExtend() {
  .fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'));
}