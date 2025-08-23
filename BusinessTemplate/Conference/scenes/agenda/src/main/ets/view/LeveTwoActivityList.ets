import { AgendaDetailModel } from '../viewModel/AgendaDetailModel'
import { AgendaListItemModel, ObjectItem } from '../viewModel/AgendaModel'
import { AgendaListItem } from './AgendaListItem'
import { MyConfig} from 'commons'

@Component
export struct LeveTwoActivityList {
  @Consume('pageStack') pageStack: NavPathStack
  @ObjectLink item: ObjectItem
  collectFun?: (item: AgendaListItemModel) => void
  @State agendaDetail: AgendaDetailModel | undefined = undefined;

  open() {
    this.item.isShowMore = !this.item.isShowMore
  }

  build() {

    Stack({
      alignContent: Alignment.Top
    }) {
      Column() {

        Row() {
          Image(`${MyConfig.URL}/project/hdc/2025/static/images/activity_list_top_icon.png`).width(18).margin({
            right: 8
          })
          Text(this.item.title).fontSize(16).lineHeight(23).fontColor(Color.White)
        }.padding({
          left: 16,
          top: 12,
        }).justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)

        Row() {
          Image(`${MyConfig.URL}agenda2%2Fzhuti_address.png?token=ca898684-bbc4-432b-9aad-4654377d5061`).width(12).margin({
            top: -2,
            right: 3
          })
          Text(this.item.address).fontSize(12).lineHeight(13).fontColor(Color.White)
        }.padding({
          left: 16,
          top: 9,
        })

      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .backgroundColor('#972EC3')
      .borderRadius(20)
      .height(141)
      .backgroundImage(`${MyConfig.URL}/project/hdc/2025/static/images/agenda_list_icon_purple.png`)
      .backgroundImagePosition(Alignment.TopStart)
      .backgroundImageSize({
        width: 109,
      })

      Column() {
        GridRow({
          gutter: { x: 12, y: 12 }
        }) {
          ForEach(this.item.subItems,
            (subItem: AgendaListItemModel, index: number) => {
              if (this.item.isShowMore || index < 4) {
                GridCol({
                  span: {
                    sm: 12, // 窗口宽度落入xs断点上，栅格子组件占据的栅格容器2列。
                    md: 6, // 窗口宽度落入sm断点上，栅格子组件占据的栅格容器3列。
                    lg: 6, // 窗口宽度落入md断点上，栅格子组件占据的栅格容器4列。
                  }
                }) {
                  AgendaListItem({ item: subItem })
                }
              }
            }, (item: AgendaListItemModel) => JSON.stringify(item))
        }

        if (this.item.subItems && this.item.subItems.length > 4) {
          Row() {
            Text(this.item.isShowMore ? '收起' : '展开')
              .fontSize(14)
              .fontColor('#999999')
              .lineHeight(20)
              .margin({ right: 8 })

            Image(this.item.isShowMore ? `${MyConfig.URL}agenda3%2Fagenda_up.png?token=d22f9d69-d70a-4c6f-9457-b01c8964bc58` :
              `${MyConfig.URL}/project/hdc/2025/static/images/agenda_more.png`)
              .width(8)
              .height(14)
              .margin({ top: 2 })
          }
          .padding({
            top: 12,
            left: 30,
            right: 30
          })
          .onClick(() => {
            this.open()
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
        top: 68,
      })
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16
    })

  }
}