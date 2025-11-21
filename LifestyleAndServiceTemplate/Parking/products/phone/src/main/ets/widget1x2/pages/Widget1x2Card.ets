const storageLocal1 = new LocalStorage();

@Entry(storageLocal1)
@Component
struct Widget1x2Card {
  @LocalStorageProp('default') default: string = '';
  readonly actionType: string = 'router';
  readonly abilityName: string = 'EntryAbility';

  nextDo() {
    if (this.default) {
      postCardAction(this, {
        action: 'router',
        abilityName: this.abilityName,
        params: {
          targetPage: 'PayPage',
          license: this.default,
        },
      });
    } else {
      postCardAction(this, {
        action: 'router',
        abilityName: this.abilityName,
        params: {
          targetPage: 'QueryPage',
        },
      });
    }
  }

  build() {
    Row({ space: 4 }) {
      Image($r('app.media.app_icon_rect'))
        .width(28)
        .aspectRatio(1)
        .borderRadius('50%')
        .clip(true)

      if (this.default) {
        Row({ space: 2 }) {
          Text(this.default)
            .fontWeight(FontWeight.Medium)
            .fontColor('rgba(0,0,0,0.90)')
            .fontSize(14)
          Text('默认')
            .padding({
              left: 2,
              right: 2,
              top: 2,
              bottom: 2,
            })
            .backgroundColor($r('app.color.system_color_background_gray'))
            .borderRadius($r('app.string.border_radius_8'))
            .fontColor('rgba(0,0,0,0.60)')
            .fontSize(8)
        }
      } else {
        Text('无默认车牌')
          .fontWeight(FontWeight.Medium)
          .fontColor('rgba(0,0,0,0.90)')
          .fontSize(14)
      }
    }
    .onClick(() => {
      this.nextDo();
    })
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .linearGradient({
      angle: 180,
      colors: [
        ['#EFF5FF', 0],
        ['#8FB2F1', 0.99],
      ],
    })
    .padding({ left: 8, right: 8 })
  }
}