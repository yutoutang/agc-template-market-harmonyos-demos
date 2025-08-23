@ComponentV2
export struct BulletSetting {

  @Param rowsNum: number = 2;
  @Param notOpacity: number = 80;
  @Param danMuSpeed: string = '适中';
  @Param danMuSize: string = '适中';
  @Event setRowsNum: Function = (set: number) => {};
  @Event setNotOpacity: Function = (set: number) => {};
  @Event setDanMuSpeed: Function = (set: string) => {};
  @Event setDanMuSize: Function = (set: string) => {};

  build() {
    Column({ space: 16 }) {
      // 显示行数
      Row() {
        Text('显示行数')
          .width(56)
          .height(19)
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
        Row() {
          ForEach(
            [1, 2, 3, 4, 5, 6],
            (item: number) => {
              Text(`${item}`)
                .width(43)
                .height(36)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .borderRadius(18)
                .textAlign(TextAlign.Center)
                .fontColor(this.rowsNum === item ? '#000' : '#9000')
                .backgroundColor(this.rowsNum === item ? '#fff' : 'transparent')
                .shadow(this.rowsNum === item ? { color: '#3000', radius: 3 } : { color: 'transparent', radius: 0 })
                .onClick(() => {
                  this.setRowsNum(item)
                })
            },
            (item: number) => item.toString()
          )
        }
        .width(260)
        .height(36)
        .padding({ left: 1, right: 1 })
        .margin({ left: 12 })
        .borderRadius(18)
        .backgroundColor('#0d000000')
      }
      .width(328)
      .height(48)

      // 不透明度
      Row() {
        Text('不透明度')
          .width(56)
          .height(19)
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
        Row() {
          ForEach(
            [20, 40, 60, 80, 100],
            (item: number) => {
              Text(item === 0 ? '' : `${item}%`)
                .width(52)
                .height(36)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .borderRadius(18)
                .textAlign(TextAlign.Center)
                .fontColor(this.notOpacity === item ? '#000' : '#9000')
                .backgroundColor(this.notOpacity === item ? '#fff' : 'transparent')
                .shadow(this.notOpacity === item ? { color: '#3000', radius: 3 } : { color: 'transparent', radius: 0 })
                .onClick(() => {
                  this.setNotOpacity(item)
                })
            },
            (item: number) => item.toString()
          )
        }
        .width(260)
        .height(36)
        .padding({ left: 1, right: 1 })
        .margin({ left: 12 })
        .borderRadius(18)
        .backgroundColor('#0d000000')
      }
      .width(328)
      .height(48)

      // 弹幕速度
      Row() {
        Text('弹幕速度')
          .width(56)
          .height(19)
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
        Row() {
          ForEach(
            ['慢', '', '适中', '', '快'],
            (item: string) => {
              Text(item)
                .width(52)
                .height(36)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .borderRadius(18)
                .textAlign(TextAlign.Center)
                .fontColor(this.danMuSpeed === item ? '#000' : '#9000')
                .backgroundColor(this.danMuSpeed === item ? '#fff' : 'transparent')
                .shadow(this.danMuSpeed === item ? { color: '#3000', radius: 3 } : { color: 'transparent', radius: 0 })
                .onClick(() => {
                  if (item) {
                    this.setDanMuSpeed(item)
                  }
                })
            },
            (item: string, index: number) => item + '_' + index.toString()
          )
        }
        .width(260)
        .height(36)
        .padding({ left: 1, right: 1 })
        .margin({ left: 12 })
        .borderRadius(18)
        .backgroundColor('#0d000000')
      }
      .width(328)
      .height(48)

      // 弹幕字号
      Row() {
        Text('弹幕字号')
          .width(56)
          .height(19)
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
        Row() {
          ForEach(
            ['小', '', '适中', '', '大'],
            (item: string) => {
              Text(item)
                .width(52)
                .height(36)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .borderRadius(18)
                .textAlign(TextAlign.Center)
                .fontColor(this.danMuSize === item ? '#000' : '#9000')
                .backgroundColor(this.danMuSize === item ? '#fff' : 'transparent')
                .shadow(this.danMuSize === item ? { color: '#3000', radius: 3 } : { color: 'transparent', radius: 0 })
                .onClick(() => {
                  if (item) {
                    this.setDanMuSize(item)
                  }
                })
            },
            (item: string, index: number) => item + '_' + index.toString()
          )
        }
        .width(260)
        .height(36)
        .padding({ left: 1, right: 1 })
        .margin({ left: 12 })
        .borderRadius(18)
        .backgroundColor('#0d000000')
      }
      .width(328)
      .height(48)
    }
  }
}