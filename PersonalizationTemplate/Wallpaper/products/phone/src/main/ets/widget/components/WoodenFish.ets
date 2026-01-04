@ObservedV2
class FloatText {
  id: number = 0;
  @Trace text: string = '';
  @Trace show: boolean = false;
  @Trace offsetY: number = 0
}

@ComponentV2
export struct WoodenFish {
  @Param cardSize: 'small' | 'medium' | 'large' = 'medium';
  @Param luckValue: number | string = 0;
  @Param count: string = '';
  @Param backgroundColorInfo: string = '#fff';
  @Param textColor: string = '#99000000';
  @Param woodenFishTitle: string = '好运';
  @Param backgroundImg: string = ''
  @Param soundEffect: boolean = true
  @Local translateValue: number = 0
  @Local textTranslateValue: number = 0
  @Local iconScaleOptions: ScaleOptions = { x: 1, y: 1 }
  @Local newLuckValue: number = 0
  @Local messageList: FloatText[] = [];
  private nextId = 0;

  aboutToAppear(): void {
    this.newLuckValue = Number(this.luckValue)
  }

  getFontSize(baseSize: number): number {
    switch (this.cardSize) {
      case 'medium':
        return baseSize;
      case 'small':
        return Math.floor(baseSize * 0.8);
      case 'large':
        return Math.floor(baseSize * 1.2);
      default:
        return baseSize;
    }
  }

  build() {
    Column() {
      Column() {
        Text(`${(this.woodenFishTitle ? this.woodenFishTitle : '好运')} +${this.newLuckValue}`)
          .fontSize(this.getFontSize(16))
          .fontWeight(FontWeight.Medium)
          .fontColor(this.textColor || '#99000000');

        Row() {
          Row() {
            Stack() {
              ForEach(this.messageList, (item: FloatText) => {
                if (item.show) {
                  Text(`${(this.woodenFishTitle ? this.woodenFishTitle : '好运')} +1`)
                    .fontSize(12)
                    .translate({ y: this.textTranslateValue })
                    .animation({ duration: 500, curve: Curve.EaseOut, playMode: PlayMode.Normal })
                }
              }, (item: FloatText) => item.id.toString() + new Date())
            }
            .width('55%')
            .alignContent(Alignment.BottomEnd)
          }
          .zIndex(9)

          Stack() {
            Column() {
              Image($r('app.media.chui'))
                .width(30)
                .height(12)
                .translate({ y: this.translateValue })
            }
            .alignItems(HorizontalAlign.Start)
            .translate({ y: -13, x: 10 })
            .zIndex(9)

            Image($r('app.media.muyu_container'))
              .width(26)
              .height(22)
              .scale(this.iconScaleOptions)
              .animation({ duration: 50, curve: Curve.EaseOut, playMode: PlayMode.Normal })
          }
        }
        .margin({
          right: 20
        })
        .alignItems(VerticalAlign.Bottom)

      }
      .visibility(this.cardSize === 'small' ? Visibility.Visible : Visibility.None)
      .justifyContent(FlexAlign.SpaceAround)
      .width('100%')
      .aspectRatio(1)
      .padding(18)
      .backgroundImage('data:image/jpeg;base64,' + this.backgroundImg)
      .backgroundImageSize(ImageSize.FILL)
      .backgroundColor(this.backgroundColorInfo ? this.backgroundColorInfo : '#fff')
      .borderRadius(4)
      .shadow({ radius: 2, color: '#00000010' });

      Row() {
        Stack({ alignContent: Alignment.BottomEnd }) {
          Row() {
            Text(`${(this.woodenFishTitle ? this.woodenFishTitle : '好运')} +${this.newLuckValue}`)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.textColor || '#99000000');
          }
          .height('100%')
          .width('100%')
          .alignItems(VerticalAlign.Top)

          Row() {
            Row() {
              Stack() {
                ForEach(this.messageList, (item: FloatText) => {
                  if (item.show) {
                    Text(`${(this.woodenFishTitle ? this.woodenFishTitle : '好运')} +1`)
                      .fontSize(16)
                      .translate({ y: this.textTranslateValue })
                      .animation({ duration: 500, curve: Curve.EaseOut, playMode: PlayMode.Normal })
                  }
                }, (item: FloatText) => item.id.toString() + new Date())
              }
              .width('55%')
              .alignContent(Alignment.BottomEnd)
            }
            .zIndex(9)

            Stack() {
              Column() {
                Image($r('app.media.chui'))
                  .width(46)
                  .height(15)
                  .translate({ y: this.translateValue })
              }
              .alignItems(HorizontalAlign.Start)
              .translate({ y: -18, x: 15 })
              .zIndex(9)

              Image($r('app.media.muyu_container'))
                .width(40)
                .height(36)
                .scale(this.iconScaleOptions)
                .animation({ duration: 50, curve: Curve.EaseOut, playMode: PlayMode.Normal })
            }
          }
          .margin({
            right: 20
          })
          .alignItems(VerticalAlign.Bottom)
        }

      }
      .visibility(this.cardSize === 'medium' ? Visibility.Visible : Visibility.None)
      .justifyContent(FlexAlign.SpaceAround)
      .width('100%')
      .padding(28)
      .aspectRatio(2)
      .backgroundColor(this.backgroundColorInfo ? this.backgroundColorInfo : '#fff')
      .backgroundImage('data:image/jpeg;base64,' + this.backgroundImg)
      .backgroundImageSize(ImageSize.FILL)
      .borderRadius(4)
      .shadow({ radius: 2, color: '#00000010' });

      Column() {
        Text(`${(this.woodenFishTitle ? this.woodenFishTitle : '好运')} +${this.newLuckValue}`)
          .fontSize(this.getFontSize(26))
          .fontWeight(FontWeight.Medium)
          .fontColor(this.textColor || '#99000000');

        Row() {
          Row() {
            Stack() {
              ForEach(this.messageList, (item: FloatText) => {
                if (item.show) {
                  Text(`${(this.woodenFishTitle ? this.woodenFishTitle : '好运')} +1`)
                    .fontSize(18)
                    .translate({ y: this.textTranslateValue })
                    .animation({ duration: 500, curve: Curve.EaseOut, playMode: PlayMode.Normal })
                }
              }, (item: FloatText) => item.id.toString() + new Date())
            }
            .width('55%')
            .alignContent(Alignment.BottomEnd)
          }
          .zIndex(9)

          Stack() {
            Column() {
              Image($r('app.media.chui'))
                .width(70)
                .height(30)
                .translate({ y: this.translateValue })
            }
            .alignItems(HorizontalAlign.Start)
            .translate({ y: -35, x: 20 })
            .zIndex(9)

            Image($r('app.media.muyu_container'))
              .width(80)
              .animation({ duration: 50, curve: Curve.EaseOut, playMode: PlayMode.Normal })
              .height(76)
              .scale(this.iconScaleOptions)
          }
        }
        .margin({
          right: 20
        })
        .alignItems(VerticalAlign.Bottom)

      }
      .visibility(this.cardSize === 'large' ? Visibility.Visible : Visibility.None)
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height('100%')
      .padding(32)
      .backgroundColor(this.backgroundColorInfo ? this.backgroundColorInfo : '#fff')
      .backgroundImage('data:image/jpeg;base64,' + this.backgroundImg)
      .backgroundImageSize(ImageSize.FILL)
      .borderRadius(4)
      .shadow({ radius: 2, color: '#00000010' });
    }
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.iconScaleOptions = { x: 0.8, y: 0.8 }
        this.textTranslateValue = 0
        this.translateValue = 5

        const newItem = {
          id: this.nextId++,
          text: `${(this.woodenFishTitle ? this.woodenFishTitle : '好运')} +1`,
          show: true,
          offsetY: 0
        } as FloatText;
        this.messageList = [...this.messageList, newItem]
      }
      if (event.type === TouchType.Up) {
        this.iconScaleOptions = { x: 1, y: 1 }
        this.translateValue = 0
        this.textTranslateValue = this.cardSize === 'small' ? -30 : this.cardSize === 'medium' ? -60 : -100
        const index = this.messageList.length - 1
        this.messageList[index].offsetY = -50
        this.messageList[index].show = false
      }
    })
    .onClick(async () => {
      this.newLuckValue++
      this.iconScaleOptions = { x: 1, y: 1 }
      postCardAction(this, {
        action: 'call',
        abilityName: 'PhoneAbility', // 只能拉起当前应用下的UIAbility
        params: {
          formId: '999',
          method: 'funA',
          calleeDetail: 'CallFrom'
        }
      });
    })
  }
}
