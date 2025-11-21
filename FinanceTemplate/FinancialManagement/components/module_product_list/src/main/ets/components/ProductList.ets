import { ProductListVM } from '../viewModel/ProductListVM'
import { CustomTabContent } from './CustomTabContent'

@ComponentV2
export struct ModuleProductList {
  vm: ProductListVM = ProductListVM.instance
  @Param productType: number = 1
  @Param selectedIndex: number = 0
  @Local currentIndex: number = 0
  @Local fontColor: ResourceStr = $r('sys.color.font_secondary')
  @Local selectedFontColor: string = '#E4480C'
  private controller: TabsController = new TabsController()

  build() {
    Tabs({ barPosition: BarPosition.Start, index: this.selectedIndex, controller: this.controller }) {
      TabContent() {
        CustomTabContent({ productType: this.productType })
      }
      .tabBar(this.tabBuilder(0, '活钱管理'))

      TabContent() {
        CustomTabContent({ productType: this.productType })
      }.tabBar(this.tabBuilder(1, '稳健低波'))

      TabContent() {
        CustomTabContent({ productType: this.productType })
          .layoutWeight(1)
      }.tabBar(this.tabBuilder(2, '稳健增值'))

      TabContent() {
        CustomTabContent({ productType: this.productType })
      }.tabBar(this.tabBuilder(3, '投资增益'))

      TabContent() {
        CustomTabContent({ productType: this.productType })
      }.tabBar(this.tabBuilder(4, '投资回报'))
    }
    .vertical(false)
    .barMode(BarMode.Fixed)
    .barWidth('100%')
    .barHeight(56)
    .animationDuration(400)
    .onChange((index: number) => {
      this.currentIndex = index
      this.vm.refresh(index)
    })
    .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
      if (index === targetIndex) {
        return
      }
      this.currentIndex = targetIndex
    })
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Column() {
        Text(name)
          .fontColor(this.currentIndex === index ? this.selectedFontColor : this.fontColor)
          .fontSize(14)
          .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Regular)
          .margin({ top: 17, bottom: 7 })
        Row()
          .width('100%')
          .height(2)
          .backgroundColor('#E4480C')
          .opacity(this.currentIndex === index ? 1 : 0)
      }
      .width(56)
    }
    .width('100%')
  }
}