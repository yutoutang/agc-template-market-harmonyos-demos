import { BreakpointType } from 'commons'

@Component
export default struct HomeTitle {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm'
  @Prop name: string
  @Prop isShowMore?: boolean = false
  moreClickFun?: () => void

  build() {
    Row() {
      Text(this.name)
        .fontSize(18)
        .lineHeight(24)
        .fontWeight(700)
        .fontColor('#111111')
      Blank()
      if (this.isShowMore) {
        Row() {
          Text('更多')
            .fontSize(14)
            .lineHeight(20)
            .fontColor('#606162')
            .padding({ right: 5 })
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontColor([$r('sys.color.ohos_id_color_foreground')])
            .opacity(0.3)
            .fontSize('24vp');
        }
        .onClick(() => {
          this.moreClickFun && this.moreClickFun()
        })
      }
    }
    .width('100%')
    .padding(new BreakpointType<Padding>({
      sm: {
        top: 48,
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8'),
      },
      md: {
        top: 48,
        left: $r('sys.float.padding_level12'),
        right: $r('sys.float.padding_level12'),
      },
      lg: {
        top: 48,
        left: $r('sys.float.padding_level16'),
        right: $r('sys.float.padding_level16'),
      },
    }).getValue(this.currentBreakpoint));
  }
}