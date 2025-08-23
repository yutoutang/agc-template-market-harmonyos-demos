import { getString } from '@agctemplate/resources'
import { DramaListVM } from '../viewmodel/DramaListVM'

@ComponentV2
export struct PlayErrorLayer {

  @Param @Require vm: DramaListVM

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Text(getString('app.string.tips_net_err'))
          .fontColor($r('sys.color.white'))
        Button(getString('app.string.refresh'))
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.vm.init()
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }
}