import { AgendaDetailModel, AgendaItemModel } from '../viewModel/AgendaDetailModel'
import { AgendaDetailParam, AgendaListItemModel, ObjectItem } from '../viewModel/AgendaModel'
import { AgendaListItem } from './AgendaListItem'
import { ScheduleItem } from './ScheduleItem'
import { MyConfig } from 'commons'
import dayjs from 'dayjs'

@Component
export struct AgendaList {
  @Consume('pageStack') pageStack: NavPathStack
  @ObjectLink item: ObjectItem
  collectFun?: (item: AgendaListItemModel) => void
  @State agendaDetail: AgendaDetailModel | undefined = undefined;
  open() {
    this.item.isShowMore = !this.item.isShowMore
  }

  @Builder
  imageTitle(icon: string, title: string) {
    Row() {
      Image(icon).width(18).height(18).margin({
        right: 8
      })
      Text(title).fontSize(16).lineHeight(23).fontColor(Color.White).fontWeight(600)
    }.padding({
      left: 16,
      top: 12,
    })
  }

  @Builder
  expandAndFold() {
    Text(this.item.isShowMore ? '收起' : '展开').fontSize(14).fontColor('#999999').lineHeight(20).margin({
      right: 8
    })
    Image(this.item.isShowMore ? `${MyConfig.URL}agenda3%2Fagenda_up.png?token=d22f9d69-d70a-4c6f-9457-b01c8964bc58` :
      `${MyConfig.URL}/project/hdc/2025/static/images/agenda_more.png`)
      .width(8)
      .height(14)
      .margin({
        top: 2
      })
  }

  build() {
    Stack({
      alignContent: Alignment.Top
    }) {

      Column() {
        if (this.item.title === '主题演讲') {
          Row() {
            Column() {

              this.imageTitle(`${MyConfig.URL}agenda2%2Fagenda_sub_item_icon.png?token=dc550aba-a7a0-4ff4-b5ec-89f04f37b55b`,
                this.item.title)

              Row() {
                Row() {
                  Image(`${MyConfig.URL}agenda2%2Fzhuti_time.png?token=df737510-df2e-4f95-a2d1-3c93ad896ff6`).width(12).margin({
                    top: -2,
                    right: 3
                  })
                  Text(dayjs(parseInt(this.item.subItems?.[0].startTime) * 1000).format('HH:mm') + '-' +
                  dayjs(parseInt(this.item.subItems?.[0].endTime) * 1000).format('HH:mm'))
                    .fontSize(12)
                    .lineHeight(13)
                    .fontColor('#ffffff')
                }.margin({
                  right: 16
                }).justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)

                Row() {
                  Image(`${MyConfig.URL}agenda2%2Fzhuti_address.png?token=ca898684-bbc4-432b-9aad-4654377d5061`).width(12).margin({
                    top: -2,
                    right: 3
                  })
                  Text(this.item.subItems?.[0].hotel).fontSize(12).lineHeight(13).fontColor('#ffffff')
                }.justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
              }.padding({
                left: 16,
                top: 7,
              })
            }.layoutWeight(1).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Start)

            Image(`${MyConfig.URL}agenda2%2Fagenda_zhuti_back.png?token=26dc3d43-645f-4bc6-84f0-d4c33b7606f3`).width(28).margin({
              right: 16
            })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .onClick(() => {
            this.pageStack.pushPath({
              name: 'AgendaDetail',
              param: new AgendaDetailParam(this.item.subItems?.[0].subSeminarId)
            })
          })
        } else {
          this.imageTitle(`${MyConfig.URL}agenda2%2Fagenda_sub_item_icon.png?token=dc550aba-a7a0-4ff4-b5ec-89f04f37b55b`,
            this.item.title || '')
        }
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .backgroundColor(this.item.title === '主题演讲' ? '#F2403D' : '#153AD1')
      .borderRadius(20)
      .height(141)
      .backgroundImage(this.item.title === '主题演讲' ?
        `${MyConfig.URL}agenda%2Fagenda_red_bg.png?token=ac1a209b-a31f-4b6c-8f56-cbb291c35cf2` :
        `${MyConfig.URL}agenda%2Fagenda_blue_bg.png?token=e51d58f5-9fa7-42c2-94cd-88fe0be0dcd2`)

      .backgroundImagePosition(Alignment.TopStart)
      .backgroundImageSize({
        width: '100%',
      })

      if (this.item.title === '主题演讲') {
        Column() {
          GridRow() {
            ForEach(this.item.subItems?.[0]._agendaList, (item: AgendaItemModel, index: number) => {
              GridCol({
                span: {
                  sm: 12,
                  md: 12,
                  lg: 12,
                },
              }) {
                /*       if (this.item.isShowMore || index < 4) {*/
                ScheduleItem({
                  item: item,
                  agendaDetail: this.agendaDetail,
                  isLast: index === (this.item.subItems?.[0]._agendaList || []).length - 1
                })
                /*  }*/
              }
            }, (item: AgendaItemModel) => item.agendaId)
          }
          .onClick(() => {
            this.pageStack.pushPath({
              name: 'AgendaDetail',
              param: new AgendaDetailParam(this.item.subItems?.[0].subSeminarId)
            })
          })

        }
        .width('100%')
        .padding({
          top: 2,
          left: 15,
          bottom: 12,
          right: 15
        })
        .backgroundColor('#ffffff')
        .borderRadius(20)
        .margin({
          top: 66
        })
      } else {
        Column() {
          GridRow({
            gutter: { x: 8, y: 8 }
          }) {
            ForEach(this.item.subItems,
              (subItem: AgendaListItemModel, index: number) => {
                if (this.item.isShowMore || index < 4) {
                  GridCol({
                    span: {
                      sm: 12,
                      md: 6,
                      lg: 6,
                    }
                  }) {
                    AgendaListItem({ item: subItem })
                  }
                }
              }, (item: AgendaListItemModel) => JSON.stringify(item))
          }.width('100%')

          if (this.item.subItems && this.item.subItems.length > 4) {
            Row() {
              this.expandAndFold()
            }.onClick(() => {
              this.open()
            })
            .padding({
              top: 12,
              left: 30,
              right: 30
            })
          }
        }
        .backgroundColor(Color.White)
        .padding({
          top: 16,
          bottom: 12,
          left: 12,
          right: 12
        })
        .width('100%')
        .borderRadius(20)
        .margin({
          top: 46,
        })
      }
    }.width('100%')
    .padding({
      left: 16,
      right: 16
    })
  }
}