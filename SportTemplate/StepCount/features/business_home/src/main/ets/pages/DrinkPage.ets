import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { RouterMap, RouterUtils, WindowModel } from 'lib_common';
import { DrinkModel, DrinkParam } from '../models/DrinkModel';
import { DrinkVM } from '../viewmodels/DrinkVM';
import { DrinkRecord } from '../components/DrinkRecord';
import { HomeCommonConstants } from '../constants/HomeCommonConstants';

@Builder
export function drinkPageBuilder() {
  DrinkPage()
}

@ObservedV2
export class GlobalStore {
  @Trace drinkedWater: number = 0; // 需要共享的字符串
  @Trace lackWater: number = 0;
  @Trace drinkGoal: number = 2000;
  @Trace myDrinkCup: number = 200
  @Trace s: number[] = []
  @Trace lastDate: string = '' // 记录上次保存的日期

  getPersistenceName(): string {
    return 'SearchHistory';
  }

  toJson(): string {
    try {
      return JSON.stringify({
        drinkedWater: this.drinkedWater,
        lackWater: this.lackWater,
        drinkGoal: this.drinkGoal,
        myDrinkCup: this.myDrinkCup,
        lastDate: this.lastDate
      });
    } catch (error) {
      return '';
    }
  }

  fromJson(json: string): void {
    const obj = JSON.parse(json) as Partial<GlobalStore>;
    this.drinkedWater = obj.drinkedWater ?? 0;
    this.lackWater = obj.lackWater ?? 0;
    this.drinkGoal = obj.drinkGoal ?? 2000;
    this.myDrinkCup = obj.myDrinkCup ?? 2000;
    this.lastDate = obj.lastDate ?? '';
  }
}

@Entry
@ComponentV2
struct DrinkPage {
  windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Local drinkVM: DrinkVM = new DrinkVM()
  @Local isShowMyCup: boolean = false;
  @Local showSheet: boolean = false;
  @Local colorGradient: LinearGradient =
    new LinearGradient([{ color: '#FF0000FF', offset: 0 }, { color: '#FFFF0000', offset: 1 }])
  @Local isShowGoal: boolean = false
  @Local goalRange: string[] =
    ['500ml', '1000ml', '1500ml', '2000ml', '2500ml', '3000ml', '3500ml', '4000ml', '4500ml', '5000ml', '5500ml',
      '6000ml', '6500ml', '7000ml', '7500ml', '8000ml']
  @Local cupRange: string[] = [
    '50ml', '100ml', '150ml', '200ml', '250ml', '300ml', '350ml', '400ml', '450ml', '500ml',
    '550ml', '600ml', '650ml', '700ml', '750ml', '800ml', '850ml', '900ml', '950ml', '1000ml',
    '1050ml', '1100ml', '1150ml', '1200ml', '1250ml', '1300ml', '1350ml', '1400ml', '1450ml', '1500ml',
    '1550ml', '1600ml', '1650ml', '1700ml', '1750ml', '1800ml', '1850ml', '1900ml', '1950ml', '2000ml',
    '2050ml', '2100ml', '2150ml', '2200ml', '2250ml', '2300ml', '2350ml', '2400ml', '2450ml', '2500ml',
    '2550ml', '2600ml', '2650ml', '2700ml', '2750ml', '2800ml', '2850ml', '2900ml', '2950ml', '3000ml'
  ];
  @Local selcetGoal: number = -1
  @Local selcetDrinkCup: number = -1
  @Local currentTime: string = ''
  @Local store: GlobalStore = PersistenceV2.connect(GlobalStore, 'global', () => new GlobalStore())!;
  @Local swipeOffsets: Map<number, number> = new Map() // 记录每条记录的滑动偏移量
  @Local private percent: number = 0.4
  @Local private sliderWidth: number = 0 // 父容器宽，onAreaChange 获取

  aboutToAppear() {
    this.drinkVM.init()

    // 检查是否跨天
    const today = DrinkVM.dateToStr(new Date())
    if (this.store.lastDate !== today) {
      // 跨天了，重置今天的数据
      this.store.drinkedWater = 0
      this.store.lackWater = this.store.drinkGoal
      this.store.lastDate = today
      PersistenceV2.save(this.store.toJson())
    }

    // 加载今天的喝水记录和时间数据
    DrinkModel.drinkRecord = DrinkModel.drinkStorage(undefined, today)
    DrinkModel.drinkTime = DrinkModel.drinkTimeStorage(undefined, today)

    // 如果没有喝水记录，重置时间slider和喝水量为0
    if (DrinkModel.drinkRecord.length === 0) {
      DrinkModel.drinkTime = DrinkModel.initDrinkTime
      DrinkModel.drinkTimeStorage(DrinkModel.drinkTime, today)
      this.store.drinkedWater = 0
      this.store.lackWater = this.store.drinkGoal
      PersistenceV2.save(this.store.toJson())
    }

    if (DrinkModel.drinkTime.length === 0) {
      DrinkModel.drinkTime = DrinkModel.initDrinkTime
    }

    this.percent = Number(this.div(this.store.drinkedWater, this.store.drinkGoal))
    this.store.lackWater = this.store.drinkGoal - this.store.drinkedWater
  }

  distanceToGoal(): string {
    if (this.store.lackWater > 0) {
      return `还差${this.store.lackWater}ml`
    } else if (this.store.lackWater === 0) {
      return '已完成目标'
    }
    return `超过目标${-this.store.lackWater}ml`
  }

  // 删除喝水记录
  deleteDrinkRecord(index: number) {
    const recordIndex = DrinkModel.drinkRecord.length - 1 - index
    if (recordIndex >= 0 && recordIndex < DrinkModel.drinkRecord.length) {
      const deleteItem = DrinkModel.drinkRecord[recordIndex]
      // 更新状态
      this.store.drinkedWater -= deleteItem.ml
      // 防止变成负数
      if (this.store.drinkedWater < 0) {
        this.store.drinkedWater = 0
      }
      this.store.lackWater = this.store.drinkGoal - this.store.drinkedWater
      // 删除记录
      DrinkModel.drinkRecord.splice(recordIndex, 1)
      const today = DrinkVM.dateToStr(new Date())
      DrinkModel.drinkStorage(DrinkModel.drinkRecord, today)
      // 同步更新 drinkTime（时间 slider 数据）
      const hourTime = DrinkModel.getCurrentHour00(deleteItem.time)
      DrinkModel.drinkTime.forEach(item => {
        if (item.time === hourTime) {
          item.ml -= deleteItem.ml
          // 防止变成负数
          if (item.ml < 0) {
            item.ml = 0
          }
        }
      })
      DrinkModel.drinkTimeStorage(DrinkModel.drinkTime, today)
      // 更新进度条
      this.percent = Number(this.div(this.store.drinkedWater, this.store.drinkGoal))
      PersistenceV2.save(this.store.toJson())
      this.swipeOffsets.set(index, 0)
      RouterUtils.replacePathByName(RouterMap.DRINK_PAGE)
    }
  }

  // 关闭其他已打开的删除按钮
  closeOtherDeleteButton(index: number) {
    this.swipeOffsets.forEach((value, key) => {
      if (key !== index && value < 0) {
        this.swipeOffsets.set(key, 0)
      }
    })
  }

  // 处理滑动手势
  handlePanGestureUpdate(event: GestureEvent, index: number): void {
    if (event.offsetX < 0) {
      // 左滑，限制最大滑动距离为 -(50vp删除按钮 + 10vp间距)
      const offset = Math.max(event.offsetX, -60)
      this.swipeOffsets.set(index, offset)
    } else if (event.offsetX > 0 && (this.swipeOffsets.get(index) ?? 0) < 0) {
      // 右滑回弹
      const currentOffset = this.swipeOffsets.get(index) ?? 0
      const newOffset = Math.min(currentOffset + event.offsetX, 0)
      this.swipeOffsets.set(index, newOffset)
    }
  }

  // 处理滑动手势结束事件
  handlePanGestureEnd(index: number): void {
    // 判断是否滑动超过阈值（30vp）
    if ((this.swipeOffsets.get(index) ?? 0) < -30) {
      // 完全展开删除按钮，距离为 -(50vp + 10vp)
      this.swipeOffsets.set(index, -60)
    } else {
      // 回弹
      this.swipeOffsets.set(index, 0)
    }
  }

  // 点击收起删除按钮
  closeDeleteButton(index: number): void {
    if ((this.swipeOffsets.get(index) ?? 0) < 0) {
      this.swipeOffsets.set(index, 0)
    }
  }

  // 计算删除按钮宽度
  private calculateDeleteButtonWidth(index: number): number {
    const offset = Math.abs(this.swipeOffsets.get(index) ?? 0)
    if (offset <= 10) {
      return 0
    }
    return Math.min((offset - 10) * 50 / 50, 50) // 从10vp开始显示，到60vp时宽度为50
  }

  // 计算删除按钮透明度
  private calculateDeleteButtonOpacity(index: number): number {
    const offset = Math.abs(this.swipeOffsets.get(index) ?? 0)
    if (offset <= 10) {
      return 0
    }
    return Math.min((offset - 10) / 50, 1) // 从10vp开始显示，到60vp时完全不透明
  }

  // 计算删除按钮左边距
  private calculateDeleteButtonMargin(index: number): number {
    const offset = Math.abs(this.swipeOffsets.get(index) ?? 0)
    if (offset <= 10) {
      return 0
    }
    return Math.min((offset - 10) * 10 / 50, 10) // 从10vp开始显示，到60vp时间距为10
  }

  build() {
    NavDestination() {
      Column() {
        // 标题
        this.titleBuilder()

        // 喝水目标
        this.contentBuilder()
      }
      .height(HomeCommonConstants.FULL_PERCENT)
      .padding({
        bottom: this.windowModel.windowBottomPadding,
      })
      .width(HomeCommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true).backgroundColor($r('app.color.color_F1F3F5'))
  }

  @Builder
  titleBuilder() {
    // 标题
    Column() {
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

        Text('喝水').fontSize(20).fontWeight(700).margin({ left: 8 })
        Blank()
        Image($r('app.media.prompt'))
          .width(16)
          .height(19)
          .draggable(false)
          .onClick(() => {
            RouterUtils.pushPathByName(RouterMap.DRINK_WARN_PAGE)
          })
      }
      .width(HomeCommonConstants.PERCENT_100)
      .height($r('app.float.nav_header_height'))
    }
    .padding({
      right: HomeCommonConstants.NUMBER_16,
      left: HomeCommonConstants.NUMBER_16,
      top: this.windowModel.windowTopPadding,
    })
    .width(HomeCommonConstants.FULL_PERCENT)
  }

  // 内容
  @Builder
  contentBuilder() {
    Scroll() {
      Column({ space: 16 }) {
        if (this.drinkVM.isToday) {
          // 当天喝水记录
          this.todayDrinkRecordBuilder()
        } else {
          // 非当天喝水记录
          DrinkRecord({
            drinkVM: this.drinkVM
          })
        }
      }
      .padding({
        left: 16,
        right: 16,
        top: 16,
        bottom: 16
      })
    }
    .layoutWeight(1)
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
  }

  // 当天喝水记录
  @Builder
  todayDrinkRecordBuilder() {
    // 喝水量
    this.drinkWaterBuilder()

    // 喝水记录
    this.drinkRecordBuilder()

    // 顶部时间轴
    this.timeLineBuilder()
  }

  // 喝水量
  @Builder
  drinkWaterBuilder() {
    Column() {
      Row() {
        Row({ space: 10 }) {
          Text($r('app.string.water_intake'))
            .fontColor($r('app.color.color_e6333333'))
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Start)
        }

        // 日期切换
        Row({ space: 8 }) {
          Stack() {
            Column()
              .width(0)
              .height(0)
              .border({
                width: {
                  left: 0,
                  right: 6,
                  top: 6,
                  bottom: 6
                },
                color: {
                  left: Color.Transparent,
                  right: '#979797',
                  top: Color.Transparent,
                  bottom: Color.Transparent
                }
              })
              .onClick(() => {
                this.drinkVM.changeDate(true)
              })
            Column()
              .width(16)
              .height(16)
              .onClick(() => {
                this.drinkVM.changeDate(true)
              })
          }

          Text(this.drinkVM.currentDateStr)
            .fontSize(HomeCommonConstants.NUMBER_12)
            .fontColor($r('app.color.color_black'))
          Stack() {
            Column()
              .width(0)
              .height(0)
              .border({
                width: {
                  left: 6,
                  right: 0,
                  top: 6,
                  bottom: 6
                },
                color: {
                  left: '#979797',
                  right: Color.Transparent,
                  top: Color.Transparent,
                  bottom: Color.Transparent
                }
              })
            Column()
              .width(16)
              .height(16)
              .onClick(() => {
                this.drinkVM.changeDate(false)
              })
          }
        }
        .margin({ left: 10 })

        Blank()
        // 加号
        Row({ space: 6 }) {
          Image($r('app.media.water_plus')).size({ width: 21, height: 21 })
            .onClick(() => {
              this.currentTime = this.getCurrentHM()
              this.store.drinkedWater += this.store.myDrinkCup
              this.store.lackWater = this.store.drinkGoal - this.store.drinkedWater
              this.store.lastDate = DrinkVM.dateToStr(new Date())
              DrinkModel.addDrink(this.currentTime, this.store.myDrinkCup)
              this.percent = Number(this.div(this.store.drinkedWater, this.store.drinkGoal))
              RouterUtils.replacePathByName(RouterMap.DRINK_PAGE)
              PersistenceV2.save(this.store.toJson());
            })
        }
      }.width(HomeCommonConstants.PERCENT_100)

      Stack() {
        Slider({
          style: SliderStyle.NONE,
          value: this.percent * this.store.drinkGoal,
          min: 0,
          max: this.store.drinkGoal,
        })
          .enabled(false)
          .trackThickness(8)
          .selectedBorderRadius(6)
          .width(HomeCommonConstants.PERCENT_100)
          .onChange(val => this.percent = val / this.store.drinkGoal)

        // 2. 自己画的"滑块"
        Column() {
          Image($r('app.media.slider_block')).width(16)
          Row({ space: 1 }) {
            Text(this.store.drinkedWater?.toString() ?? '0')
              .fontColor('#333')
              .fontSize(12)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .textAlign(TextAlign.End)
            Text('ml').fontColor('#333').fontSize(10)
          }
          .offset({
            x: this.store.drinkedWater?.toString().length > 3 ?
              -this.store.drinkedWater?.toString().length * 3 : 0
          })
        }
        .width(100)
        .borderRadius(16)
        .offset({
          // 3. 跟随滑动（端点精确对齐：0 最左端，1 最右端；中间线性插值）
          x: (() => {
            const p = Math.min(Math.max(this.percent, 0), 1);
            if (p <= 0) {
              return -this.sliderWidth / 2 + 5;
            }
            if (p >= 1) {
              return this.sliderWidth / 2 - 5;
            }
            return p * (this.sliderWidth - 32) - (this.sliderWidth / 2 - 16);
          })(),
          y: 20
        })
        .hitTestBehavior(HitTestMode.Transparent) // 4. 手势透传

      }.height(80)
      .onAreaChange((_, rect) => this.sliderWidth = Number(rect.width))

      Divider().strokeWidth('1px').color($r('sys.color.comp_background_tertiary'))

      // 喝水量值
      Row() {
        Column({ space: 6 }) {
          Row({ space: 3 }) {
            Row() {
            }.backgroundColor('#3E78F7').width(3).height(11).borderRadius(1.5)

            Text($r('app.string.my_cup')).fontSize(12).lineHeight(16).fontColor('#999999')
            Image($r('app.media.edit_water')).size({ width: 11, height: 11 })
          }

          Row({ space: 3 }) {
            Text(this.store.myDrinkCup?.toString())
              .fontSize(20)
              .fontColor('#333333')
              .fontWeight(FontWeight.Bold)
            Text('ml').fontSize(11).fontColor('#999999')
          }
          .bindSheet($$this.isShowMyCup, this.cupSheet(), {
            height: SheetSize.FIT_CONTENT,
            showClose: false,
            preferType: SheetType.CENTER
          })
        }.onClick(() => {
          this.isShowMyCup = true
        })

        Text(this.distanceToGoal()).fontColor('#999999').fontSize(12)
        Column({ space: 6 }) {
          Row({ space: 3 }) {
            Row() {
            }.backgroundColor('#0DBA72').width(3).height(11).borderRadius(1.5)

            Text($r('app.string.my_goal')).fontSize(12).lineHeight(16).fontColor('#999999')
            Image($r('app.media.edit_water')).size({ width: 11, height: 11 })
          }

          Row({ space: 3 }) {
            Text(this.store.drinkGoal?.toString()).fontSize(20).fontColor('#333333').fontWeight(FontWeight.Bold)
            Text('ml').fontSize(11).fontColor('#999999')
          }
          .bindSheet($$this.isShowGoal, this.goalSheet(), {
            height: SheetSize.FIT_CONTENT,
            showClose: false,
            preferType: SheetType.CENTER
          })
        }
        .onClick(() => {
          this.isShowGoal = true
        })
      }.width(HomeCommonConstants.PERCENT_100).justifyContent(FlexAlign.SpaceBetween).margin({ top: 19 })
    }
    .width(HomeCommonConstants.PERCENT_100)
    .height(188)
    .borderRadius(12)
    .backgroundColor('#FFFFFF')
    .padding({
      left: 20,
      top: 17,
      right: 17,
      bottom: 28
    })
  }

  // 喝水记录
  @Builder
  drinkRecordBuilder() {
    Text($r('app.string.drink_record'))
      .fontWeight(700)
      .width(HomeCommonConstants.PERCENT_100)
      .lineHeight(22)
      .textAlign(TextAlign.Start)
    Column({ space: 10 }) {
      ForEach([...DrinkModel.drinkRecord].reverse(),
        (item: DrinkParam, index: number) => {
          this.drinkCardBuilder(item, index)
        }, (index: number) => `${Date.now()}-${index}`)
    }
    .padding({
      top: 18,
      bottom: 18,
      left: 16,
      right: 16
    })
    .width(HomeCommonConstants.PERCENT_100)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder
  drinkCardBuilder(item: DrinkParam, index: number) {
    Row() {
      // 喝水记录（左侧，宽度动态变化）
      Row({ space: 12 }) {
        Image($r('app.media.water')).width(40).height(40)
        Column() {
          Text($r('app.string.water'))
            .fontColor('#333333')
            .fontWeight(FontWeight.Bold)
            .fontSize(16)
            .width(HomeCommonConstants.PERCENT_100)
          Row({ space: 4 }) {
            Image($r('app.media.ring')).size({ width: 8, height: 8 })
            Text(item.time)
              .fontColor('#80000000')
              .fontSize(10)
              .fontWeight(FontWeight.Bold)
              .lineHeight(11)
          }.width(HomeCommonConstants.PERCENT_100)
        }.width(40)

        Text(item.ml + 'ml')
          .fontColor('#333333')
          .fontWeight(FontWeight.Bold)
          .fontSize(22)
          .textAlign(TextAlign.End)
          .layoutWeight(1)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .border({ width: 1, color: '#E0E3EE' })
      .borderRadius(12)
      .padding({
        top: 12,
        right: 13,
        bottom: 10,
        left: 13
      })
      .width(`calc(100% - ${Math.abs(this.swipeOffsets.get(index) ?? 0)}vp)`)
      .backgroundColor('#FFFFFF')
      .animation({ duration: 300, curve: Curve.Smooth })
      .gesture(
        PanGesture({ direction: PanDirection.Horizontal })
          .onActionStart(() => {
            // 关闭其他已打开的删除按钮
            this.closeOtherDeleteButton(index)
          })
          .onActionUpdate((event: GestureEvent) => {
            this.handlePanGestureUpdate(event, index)
          })
          .onActionEnd((event: GestureEvent) => {
            // 判断是否滑动超过阈值（30vp）
            this.handlePanGestureEnd(index)
          })
      )
      .onClick(() => {
        // 点击收起删除按钮
        this.closeDeleteButton(index)
      })

      // 删除按钮（右侧，宽度和透明度动态变化）
      Row() {
        Text('删除')
          .fontColor('#FFFFFF')
          .fontSize(14)
      }
      .width(this.calculateDeleteButtonWidth(index))
      .height(62)
      .borderRadius(12)
      .backgroundColor('#FF4444')
      .justifyContent(FlexAlign.Center)
      .opacity(this.calculateDeleteButtonOpacity(index))
      .animation({ duration: 300, curve: Curve.Smooth })
      .margin({
        left: this.calculateDeleteButtonMargin(index)
      })
      .onClick(() => {
        // 删除逻辑
        this.deleteDrinkRecord(index)
      })
    }
    .width(HomeCommonConstants.PERCENT_100)
    .height(72)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  // 底部时间轴
  @Builder
  timeLineBuilder() {
    Column({ space: 8 }) {
      Row() {
        ForEach(DrinkModel.drinkTime, (item: DrinkParam) => {
          Slider({
            value: item.ml,
            direction: Axis.Vertical,
            style: SliderStyle.NONE,
            reverse: true,
            max: this.store.drinkGoal// 竖向的Slider默认是上端是min值，下端是max值，因此想要从下往上滑动，需要设置reverse为true
          })
            .enabled(false)
            .selectedColor('#34A2F8')
            .width('4%')
            .trackThickness('8')// 滑轨粗细，单位 vp
            .selectedBorderRadius(4)
        }, (item: DrinkParam) => JSON.stringify(item))
      }.justifyContent(FlexAlign.SpaceBetween).height(115)

      Row() {
        Text('00:00').fontColor('#809FB8').fontSize(12)
        Text('12:00').fontColor('#809FB8').fontSize(12)
        Text('24:00').fontColor('#809FB8').fontSize(12)
      }.justifyContent(FlexAlign.SpaceBetween).width(HomeCommonConstants.PERCENT_100)
    }
    .width(HomeCommonConstants.PERCENT_100)
    .height(162)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .padding({
      right: 17,
      left: 14,
      top: 14,
      bottom: 13
    })
  }

  @Builder
  goalSheet() {
    Column() {
      Row() {
        Text($r('app.string.goal')).fontSize(20).fontWeight(700).margin({ left: 8 })
        Blank()
        Image($r('app.media.ic_close_sheet')).width(40).height(40).onClick(() => {
          this.isShowGoal = false;
        })
      }
      .width(HomeCommonConstants.PERCENT_100)
      .height(56)

      TextPicker({
        range: this.goalRange,
        selected: this.store.drinkGoal ? this.goalRange.findIndex(item => item === this.store.drinkGoal + 'ml') : 5
      })
        .onChange((value: string | string[]) => {
          const str = Array.isArray(value) ? value[0] : value;
          this.selcetGoal = Number(str.match(/\d+/)?.[0] ?? 0);
        })
        .divider({ color: '#33000000' })
        .selectedTextStyle({
          color: '#000',
          font: {
            weight: FontWeight.Bold,
            size: 20,
          }
        })
      Column() {
        Button($r('app.string.save'))
          .width(HomeCommonConstants.PERCENT_100)
          .fontColor($r('sys.color.font_on_primary'))
          .height(40)
          .backgroundColor('#FC7A17')
          .onClick(() => {
            this.isShowGoal = false;
            if (this.selcetGoal) {
              this.store.drinkGoal = this.selcetGoal
            } else {
              this.store.drinkGoal = 3000
            }
            if (this.selcetGoal === -1) {
              this.store.drinkGoal = 500
            }
            this.store.lackWater = this.store.drinkGoal - this.store.drinkedWater
            RouterUtils.replacePathByName(RouterMap.DRINK_PAGE)
          })
      }
      .justifyContent(FlexAlign.End)
      .padding({
        left: 6,
        bottom: 12,
        top: 28,
        right: 6,
      })
    }.padding({ left: 16, right: 16, bottom: 12 })
  }

  @Builder
  cupSheet() {
    Column() {
      Row() {
        Text($r('app.string.cup')).fontSize(20).fontWeight(700).margin({ left: 8 })
        Blank()
        Image($r('app.media.ic_close_sheet')).width(40).height(40).onClick(() => {
          this.isShowMyCup = false;
        })
      }
      .width(HomeCommonConstants.PERCENT_100)
      .height(56)

      TextPicker({
        range: this.cupRange,
        selected: this.store.myDrinkCup ? this.cupRange.findIndex(item => item === this.store.myDrinkCup + 'ml') : 5
      })
        .onChange((value: string | string[], index: number | number[]) => {
          const str = Array.isArray(value) ? value[0] : value;
          this.selcetDrinkCup = Number(str.match(/\d+/)?.[0] ?? 0);
        })
        .divider({ color: '#33000000' })
        .selectedTextStyle({
          font: {
            size: 20,
            weight: FontWeight.Bold,
          },
          color: '#000',
        })

      Column() {
        Button($r('app.string.save'))
          .width(HomeCommonConstants.PERCENT_100)
          .height(40)
          .backgroundColor('#FC7A17')
          .fontColor($r('sys.color.font_on_primary'))
          .onClick(() => {
            if (!this.selcetDrinkCup) {
              this.selcetDrinkCup = 300
            }
            if (this.selcetDrinkCup === -1) {
              this.selcetDrinkCup = 50
            }
            this.store.myDrinkCup = this.selcetDrinkCup
            this.getUIContext().getPromptAction().showToast({ message: '保存成功' })
            this.store.lackWater = this.store.drinkGoal - this.store.drinkedWater
            this.isShowMyCup = false;

          })
      }
      .justifyContent(FlexAlign.End)
      .padding({
        right: 6,
        bottom: 12,
        left: 6,
        top: 28
      })
    }
    .width(HomeCommonConstants.PERCENT_100)
    .padding(12)
  }

  isInRange(n: string | number): boolean {
    const v = Number(n); // 先转数字
    return !Number.isNaN(v) && v >= 1 && v <= this.store.drinkGoal;
  }

  div(a: number, b: number): string {
    const v = Math.round((a / b) * 10) / 10; // 保留一位
    return v % 1 === 0 ? String(Math.trunc(v)) : v.toFixed(1);
  }

  getCurrentHM(): string {
    const d = new Date();
    return `${d.getHours().toString().padStart(2, '0')}:${d.getMinutes().toString().padStart(2, '0')}`;
  }
}