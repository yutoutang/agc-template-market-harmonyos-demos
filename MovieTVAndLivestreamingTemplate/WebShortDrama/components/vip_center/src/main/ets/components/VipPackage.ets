import { BaseCell } from 'base_apis';
import { VipPackageItem } from '../model/Model';

@ComponentV2
export struct VipPackage {
  @Local currentIndex: number = 0
  @Param userName: string = ''
  @Param avatar: string = ''
  @Param isVip: boolean = false
  @Param currentPackage: VipPackageItem = new VipPackageItem()
  @Event packageChange: (vipPackage: VipPackageItem) => void = () => {
  }
  private packageList: VipPackageItem[] = [
    {
      title: '会员周卡',
      amount: 5,
      duration: 'week',
      amountDes: '剧情抢先看',
    },
    {
      title: '连续包月',
      amount: 20,
      originalPrice: 29,
      duration: 'month',
      amountDes: '首月特惠',
    },
    {
      title: '会员季卡',
      amount: 78,
      originalPrice: 98,
      duration: 'quarter',
      amountDes: '低至0.63元/天',
    },
    {
      title: '会员半年卡',
      amount: 199,
      originalPrice: 249,
      duration: 'halfYear',
      amountDes: '低至0.3元/天',
    },
    {
      title: '会员年卡',
      amount: 299,
      duration: 'year',
      amountDes: '畅享全部权益',
    }]

  @Builder
  vipPackageCard(item: VipPackageItem, index: number) {
    Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center, direction: FlexDirection.Column }) {
      Column() {
        Text(item.title)
          .fontSize(14)
          .fontColor('#e6000000')
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 8 })

        Column() {
          Text() {
            Span('¥')
              .fontSize(14)
            Span(`${item.amount.toString()}`)
              .fontSize(28)
          }
          .fontColor(this.currentIndex === index ? '#7E4D12' : $r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)

          if (item.originalPrice) {
            Text() {
              Span('¥')
              Span(`${item.originalPrice.toString()}`)
            }
            .fontSize(12)
            .fontColor($r('sys.color.font_tertiary'))
            .decoration({ type: TextDecorationType.LineThrough })
          }
        }
      }
      .flexGrow(1)
      .justifyContent(FlexAlign.Center)

      Row() {
        Text(item.amountDes)
          .lineHeight(16)
          .fontSize(12)
          .fontColor(this.currentIndex === index ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.currentIndex === index ? '#BD9164' : $r('sys.color.comp_background_tertiary'))
      .padding({ top: 4, bottom: 4 })
    }
    .border({
      width: this.currentIndex === index ? 2 : 1,
      color: this.currentIndex === index ? '#BD9164' : '#fff',
    })
    .backgroundColor(this.currentIndex === index ? '#FFFCF2' : $r('sys.color.background_primary'))
    .borderRadius(16)
    .width(104)
    .clip(true)
    .margin({ top: 8 })
    .onClick(() => {
      this.currentIndex = index
      this.packageChange(item)
    })
  }

  @Builder
  vipPackageBuilder() {
    List({ space: 8 }) {
      ForEach(this.packageList, (item: VipPackageItem, index: number) => {
        ListItem() {
          this.vipPackageCard(item, index)
        }
      }, (item: VipPackageItem) => item.title)
    }
    .height(138)
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
  }

  build() {
    Column() {
      BaseCell({
        cellTitle: '会员套餐',
        customBuilderParam: () => this.vipPackageBuilder(),
      })
      if (this.currentIndex === 1) {
        Text('次月起自动续费为29/月，可随时取消')
          .fontSize(12)
          .fontColor($r('sys.color.font_tertiary'))
          .lineHeight(16)
          .margin({ top: 13 })
      }
    }
    .alignItems(HorizontalAlign.Start)
    .height(166)
  }
}