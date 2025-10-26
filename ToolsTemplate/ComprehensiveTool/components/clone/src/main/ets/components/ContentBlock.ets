import { MainFile, TransferState, TransferType } from '../common/Constant'
import { formatBytes } from '../utils/FileUtil'

@ComponentV2
export struct ContentBlock {
  @Param type: TransferType = TransferType.Send
  @Param state: TransferState = TransferState.BEFORE
  @Param title: string = ''
  @Param mainFile: MainFile = new MainFile()
  @Param img: ResourceStr = ''
  @Param count: number = 0
  @Param progress: string = ''
  @Event onChange: (value: boolean) => void = () => {
  }

  build() {
    Row() {
      Row() {
        if (this.state === TransferState.BEFORE && this.type === TransferType.Send) {
          Checkbox({ name: 'checkbox2', group: 'checkboxGroup' })
            .select(true)
            .shape(CheckBoxShape.ROUNDED_SQUARE)
            .margin({ right: 12 })
            .onChange((value: boolean) => {
              this.onChange(value)
            })
        }
        Image(this.img)
          .width(48)
          .height(48)
          .margin({ right: 12 })
        Column() {
          Text() {
            Span(this.title)
              .margin({ right: 12 })
            if (this.state === TransferState.BEFORE && this.type === TransferType.Send) {
              Span(`(${this.mainFile.isSelected ? this.mainFile.size : 0}/${this.mainFile.size})`)
            }
          }
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 2 })

          if (this.title !== '联系人') {
            Text() {
              Span('大小：')
              Span(formatBytes(this.mainFile.fileSize))
            }
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Regular)
          }
        }
        .alignItems(HorizontalAlign.Start)
      }

      if (this.state === TransferState.MIDDLE || this.state === TransferState.AFTER) {
        Column() {
          Text(this.progress)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 2 })
          Text() {
            if (this.state === TransferState.MIDDLE) {
              Span('正在传输')
              Span(`(${this.count}/${this.mainFile.size})`)
            } else {
              Span('传输完成!')
            }
          }
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_tertiary'))
          .fontWeight(FontWeight.Regular)
        }
        .alignItems(HorizontalAlign.End)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(12)
    .margin({ bottom: 12 })
    .borderRadius(16)
    .backgroundColor(Color.White)
  }
}