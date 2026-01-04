import { AppStorageV2 } from '@kit.ArkUI';
import { CommonConstants, UserInfoModel, WindowModel } from 'lib_common';

@Builder
export function SelectDeliveryTimeBuilder(selected: string, confirmDeliveryTime: (deliveryTime: string) => void) {
  SelectDeliveryTime({
    selected: selected ? selected : '立即送出',
    confirmDeliveryTime: confirmDeliveryTime
  })
}

@ComponentV2
export struct SelectDeliveryTime {
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local userInfoModel: UserInfoModel = AppStorageV2.connect(UserInfoModel, () => new UserInfoModel())!;
  // 选中地址id
  @Param @Require selected: string = '';
  @Local list: string[] = getSmartDeliverySegments(96); //24小时
  @Event
  confirmDeliveryTime: (deliveryTime: string) => void = () => {
    // do nothing.
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          ForEach(this.list, (item: string) => {
            Divider()
              .color($r('sys.color.comp_divider'))
              .strokeWidth('1px')
            Column() {
              Row() {
                Column() {
                  Text(item)
                    .fontColor(this.selected === item ? $r('app.color.app_theme') : $r('sys.color.black'))
                }.width('90%')

                Checkbox({ name: 'channelCheckBox', group: 'checkboxGroup' })
                  .select((this.selected ? this.selected : '立即配送') === item)
                  .shape(CheckBoxShape.CIRCLE)
                  .onChange((value: boolean) => {
                    if (value) {
                      this.confirmDeliveryTime(item)
                    }
                  });
              }
              .justifyContent(FlexAlign.Start)
              .borderRadius(16)
              .padding({
                top: CommonConstants.PADDING_S,
                bottom: CommonConstants.PADDING_S
              })
              .margin({ bottom: CommonConstants.PADDING_S })
            }
          }, (item: string) => item)
        }

      }
      .layoutWeight(1)
      .width(CommonConstants.FULL_PERCENT)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .padding({
      left: CommonConstants.PADDING_S,
      right: CommonConstants.PADDING_S,
      bottom: this.windowModel.windowBottomPadding,
      top: 10
    })
  }
}

function getSmartDeliverySegments(segmentCount: number = 8): string[] {
  const segments: string[] = ['立即送出'];
  const now = new Date();

  // 计算下一个15分钟锚点
  const currentMinutes = now.getMinutes();
  let nextAnchorMinutes = (Math.floor(currentMinutes / 15) + 1) * 15;
  let nextAnchorHours = now.getHours();

  // 处理分钟数超过60的情况
  if (nextAnchorMinutes >= 60) {
    nextAnchorMinutes = 0;
    nextAnchorHours += 1;
  }

  const startAnchorTime = new Date(now);
  startAnchorTime.setHours(nextAnchorHours, nextAnchorMinutes, 0, 0);

  // 生成后续时间段
  for (let i = 0; i < segmentCount - 1; i++) {
    const startTime = new Date(startAnchorTime.getTime() + i * 15 * 60 * 1000);
    const endTime = new Date(startTime.getTime() + 15 * 60 * 1000);

    const formatDate = (date: Date): string => {
      const today = new Date();
      const tomorrow = new Date(today);
      tomorrow.setDate(today.getDate() + 1);

      // 检查是否是今天
      if (checkSameDay(date, today)) {
        return '今天';
      } else if (checkSameDay(date, tomorrow)) { // 检查是否是明天
        return '明天';
      } else { // 其他情况显示完整日期
        const year = date.getFullYear();
        const month = date.getMonth() + 1;
        const day = date.getDate();
        return `${year}年${month}月${day}日`;
      }
    };
    const formatTime = (date: Date): string => {
      const hours = date.getHours().toString().padStart(2, '0');
      const minutes = date.getMinutes().toString().padStart(2, '0');
      return `${hours}:${minutes}`;
    };

    segments.push(`${formatDate(startTime)} ${formatTime(startTime)}-${formatTime(endTime)}`);
  }

  return segments;
}

function checkSameDay(date: Date, otherDate: Date) {
  return date.getDate() === otherDate.getDate() &&
    date.getMonth() === otherDate.getMonth() &&
    date.getFullYear() === otherDate.getFullYear()
}
