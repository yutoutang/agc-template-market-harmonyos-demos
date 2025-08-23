import { MyConfig } from 'commons'
import { ObjectItem } from '../viewModel/AgendaModel'


const activityInfoMap: Record<string, string> = {
  '扫地僧见面会': `${MyConfig.URL}/project/hdc/2025/static/images/activity_1.png`,
  '某云产品体验官': `${MyConfig.URL}/project/hdc/2025/static/images/activity_2.png`,
  'AI应用开发馆': `${MyConfig.URL}/project/hdc/2025/static/images/activity_3.png`,
  'harmonyOS极客马拉松': `${MyConfig.URL}/project/hdc/2025/static/images/activity_4.png`,
  'codeLabs大广场': `${MyConfig.URL}/project/hdc/2025/static/images/activity_5.png`,
  'codeLabs溪刘坡村': `${MyConfig.URL}/project/hdc/2025/static/images/activity_6.png`,
  '开发者聚乐部': `${MyConfig.URL}/project/hdc/2025/static/images/activity_7.png`,
}

class ActivityListParams {
  type: string
  date: string
  address: string

  constructor(type: string, date: string, address: string) {
    this.type = type
    this.date = date
    this.address = address
  }
}

@Component
export struct ActivityList {
  @Consume('pageStack') pageStack: NavPathStack
  @ObjectLink item: ObjectItem
  collectFun?: () => void

  getImgUrl() {
    if (this.item.subItems && this.item.subItems[0] && this.item.subItems[0].mMeetingTypeCn) {
      let key = this.item.subItems[0].mMeetingTypeCn.join(',')
        .replace(/\s+/g, '')
      return activityInfoMap[key]
    }
    return `${MyConfig.URL}/project/hdc/2025/static/images/activity_4.png`
  }

  aboutToAppear(): void {

  }

  build() {
    Column() {
      Row() {
        Row() {
          Image(this.getImgUrl()).width(24).margin({
            right: 6
          })
          Text(this.item.subItems && this.item.subItems[0] && this.item.subItems[0].mMeetingTypeCn.join(','))
            .fontSize(16)
            .lineHeight(23)
            .fontColor('#e6000000')
            .fontWeight(600)
        }.justifyContent(FlexAlign.Start).layoutWeight(1)

        Image(`${MyConfig.URL}/project/hdc/2025/static/images/go_active_deatils_icon.png`).width(28)
      }.justifyContent(FlexAlign.SpaceBetween).padding({ bottom: 12 }).width('100%')


      Column() {
        Text(this.item.subItems && this.item.subItems[0] && this.item.subItems[0].subjectDesc)
          .textOverflow({
            overflow: TextOverflow.Ellipsis
          })
          .maxLines(2)
          .fontSize(14)
          .lineHeight(18)
          .fontColor('#99000000')
      }.width('100%').alignItems(HorizontalAlign.Start).margin({
        bottom: 12
      })

    }
    .backgroundColor(Color.White)
    .borderRadius(20)
    .onClick(() => {
      this.pageStack.pushPath({
        name: 'ActivityListLevelTwo',
        param: new ActivityListParams(this.item.title, this.item?.time, this.item?.address)
      })
    })
    .height(116)

    .margin({
      bottom: 8
    })
    .padding({
      left: 24,
      right: 24,
      top: 21,
      bottom: 21
    })

  }
}