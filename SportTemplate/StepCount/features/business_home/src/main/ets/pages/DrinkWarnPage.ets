import { CommonConfirmDialog, RouterUtils, WindowModel } from 'lib_common'
import { DrinkWarnParam } from '../models/DrinkModel'
import { DrinkWarnViewModel } from '../viewmodels/DrinkWarnViewModel'
import { TargetReminderAgentHelper } from '../util/TargetReminderAgentHelper'
import { AppStorageV2 } from '@kit.ArkUI'

@Builder
export function drinkWarnPageBuilder() {
  DrinkWarnPage()
}

@ObservedV2
class PromptWarnParam {
  @Trace text: string = ''
  @Trace isSelected: boolean = false

  constructor(text: string, isSelected: boolean) {
    this.text = text
    this.isSelected = isSelected
  }
}

@Entry
@ComponentV2
struct DrinkWarnPage {
  @Local isShowDel: boolean = false
  @Local selectedTab: number = 0
  @Local isShowContent: boolean = false
  @Local isShowTime: boolean = false
  @Local promptContent: PromptWarnParam[] =
    [
      new PromptWarnParam('喝水时间到啦，记得喝水哦~', false),
      new PromptWarnParam('要想美，多喝水!', false),
      new PromptWarnParam('天干物燥，多多喝水', false),
      new PromptWarnParam('学习再累，工作再苦，也要记得喝水哦~', false),
      new PromptWarnParam('为了健康，该喝水啦.', false),
    ]
  @Local isMilitaryTime: boolean = false;
  @Local selectTime: string = '' // 选中的时间
  @Local isShowAdd: boolean = false
  private vm: DrinkWarnViewModel = DrinkWarnViewModel.getInstance()
  windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  private selectedTime: Date = new Date('2022-07-22T08:00:00');

  aboutToAppear(): void {
    this.vm.init();
    this.vm.getWarnTimes();
  }

  build() {
    NavDestination() {
      Column() {
        // 标题
        Row() {
          Stack() {
            Image($r('app.media.ellipse')).width(40).height(40)
              .backgroundColor('#0d000000').borderRadius('50%')
            Image($r('app.media.arrow_left'))
              .width(24)
              .height(24)
              .draggable(false)
          }
          .onClick(() => {
            RouterUtils.pop()
          })

          Text('喝水提醒设置').fontSize(20).fontWeight(700).margin({ left: 8 }).lineHeight(28)
        }.padding({ left: 16, right: 16 })
        .width('100%')
        .height(48)
        .margin({ bottom: 15 })

        // Tab bar
        Row() {
          Column() {
            Text('时间设置')
              .fontSize(16)
              .fontColor(this.selectedTab === 0 ? '#FF6017' : '#e6000000')
            Row()
              .width(34)
              .height(2)
              .backgroundColor(this.selectedTab === 0 ? '#FF6017' : Color.Transparent)
              .margin({ top: 6 })
          }
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            this.selectedTab = 0
          })

          Column() {
            Text('提醒方式设置')
              .fontSize(16)
              .fontColor(this.selectedTab === 1 ? '#FF6017' : '#e6000000')
            Row()
              .width(34)
              .height(2)
              .backgroundColor(this.selectedTab === 1 ? '#FF6017' : Color.Transparent)
              .margin({ top: 6 })
          }
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            this.selectedTab = 1
          })
        }
        .width('100%')
        .height(48)
        .justifyContent(FlexAlign.SpaceEvenly)

        // Tab content container
        Column() {
          if (this.selectedTab === 0) {
            Scroll() {
              if (this.isShowAdd) {
                Column() {

                  Column({ space: 16 }) {
                    Row() {
                      Row({ space: 16 }) {
                        Image($r('app.media.alarm_black')).width(24).height(24)
                        Text('提醒时间').fontWeight(FontWeight.Bold)
                      }

                      Blank()
                      Row({ space: 4 }) {
                        Text(this.vm.promptTime)
                          .fontColor($r('sys.color.mask_secondary'))
                          .fontSize(14)
                        Image($r('app.media.alarm_right')).width(12).height(24)

                      }
                      .bindSheet($$this.isShowTime, this.timeSheet(), {
                        height: SheetSize.FIT_CONTENT,
                        showClose: false,
                        preferType: SheetType.CENTER
                      })
                    }
                    .onClick(() => {
                      this.isShowTime = true;
                    })
                    .borderRadius(12)
                    .width('100%')
                    .height(80)
                    .backgroundColor('#ffffff')
                    .justifyContent(FlexAlign.SpaceBetween)
                    .padding({
                      left: 12,
                      right: 12,
                      top: 16,
                      bottom: 16
                    })

                    Row() {
                      Row({ space: 16 }) {
                        Image($r('app.media.doc_plaintext')).width(24).height(24)
                        Text('提醒内容').fontWeight(FontWeight.Bold)
                      }

                      Blank()
                      Row({ space: 4 }) {
                        Text(this.vm.prompt)
                          .fontColor('#99000000')
                          .fontSize(14)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .maxLines(1)
                          .width('90%')
                        Image($r('app.media.alarm_right')).width(12).height(24)
                          .bindSheet($$this.isShowContent, this.contentSheet(), {
                            height: SheetSize.FIT_CONTENT,
                            showClose: false,
                            preferType: SheetType.CENTER
                          })
                      }.width('50%').justifyContent(FlexAlign.End)
                    }
                    .onClick(() => {
                      this.isShowContent = true;
                    })
                    .borderRadius(12)
                    .width('100%')
                    .height(80)
                    .backgroundColor('#ffffff')
                    .padding({
                      left: 12,
                      right: 12,
                      top: 16,
                      bottom: 16
                    })
                  }.layoutWeight(1).padding({ left: 16, right: 16 }).margin({ top: 24 })

                  Column() {
                    Button('确认')
                      .width('100%')
                      .height(40)
                      .fontColor($r('sys.color.font_on_primary'))
                      .backgroundColor('#FC7A17')
                      .onClick(async () => {
                        this.vm.sysWarnTimes().then((state) => {
                          // eslint-disable-next-line @hw-stylistic/space-before-blocks
                          if (state) {
                            this.isShowAdd = false
                            this.selectedTime = new Date('2022-07-22T08:00:00')
                          }
                        })
                      })
                  }
                  .justifyContent(FlexAlign.End)
                  .padding({
                    bottom: 15,
                    left: 6,
                    right: 6,
                    top: 28
                  })
                }
              } else {
                if (this.vm.warnTime.length !== 0) {
                  Column() {
                    Row() {
                      Text('定时提醒').fontSize(16).lineHeight(22).fontWeight(FontWeight.Bolder)
                      Text(this.isShowDel ? '取消删除' : '选择删除')
                        .fontSize(12)
                        .lineHeight(17)
                        .fontColor('#e6666666')
                        .onClick(() => {
                          this.isShowDel = !this.isShowDel
                        })
                    }.width('100%').justifyContent(FlexAlign.SpaceBetween)
                    .margin({ top: 16, bottom: 11 })

                    Column() {
                      ForEach(this.vm.warnTime, (item: DrinkWarnParam) => {
                        this.alramTime(item)
                      }, (item: DrinkWarnParam) => JSON.stringify(item))
                    }.backgroundColor('#fff').borderRadius(12).padding({ left: 15, right: 25, bottom: 28 })

                    Button('添加更多时间')
                      .width('250')
                      .height(40)
                      .fontColor($r('sys.color.warning'))
                      .backgroundColor('#0A131F35')
                      .onClick(() => {
                        this.isShowAdd = true
                      })
                      .margin({ top: 28 })
                  }.padding({ left: 16, right: 16 })
                } else {
                  Column() {
                    Column() {
                      Row() {
                        Text('定时提醒')
                          .fontSize(16)
                          .fontWeight(FontWeight.Bolder)
                          .width('100%')
                      }.width('100%').height(48)
                      .padding({ top: 13, bottom: 13 })
                      .justifyContent(FlexAlign.Start)

                      Row() {
                        Image($r('app.media.add_more')).size({ width: 15, height: 15 }).margin({ right: 4 })
                        Text('添加更多时间').fontColor('#e6000000')
                      }
                      .onClick(() => {
                        this.isShowAdd = true
                      })
                      .width('100%')
                      .height(88)
                      .backgroundColor('#0d000000')
                      .borderRadius(16)
                      .justifyContent(FlexAlign.Center)
                      .padding({ left: 16, right: 16 })
                    }
                    .width('100%')
                    .height(152)
                    .backgroundColor('#fff')
                    .borderRadius(16)
                    .padding({ left: 16, right: 16 })
                  }
                  .width('100%')
                  .height(152)
                  .margin({ top: 16 })
                  .padding({ left: 16, right: 16 })
                }
              }

            }
          } else {
            Column({ space: 16 }) {
              Row() {
                Row({ space: 16 }) {
                  Text($r('app.string.alert_prompt')).fontWeight(FontWeight.Bold)
                }

                Blank()
                Row({ space: 4 }) {
                  Text($r('app.string.popup_notification_for_timely_reminders'))
                    .fontColor('#99000000')
                    .fontSize(14)

                  Image(TargetReminderAgentHelper.getInstance().type === TargetReminderAgentHelper.TYPE_ALARM_CLOCK ?
                    $r('app.media.vector') : $r('app.media.unvector')).size({ width: 20, height: 20 })
                    .onClick(() => {
                      TargetReminderAgentHelper.getInstance().switchType(TargetReminderAgentHelper.TYPE_ALARM_CLOCK)
                    })
                }
              }
              .borderRadius(12)
              .width('100%')
              .height(80)
              .backgroundColor('#ffffff')
              .padding({
                left: 12,
                right: 12,
                top: 16,
                bottom: 16
              })

              Row() {
                Row({ space: 16 }) {
                  Text($r('app.string.push_notification')).fontWeight(FontWeight.Bold)
                }

                Blank()
                Row({ space: 4 }) {
                  Text($r('app.string.notification_from_Huawei'))
                    .fontColor('#99000000')
                    .fontSize(14)

                  Image(TargetReminderAgentHelper.getInstance().type === TargetReminderAgentHelper.TYPE_NOTICE ?
                    $r('app.media.vector') : $r('app.media.unvector')).size({ width: 20, height: 20 })
                    .onClick(() => {
                      TargetReminderAgentHelper.getInstance().switchType(TargetReminderAgentHelper.TYPE_NOTICE)
                    })
                }
              }
              .borderRadius(12)
              .width('100%')
              .height(80)
              .backgroundColor('#ffffff')
              .padding({
                left: 12,
                right: 12,
                top: 16,
                bottom: 16
              })
            }
            .padding({ left: 16, right: 16 })
            .margin({ top: 24 })
            .padding({ left: 16, right: 16 })
            .width('100%')
            .height('100%')
          }
        }
        .layoutWeight(1)
        .width('100%')
        .backgroundColor('#F1F3F5')
      }
      .padding({
        bottom: this.windowModel.windowBottomPadding,
      })
    }
    .backgroundColor('#fff')
    .hideTitleBar(true).padding({ top: 40 })
  }

  @Builder
  alramTime(item: DrinkWarnParam) {
    Row() {
      Row() {
        Stack() {
          Row().size({ width: 18, height: 18 }).backgroundColor('#D30B0B').borderRadius('50%')
          Row().size({ width: 14, height: 2 }).backgroundColor('#fff')
        }.visibility(this.isShowDel ? Visibility.Visible : Visibility.None)
        .onClick(() => {
          CommonConfirmDialog.show({
            priBtnFg: $r('app.color.color_99000000'),
            primaryTitle: '定时提示删除确认?',
            content: '确定要删除每天' + item.time + '的提醒吗？',
            confirm: () => {
              this.vm.deleteWarnTime(item.id)
            },
          })
        })

        Image($r('app.media.alarm')).width(16).height(16).margin({ left: 20 })
        Text(item.time).fontSize(18).lineHeight(21).margin({ left: 12 })
      }

      Row() {
        Toggle({ type: ToggleType.Switch, isOn: item.isOpen })
          .onChange((isOn: boolean) => {
            item.isOpen = isOn
            this.vm.updateByIsOpen(item)
          })

        Image($r('app.media.alarm_right')).width(12).height(24).margin({ left: 20 })
          .onClick(() => {
            this.isShowAdd = true;
            this.vm.params = item;
            this.vm.promptTime = item.time
            this.vm.prompt = item.prompt!
            this.selectedTime = this.toFullGMT(this.vm.params?.time)
          })
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .height(60)
    .border({ width: { bottom: 1 }, color: '#26979797' })
  }

  @Builder
  contentSheet() {
    Column() {
      Row() {
        Text('选择提示内容').fontSize(20).fontWeight(700).margin({ left: 8 })
        Blank()
        Image($r('app.media.ic_close_sheet')).width(40).height(40).onClick(() => {
          this.isShowContent = false;
        })
      }
      .width('100%')
      .height(56)

      Column() {
        ForEach(this.promptContent, (item: PromptWarnParam, index: number) => {
          Row() {
            Text(item.text).fontSize(16).fontColor('#99000000').lineHeight(24)
            Image($r('app.media.vector'))
              .width(21)
              .height(21)
              .visibility(item.isSelected ? Visibility.Visible : Visibility.Hidden)
          }
          .width('100%')
          .height(44)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 15, right: 17 })
          .onClick(() => {
            this.promptContent.forEach((item: PromptWarnParam, index: number) => {
              item.isSelected = false
            })
            this.promptContent.map((i: PromptWarnParam, index: number) => {
              if (i.text === item.text) {
                this.promptContent[index].isSelected = true
              }
            });
          })

          if (index !== this.promptContent.length - 1) {
            Divider().strokeWidth('1px').color($r('sys.color.comp_background_tertiary'))
          }
        }, (item: PromptWarnParam) => JSON.stringify(item))
      }.width('100%').borderRadius(16)

      Column() {
        Button('确认')
          .width('100%')
          .height(40)
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor('#FC7A17')
          .onClick(() => {
            this.isShowContent = false;
            this.promptContent.map((item: PromptWarnParam) => {
              if (item.isSelected) {
                this.vm.prompt = item.text
              }
            })
          })
      }
      .justifyContent(FlexAlign.End)
      .padding({
        bottom: 12,
        left: 6,
        right: 6,
        top: 28
      })
    }.padding({ left: 16, right: 16, bottom: 28 })
  }

  @Builder
  timeSheet() {
    Column() {
      Row() {
        Text('选择提醒时间').fontSize(20).fontWeight(700).margin({ left: 8 })
        Blank()
        Image($r('app.media.ic_close_sheet')).width(40).height(40).onClick(() => {
          this.isShowTime = false;
        })
      }
      .width('100%')
      .height(56)

      TimePicker({
        selected: this.selectedTime
      })
        .selectedTextStyle({
          // color: '#000',
          font: {
            size: 20,
            weight: FontWeight.Bold
          }
        })
        .useMilitaryTime(this.isMilitaryTime)
        .onChange((value: TimePickerResult) => {
          if (value.hour >= 0) {
            this.selectedTime.setHours(value.hour, value.minute);
          }
          this.selectTime = (this.digitCount(value.hour) === 1 ? '0' + value.hour :
            value.hour) + ':' + (this.digitCount(value.minute) === 1 ? '0' + value.minute : value.minute)
        })
      Column() {
        Button('确认')
          .width('100%')
          .height(40)
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor('#FC7A17')
          .onClick(() => {
            this.isShowTime = false;
            if (this.selectTime) {
              this.vm.promptTime = this.selectTime
            } else {
              this.vm.promptTime = '08:00'
            }
          })
      }
      .justifyContent(FlexAlign.End)
      .padding({
        bottom: 12,
        left: 6,
        right: 6,
        top: 28
      })
    }.padding({ left: 16, right: 16, bottom: 28 })
  }

  digitCount(n: number): number {
    return Math.abs(n).toString().length;
  }

  toFullGMT(timeStr: string) {
    const tmp = timeStr.split(':');
    const h = Number(tmp[0]);
    const m = Number(tmp[1]);
    const d = new Date();
    d.setHours(h, m, 0, 0);
    return d;
  }
}