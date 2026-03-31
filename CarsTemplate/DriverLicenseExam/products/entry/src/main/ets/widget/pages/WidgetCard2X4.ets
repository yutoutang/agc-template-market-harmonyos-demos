import formProvider from '@ohos.app.form.formProvider';

const PROGRESS:string[] = ['科目一','科目二','科目三','科目四']

@Entry
@Component
struct WidgetCard {
  /*
   * The title.
   */
  readonly title: string = 'Hello World';
  /*
   * The action type.
   */
  readonly actionType: string = 'router';
  /*
   * The ability name.
   */
  readonly abilityName: string = 'EntryAbility';
  /*
   * The message.
   */
  readonly message: string = 'add detail';
  /*
   * The width percentage setting.
   */
  readonly fullWidthPercent: string = '100%';
  /*
   * The height percentage setting.
   */
  readonly fullHeightPercent: string = '100%';

  @LocalStorageProp('index') @Watch('indexChange') index:number = 0;
  @LocalStorageProp('didCount') didCount:number = 0;
  @LocalStorageProp('totalCount') totalCount:number = 0;
  @State currentProgress:string = PROGRESS[this.index];

  indexChange() {
    this.currentProgress = PROGRESS[this.index];
  }

  @Styles
  btnStyle () {
  .width(130)
  .height(28)
  .padding({
    left: 8,
    top: 4,
    right: 8,
    bottom: 4,
  })
  .borderRadius(14)
  .backgroundColor('#64bb5c')
}

  build() {
    Column({space:12}) {
      Row() {
        Image($r('app.media.app_icon'))
          .width(20)
          .height(20)
          .margin({right:8})
          .borderRadius(4)
        Text('驾考')
          .fontSize('12vp')
          .fontColor('#000000')
          .fontWeight(400)
      }
      .width(this.fullWidthPercent)
      .justifyContent(FlexAlign.Start)
      Row() {
        Text(`当前进度-${this.currentProgress}`)
          .fontFamily('HarmonyHeiTi')
          .fontColor('#000000')
          .fontSize('14vp')
          .fontWeight(500)
          .lineHeight('19vp')
      }
      .width(this.fullWidthPercent)

      Row() {
        Text('顺序练习')
          .fontFamily('HarmonyHeiTi')
          .fontColor('#000000')
          .fontSize('14vp')
          .fontWeight(500)
          .lineHeight('19vp')
          .margin({right:12})
        Text(`练习进度: ${this.didCount}/${this.totalCount}`)
          .fontFamily('HarmonyHeiTi')
          .fontColor('#000000')
          .fontSize('12vp')
          .fontWeight(400)
          .lineHeight('16vp')
      }
      .width(this.fullWidthPercent)
      .justifyContent(FlexAlign.Start)

      Row() {
        Text('模拟考试')
          .btnStyle()
          .fontFamily('HarmonyHeiTi')
          .fontColor('#FFFFFF')
          .fontSize('14vp')
          .fontWeight(500)
          .lineHeight('19vp')
          .textAlign(TextAlign.Center)
          .onClick(() => {
            postCardAction(this, {
              action: this.actionType,
              abilityName: this.abilityName,
              params: {
                message: 'practiceView'
              }
            });
          })

        Text('去练习')
          .btnStyle()
          .fontFamily('HarmonyHeiTi')
          .fontColor('#FFFFFF')
          .fontSize('14vp')
          .fontWeight(500)
          .lineHeight('19vp')
          .textAlign(TextAlign.Center)
          .onClick(() => {
            postCardAction(this, {
              action: this.actionType,
              abilityName: this.abilityName,
              params: {
                message: 'orderPractice'
              }
            });
          })
      }
      .width(this.fullWidthPercent)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .padding(12)
    .width(this.fullWidthPercent)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .onClick(() => {
      postCardAction(this, {
        action: this.actionType,
        abilityName: this.abilityName,
        params: {
          message: this.message
        }
      });
    })
  }
}