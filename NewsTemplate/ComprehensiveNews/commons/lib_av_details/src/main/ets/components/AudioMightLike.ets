import { RouterMap, RouterUtils } from 'lib_common'
import { AvModel, HomeServiceApi, NewsEnum } from 'lib_news_api'
import { AvRouter } from '../utils/AvRouter'
import { AudioVM } from '../viewmodel/AudioViewModel'

@ComponentV2
export struct AudioMightLike {
  @Local broadcastList: AvModel[] = []
  @Local audioVM: AudioVM = new AudioVM()
  private avRouter: AvRouter = new AvRouter(this.getUIContext())

  async aboutToAppear() {
    this.broadcastList = await HomeServiceApi.queryBroadcastLike()
  }

  build() {
    Column({ space: 16 }) {
      Text('猜您喜欢').fontSize(18).fontWeight(FontWeight.Bold).fontColor($r('sys.color.font_primary'))
      List({ space: 12 }) {
        ForEach(this.broadcastList, (item: AvModel, index: number) => {
          ListItem() {
            Column({ space: 4 }) {
              Image(item.coverUrl)
                .objectFit(ImageFit.Fill)
                .borderRadius(8)
                .clip(true)
                .width('100%')
                .height(this.audioVM.getBroadcastSize())
              Text(item.title)
                .fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
            }
            .onClick(() => {
              // 移除栈内audio详情
              RouterUtils.getStack().removeByName(RouterMap.AUDIO_PLAYING_DETAILS)
              RouterUtils.getStack().removeByName(RouterMap.AUDIO_DETAILS)
              const params: Record<string, string | NewsEnum> = {
                'id': item.id,
                'type': item.type,
              }
              this.avRouter.pushToAvDetails(params,
                'broadcast_like_flow_tb' + item.id + index)
            })
          }
        }, (item: AvModel) => item.id)
      }
      .scrollBar(BarState.Off)
      .lanes(this.audioVM.getBroadcastLanes(), 12)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST,
      })
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .layoutWeight(1)
    }
    .padding({ left: 16, right: 16 })
    .alignItems(HorizontalAlign.Start)
  }
}