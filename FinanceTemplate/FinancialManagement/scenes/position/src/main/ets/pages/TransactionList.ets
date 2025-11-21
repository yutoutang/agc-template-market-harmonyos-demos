import { CustomContentDialog } from '@kit.ArkUI'
import { CommonFilter, RouterMap, FormatUtil } from 'module_base'
import { IMonthTransactionItem, ITransactionItem } from 'lib_foundation'
import { TransactionListVM } from '../viewModels/TransactionListVM'


@ComponentV2
struct TransactionRecordList {
  vm: TransactionListVM = TransactionListVM.instance
  searchController: SearchController = new SearchController()
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      contentBuilder: () => {
        this.buildContent();
      },
    }),
    width: '100%',
    offset: { dx: 0, dy: 28 },
    cornerRadius: {
      topLeft: 32,
      topRight: 32,
      bottomLeft: 0,
      bottomRight: 0,
    },
    alignment: DialogAlignment.Bottom,
  })

  build() {
    NavDestination() {
      Column() {
        Row() {
          Search({ value: this.vm.searchText, placeholder: '搜索', controller: this.searchController })
            .width('100%')
            .placeholderColor($r('sys.color.font_secondary'))
            .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
            .textFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
            .margin({ bottom: 16 })
            .focusable(false)
            .onClick(() => {
              FormatUtil.jumpToNext(RouterMap.TRANSACTION_SEARCH)
            })
        }
        .padding({ left: 16, right: 16 })

        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Row() {
            Select(this.vm.selectTransactionTypeList)
              .value(this.vm.getLabel(this.vm.transactionTypeList, this.vm.transactionType))
              .font({ size: $r('sys.float.Body_M'), weight: FontWeight.Regular })
              .backgroundColor($r('sys.color.background_secondary'))
              .onSelect((index: number, value: string) => {
                const arrangement = this.vm.getValue(this.vm.transactionTypeList, value)
                if (this.vm.transactionType !== arrangement) {
                  this.vm.transactionType = arrangement
                  this.vm.search()
                }
              })
            Select(this.vm.selectTransactionDateList)
              .value(this.vm.getLabel(this.vm.transactionDateList, this.vm.transactionDate))
              .font({ size: $r('sys.float.Body_M'), weight: FontWeight.Regular })
              .backgroundColor($r('sys.color.background_secondary'))
              .onSelect((index: number, value: string) => {
                const arrangement = this.vm.getValue(this.vm.transactionDateList, value)
                if (this.vm.transactionDate !== arrangement) {
                  this.vm.transactionDate = arrangement
                  this.vm.search()
                }
              })
          }

          Row() {
            Text('筛选')
              .fontSize(14)
              .fontWeight(FontWeight.Regular)
              .fontColor(this.vm.isSelecting ? '#E4480C' : $r('sys.color.font_primary'))
            Image(this.vm.isSelecting ? $r('app.media.ic_select_filter') : $r('app.media.ic_filter'))
              .width(16)
              .height(16)
          }
          .onClick(() => {
            this.dialogController.open()
          })
        }
        .padding({ left: 16, right: 16 })

        if (this.vm.transactionRecordList.length <= 0) {
          Column() {
            Image($r('app.media.ic_no_record'))
              .width(120)
              .height(120)
            Text('暂无交易记录')
              .fontSize(14)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_tertiary'))
          }
          .width('100%')
          .margin({ top: 77 })
        } else {
          List() {
            ForEach(this.vm.transactionRecordList, (monthTransactionItem: IMonthTransactionItem) => {
              ListItem() {
                Column() {
                  Row() {
                    Text(monthTransactionItem.month)
                      .fontSize(14)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_secondary'))
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16 })
                  .margin({ bottom: 8 })

                  ForEach(monthTransactionItem.transactionList, (transactionItem: ITransactionItem) => {
                    Flex() {
                      Row() {
                        Text() {
                          if (transactionItem.type === 2) {
                            Span('购买')
                              .fontColor('#E4480C')
                          } else if (transactionItem.type === 3) {
                            Span('赎回')
                          } else {
                            Span('到期')
                          }
                        }
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor($r('sys.color.font_primary'))
                      }
                      .margin({ right: 8 })
                      .flexShrink(0)

                      Column() {
                        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Start }) {
                          Text(transactionItem.productName)
                            .fontSize(14)
                            .fontWeight(FontWeight.Medium)
                            .fontColor($r('sys.color.font_primary'))
                            .maxLines(2)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .margin({ right: 20 })
                          Text(transactionItem.amount + '元')
                            .fontSize(14)
                            .fontWeight(FontWeight.Medium)
                            .fontColor($r('sys.color.font_primary'))
                        }
                        .height(38)
                        .margin({ bottom: 2 })

                        Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                          Text(transactionItem.date)
                            .fontSize(12)
                            .fontWeight(FontWeight.Regular)
                            .fontColor($r('sys.color.font_secondary'))
                          Text('份额为' + transactionItem.share + '份')
                            .fontSize(12)
                            .fontWeight(FontWeight.Regular)
                            .fontColor($r('sys.color.font_secondary'))
                        }
                      }
                      .flexGrow(1)
                    }
                    .backgroundColor(Color.White)
                    .padding({
                      top: 12,
                      bottom: 12,
                      left: 16,
                      right: 16,
                    })
                    .onClick(() => {
                      FormatUtil.jumpToNext(RouterMap.TRANSACTION_RECORD_INFO, transactionItem.id)
                    })
                  }, (monthTransactionItem: IMonthTransactionItem) => JSON.stringify(monthTransactionItem))
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
              }
              .margin({ top: 10 })
            }, (item: IMonthTransactionItem) => JSON.stringify(item))
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        }
      }
      .width('100%')
      .height('100%')
    }
    .title('交易记录')
    .backgroundColor($r('sys.color.background_secondary'))
    .onShown(() => {
      this.vm.init()
    })
    .onHidden(() => {
      this.vm.clear()
    })
  }

  // 自定义弹出框的内容区
  @Builder
  buildContent(): void {
    Column() {
      Scroll() {
        Column() {
          Row() {
            Text('筛选')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
            Image($r('app.media.ic_close'))
              .width(40)
              .height(40)
              .onClick(() => {
                this.dialogController.close()
              })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width('100%')
          .margin({ bottom: 33 })

          Row() {
            CommonFilter({
              text: '销售状态类型',
              value: this.vm.transactionType,
              list: this.vm.transactionTypeList,
              changeValue: (value) => {
                this.vm.tempTransactionType = value
              },
            })
          }
          .margin({ bottom: 11 })

          CommonFilter({
            text: '销售周期',
            value: this.vm.transactionDate,
            list: this.vm.transactionDateList,
            changeValue: (value) => {
              this.vm.tempTransactionDate = value
            },
          })

          Row({ space: 12 }) {
            Button('重置')
              .height(40)
              .fontColor($r('sys.color.font_primary'))
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .flexGrow(1)
              .onClick(() => {
                this.vm.isSelecting = false
                this.vm.reset()
                this.dialogController.close()
              })

            Button('完成')
              .height(40)
              .fontColor($r('sys.color.font_on_primary'))
              .backgroundColor('#E4480C')
              .flexGrow(1)
              .onClick(() => {
                this.vm.transactionType = this.vm.tempTransactionType
                this.vm.transactionDate = this.vm.tempTransactionDate
                this.vm.isSelecting = true
                this.vm.search()
                this.dialogController.close()
              })
          }
          .width('100%')
          .margin({ top: 28 })
        }
        .width('100%')
        .padding({ bottom: 28 })
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
  }
}

@Builder
export function TransactionRecordListBuilder() {
  TransactionRecordList()
}