import { AppUtil, MyConfig } from 'commons';
import { getActivityListJson } from '../service/ActivitisService';
import { ActivityListItem } from '../viewModel/ActivitisModel';
import { common } from '@kit.AbilityKit';

// 跳转页面入口函数
@Builder
export function ActivitiesPageBuilder() {
  ActivitiesPage()
}


@Component
struct ActivitiesPage {
  scroller: Scroller = new Scroller()
  @Consume('pageStack') pageStack: NavPathStack
  @StorageProp('deviceId') deviceId: string = '';
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @State allData: ActivityListItem[] = []
  @State currentData: ActivityListItem = {
    type: '',
    name: '',
    image: '',
    address: '',
    longitude: '',
    latitude: '',
    desc: ''
  }
  @State type: string = ''
  @State loading: boolean = true;
  @State showTitleBar: boolean = false;

  aboutToAppear(): void {
    this.type = (this.pageStack.getParamByName('ActivitiesPage')[0] as Record<string, string>).type
    this.loadData()
  }

  loadData() {
    getActivityListJson().then(res => {
      let data = res.data.find(item => {
        return item.type === this.type
      })
      if (data) {
        this.currentData = data
      }
      setTimeout(() => {
        this.loading = false
      }, 400)
    })
  }

  build() {
    NavDestination() {
      Stack({
        alignContent: Alignment.Top
      }) {
        if (this.loading) {
          Column() {
            LoadingProgress().width(70)
          }.backgroundColor($r('sys.color.white')).width('100%').height('100%').justifyContent(FlexAlign.Center)
        } else {
          Column() {
            Row() {
              Row(){
                SymbolGlyph($r('sys.symbol.chevron_left'))
                  .fontSize(30)
              }
              .padding({left: 12})
              .height(40)
              .borderRadius(100)
              .backgroundColor('#E6E8E9')
              .width(40)
              .onClick(() => {
                this.pageStack.pop()
              })
              Text('')
                .width('100%')
                .fontSize(24)
                .fontColor('#111111')
                .fontWeight(700)
            }
            .height(56)
            .justifyContent(FlexAlign.Center)
            .padding({ left: 20 })
          }
          .padding({ top: px2vp(this.topRectHeight) })
          .backgroundColor(this.showTitleBar ? 'rgba(255, 255, 255, 1)' : 'rgba(255, 255, 255, 0)')
          .zIndex(1)
          .animation({ duration: 300 })

          Scroll(this.scroller) {
            Column() {
              Image(MyConfig.URL + this.currentData.image)
                .alt($r('app.media.active_no_color'))
                .width('100%')

              Column() {
                Text(`${this.currentData.name}`)
                  .fontSize(18)
                  .fontColor('#111111')
                  .lineHeight(25)
                  .fontWeight(700)
                  .margin({ bottom: 6 })

                Row() {
                  Row() {
                    Image(MyConfig.URL + 'new_home%2Faddr.svg?token=a96e854c-3e11-41ed-95c6-5ba5bba0b5fc')
                      .width(20)
                      .height(20)
                      .margin({ right: 4 })
                    Text(`${this.currentData.address}`)
                      .fontSize(14)
                      .fontColor('#cc000000')
                  }
                  .layoutWeight(1)
                  .margin({ right: 12 })

                  Column() {
                    Text('去这里').fontSize(14).fontColor('#ffffff').lineHeight(20)
                  }
                  .backgroundColor('#244AFD')
                  .padding({
                    left: 16,
                    right: 16,
                    top: 6,
                    bottom: 8
                  })
                  .borderRadius(20)
                  .onClick(() => {
                    let mapUrl = this.getUIContext().getHostContext()!.resourceManager.getStringByNameSync('map_url');
                    const bundleName = AppUtil.getBundleName();
                    const uri =
                      `${mapUrl}/routes?daddr=${this.currentData.latitude},${this.currentData.longitude}(${this.currentData.address})&type=drive&utm_source=${bundleName}}`;
                    let context = this.getUIContext().getHostContext()! as common.UIAbilityContext;
                    context.openLink(uri, {
                      appLinkingOnly: false
                    });
                  })
                }
                .width('100%')
                .margin({ bottom: 15 })

                Row() {
                  Column() {
                  }
                  .width(3)
                  .height(14)
                  .backgroundColor('#972EC3')
                  .borderRadius(1)
                  .margin({
                    right: 5
                  })

                  Text('活动简介')
                    .fontSize(16)
                    .fontColor('#111111')
                    .lineHeight(23)
                    .fontWeight(700)
                    .textAlign(TextAlign.Start)
                }
                .margin({
                  bottom: 9
                })

                Column() {
                  Text(`${this.currentData.desc}`)
                    .fontSize(14)
                    .lineHeight(21)
                    .fontColor('#99111111')
                }
                .borderRadius(20)
                .padding({
                  top: 16,
                  left: 12,
                  right: 12,
                  bottom: 126
                })
                .width('100%')
                .backgroundColor(Color.White)
                .shadow({
                  radius: vp2px(15),
                  color: '#0a000000',
                  offsetX: 0,
                  offsetY: vp2px(4)
                })
              }
              .alignItems(HorizontalAlign.Start)
              .padding({
                left: 16,
                right: 16,
                top: 20,
                bottom: 20
              })
              .margin({ top: '-6%' })
              .constraintSize({
                minHeight: 'calc(100% - 210vp)',
              })
              .width('100%')
              .linearGradient({
                angle: 180, // 角度
                colors: [
                  ['#F4F1EE', 0], // 起始色，透明度0.89
                  ['#F1F3F5', 1.0]// 终止色
                ]
              })
              .borderRadius({
                topLeft: 20,
                topRight: 20
              })
            }
          }
          .scrollBar(BarState.Off)
          .onWillScroll((xOffset: number, yOffset: number, scrollState: ScrollState) => {
            let scrollHeight = this.scroller.currentOffset().yOffset
            this.showTitleBar = scrollHeight > 210
          })
        }
      }

    }
    .hideTitleBar(true)
  }
}