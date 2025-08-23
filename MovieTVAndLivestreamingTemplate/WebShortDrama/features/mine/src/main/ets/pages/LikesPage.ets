import { jumpDetailPage, ParamsModel } from '@agctemplate/detail';
import { getString } from '@agctemplate/resources';
import { MyWatchRecordData, RequestAPI } from '@agctemplate/server';
import { appRouter, container, WindowManager } from '@agctemplate/utils';
import { NavDestinationModifier } from '@agctemplate/widgets'
import { VideoSeries } from '../component/VideoSeries';
import { Header } from '../component/Header';
import { MyLikeDramaData, MyLikeDramaRes } from '@agctemplate/server/src/main/ets/bean/response/MyLikeDramaRes';
import { getDramaInfo, setLike } from '@agctemplate/server/src/main/ets/api/mock/mockData/mockDramaFactory';

@ComponentV2
export struct LikesPage {
  @Local myLikeRes: MyLikeDramaRes = new MyLikeDramaRes();
  navDestinationModifier: NavDestinationModifier = new NavDestinationModifier();

  aboutToAppear(): void {
    container.resolve(RequestAPI).getMyLikeDrama({
      pageSize: 1,
      pageNum: 20
    }).then((res) => {
      this.myLikeRes = new MyLikeDramaRes(res.getBody());
    })
  }

  build() {
    NavDestination() {
      Column() {
        Header({ title: getString('app.string.my_like') })
        Column() {
          if (this.myLikeRes.myLikeDramas.length > 0) {
            this.LikesItemsBuilder()
          } else {
            Text('暂无观看记录')
              .height('100%')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.icon_secondary'))
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .height('100%')
      .width('100%')

    }
    .onBackPressed(() => {
      appRouter.back(true)
      return true
    })
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.comp_background_gray'))
    .attributeModifier(this.navDestinationModifier)

  }

  @Builder
  LikesItemsBuilder() {
    Grid() {
      Repeat<MyLikeDramaData>(this.myLikeRes.myLikeDramas)
        .each((ri: RepeatItem<MyLikeDramaData>) => {
          GridItem() {
            VideoSeries({
              title: ri.item.name,
              currentEpisode: ri.item.currentWatch + 1,
              totalCount: ri.item.totalCount,
              cover: ri.item.coverUrl,
              likeCount: ri.item.likeCount,
              isLike: true,
              isVip: ri.item.isVip,
              onContinueWatch: () => {
                jumpDetailPage(ri.item, ri.item.currentWatch, 0, (params) => {
                  WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
                  const paramsInfo = params.result as ParamsModel
                  const drama = getDramaInfo(paramsInfo.id)
                  drama.curIndex = paramsInfo.curIndex
                  this.updateLikes()
                })
              }
            })
          }
        })
        .key((item: MyLikeDramaData, index: number): string => item.id)// 键值生成函数
        .virtualScroll({
          totalCount: this.myLikeRes.myLikeDramas.length
        }) // 打开virtualScroll模式，totalCount为期望加载的数据长度
    }
    .edgeEffect(EdgeEffect.Spring)
    .columnsTemplate('1fr 1fr 1fr')
    .scrollBar(BarState.Off)
    .cachedCount(4) // 容器组件的预加载区域大小
    .margin({ bottom: 60 })
  }

  updateLikes() {
    container.resolve(RequestAPI).getMyLikeDrama({
      pageSize: 1,
      pageNum: 20
    }).then((res) => {
      this.myLikeRes = new MyLikeDramaRes(res.getBody());
    })
  }
}

@Builder
export function LikesPageBuilder() {
  LikesPage()
}