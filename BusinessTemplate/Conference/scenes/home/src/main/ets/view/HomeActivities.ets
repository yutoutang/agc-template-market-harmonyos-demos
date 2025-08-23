import { ActivityDetailsParams } from '../viewModel/ActivitisModel'
import { BreakpointType, MyConfig } from 'commons';

@Component
export default struct HomeActivities {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm'
  @Consume('pageStack') pageStack: NavPathStack
  @State topImageHeight: number = 0
  @State bottomImageHeight: number = 0

  goDetail(name: string) {
    this.pageStack.pushPath({
      name: 'ActivitiesPage',
      param: new ActivityDetailsParams(name)
    })
  }

  build() {
    Column({ space: 12 }) {
      Stack(){
        Image(MyConfig.URL + 'home_new%2Fbg_activity_1.png?token=0fc0009c-ac65-47ca-a646-a2799b4ccba9')
          .width('100%').height(144)
        Row(){
          Image(MyConfig.URL + 'home%2Fhome_expert_1.png?token=7241d278-d50a-45cb-a225-88af52f3f4f1')
            .width(112)
            .height(112)

          Column(){
            Text('音乐节')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
              .padding({ top: 16, bottom: 8 })
            Row({ space: 5 }){
              Image($r('app.media.clock'))
                .width(16)
              Text('14:30-17:00')
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
            }
            Row({ space: 5 }){
              Image($r('app.media.addr'))
                .width(16)
              Text('广东 1号会议中心')
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
            }
            .padding({ top: 4 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 11 })
          .height('100%')
        }
        .width('100%')
        .padding({ left: 14, right: 14 })
      }
      .height(144)
      .onClick(() => {
        //音乐节
        this.goDetail('yinYue')
      })

      Stack(){
        Image(MyConfig.URL + 'home_new%2Fbg_activity_2.png?token=92457e85-8d57-4b9d-a0fb-faf402a5fb6a')
          .width('100%').height(144)
        Row(){
          Image(MyConfig.URL + 'home%2Fhome_tea_party_.png?token=97597c35-eaa9-4e58-8e93-52a8b2563a7b')
            .width(112)
            .height(112)

          Column(){
            Text('技术嘉年华')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
              .padding({ top: 16, bottom: 8 })
            Row({ space: 5 }){
              Image($r('app.media.clock'))
                .width(16)
              Text('14:30-17:00')
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
            }
            Row({space: 5}){
              Image($r('app.media.addr'))
                .width(16)
              Text('广东 1号展播厅')
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
            }
            .padding({ top: 4 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 11 })
          .height('100%')
        }
        .width('100%')
        .padding({ left: 14, right: 14 })
      }
      .height(144)
      .onClick(() => {
        this.goDetail('jiaNianHua')
      })

      Stack(){
        Image(MyConfig.URL + 'home_new%2Fbg_activity_3.png?token=52794aa5-9deb-4ce1-a3e2-7156b56aeed7').width('100%').height(144)
        Row(){
          Image(MyConfig.URL+ 'home%2Fhome_tech_party_1.png?token=b79da03f-dbff-41e6-84c0-8ddf0cfdd5ae')
            .width(112)
            .height(112)

          Column(){
            Text('早餐会')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
              .padding({ top: 16, bottom: 8 })
            Row({ space: 5 }){
              Image($r('app.media.clock'))
                .width(16)
              Text('14:30-17:00')
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
            }
            Row({space: 5}){
              Image($r('app.media.addr'))
                .width(16)
              Text('广东 1号展播厅')
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
            }
            .padding({ top: 4 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 11 })
          .height('100%')
        }
        .width('100%')
        .padding({ left: 14, right: 14 })
      }
      .height(144)
      .onClick(() => {
        this.goDetail('zaoCan')
      })
    }
    .padding(new BreakpointType<Padding>({
      sm: {
        top: 10,
        left: $r('sys.float.padding_level8'),
        right: $r('sys.float.padding_level8'),
      },
      md: {
        top: 10,
        left: $r('sys.float.padding_level12'),
        right: $r('sys.float.padding_level12'),
      },
      lg: {
        top: 10,
        left: $r('sys.float.padding_level16'),
        right: $r('sys.float.padding_level16'),
      },
    }).getValue(this.currentBreakpoint))
    .width('100%')
  }
}