import { ReservationCard } from '../components/ReservationCard';
import { AppointmentInfo, IAppointment } from '../common/Type';

@Entry
@ComponentV2
struct Sample1 {
  @Local list: AppointmentInfo[] = [
    new AppointmentInfo({
      reserveTime: 1767061800000,
      itemName: '法式美甲',
      contactName: '1号选手',
      contactPhone: '130****1212',
      numbers: 2,
      remarks: '大概会晚到一会',
      state: 10,
      setSchedule: 0,
      setSubscription: 0,
    } as IAppointment),
    new AppointmentInfo({
      reserveTime: 1755769268621,
      itemName: '猫眼美甲',
      contactName: '2号选手',
      contactPhone: '130****1212',
      numbers: 4,
      remarks: '',
      state: 30,
      setSchedule: 0,
      setSubscription: 0,
    } as IAppointment),
  ];

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 10 }) {
          ForEach(this.list, (v: AppointmentInfo, index: number) => {
            ReservationCard({
              appointInfo: v,
              // todo: 替换为实际的推送服务通知模板ID，多个ID以英文逗号(,)连接
              entityIds: 'xxx',
              cancelReservation: () => {
                this.list.splice(index, 1);
                this.getUIContext().getPromptAction().showToast({ message: '已取消预约' });
              },
            })
          }, (v: AppointmentInfo) => JSON.stringify(v))
        }
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .title('预约管理卡片列表')
    .backgroundColor($r('sys.color.background_secondary'))
    .padding(16)
  }
}