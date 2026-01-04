import { CareerObjectiveItem, CareerObjectiveModel } from '../viewmodel/CareerObjectiveModel'
import { InfoRow } from './InfoRow'
import { GlobalContext } from '../common/GlobalContext';
import { common } from '@kit.AbilityKit';

@ComponentV2
export struct JobIntentions {
  @Local vm: CareerObjectiveModel | undefined = undefined
  @Event goToDetail: (index: number, item?: CareerObjectiveItem) => void = () => {
  };
  private abilityContext: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  async aboutToAppear() {
    await GlobalContext.initUIAbilityContext(this.abilityContext);
    this.vm = CareerObjectiveModel.instance
  }

  build() {
    Column() {
      // 标题和描述
      Column() {
        Text('想找什么工作?')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
          .width('100%')
          .margin({ bottom: 8 })

        Text('填写想找的工作，为您精准匹配适合的职位')
          .fontSize(14)
          .fontColor('rgba(0,0,0,0.45)')
          .width('100%')
      }
      .width('100%')
      .padding({
        top: 20,
        bottom: 20
      })
      .alignItems(HorizontalAlign.Start)

      Column() {
        Row() {
          Column() {
          }
          .width(4).height(19).backgroundColor('#FF564AF7').borderRadius(2)

          Text('全职意向')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#000000')
            .margin({ left: 8 })
          Blank()
        }
        .width('100%').margin({ bottom: 16 })

        // 全职意向列表
        this.intentionList('全职')

        Divider().strokeWidth('1px').margin({ top: 16, bottom: 16 })

        // 兼职意向
        Row() {
          Column() {
          }
          .width(4).height(19).backgroundColor('#FF564AF7').borderRadius(2)

          Text('兼职意向')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#000000')
            .margin({ left: 8 })
          Blank()
        }
        .width('100%').margin({ bottom: 16 })

        // 兼职意向列表
        this.intentionList('兼职')

        // 添加新的求职期望按钮
        Row() {
          Image($r('app.media.plus'))
            .width(20)
            .height(20)
            .fillColor('#5B6FFF')
            .margin({ right: 8 })

          Text('添加新的求职期望')
            .fontSize(14)
            .fontColor('#5B6FFF')
        }
        .width('100%')
        .height(48)
        .justifyContent(FlexAlign.Center)
        .border({ width: 1, color: '#5B6FFF', radius: 8 })
        .margin({
          left: 16,
          right: 16,
          top: 20
        })
        .onClick(() => {
          this.goToDetail(-1)
        })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
      .margin({ bottom: 16 })
      .padding(16)

      // 求职状态
      Row() {
        InfoRow({
          title: '求职状态',
          titleFontSize: 14,
          valueFontSize: 12,
          value: this.vm?.jobStatus || '请选择求职状态',
          isSecondary: !this.vm?.jobStatus,
          heightValue: 48,
          onClickRow: () => {
            this.TextPicker()
          }
        })
      }
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  intentionList(jobType: string) {
    Column() {
      ForEach(this.vm?.items.filter((item: CareerObjectiveItem) => item.jobType === jobType),
        (item: CareerObjectiveItem, index: number) => {
          Column() {
            Row() {
              Column() {
                Text(`[${item.city}]${item.position}`)
                  .fontSize(16)
                  .fontColor('#000000')
                  .width('100%')
                  .margin({ bottom: 4 })

                Text(`${item.salary} | ${item.industry} | ${item.jobType}`)
                  .fontSize(14)
                  .fontColor('rgba(0,0,0,0.45)')
                  .width('100%')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Image($r('app.media.right'))
                .width(16)
                .height(16)
                .fillColor('rgba(0,0,0,0.45)')
            }
            .width('100%')
            .padding({
              left: 16,
              right: 16,
              top: 20
            })
            .onClick(() => {
              // 找到该 item 在完整列表中的真实索引
              const realIndex = this.vm!.items.indexOf(item)
              this.goToDetail(realIndex, item)
            })

          }
        }, (item: CareerObjectiveItem, index: number) => `${JSON.stringify(item)}_${index}}`)
    }
  }

  // 求职状态选择
  TextPicker() {
    let range: string[] = ['离职-正在找工作', '在职-考虑机会', '在职-暂不考虑'];
    let selectedIndex = 0;

    this.getUIContext().showTextPickerDialog({
      range: range,
      selected: selectedIndex,
      defaultPickerItemHeight: 40,
      cancelButtonStyle: { fontColor: '#666666' },
      onAccept: (value: TextPickerResult) => {
        const selectedValue = value.value as string;
        this.vm!.jobStatus = selectedValue
      },
    })
  }
}
