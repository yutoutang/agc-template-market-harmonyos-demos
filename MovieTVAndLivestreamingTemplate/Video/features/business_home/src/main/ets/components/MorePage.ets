import { RouterMap, RouterUtils, WindowModel } from 'lib_common';
import { VideoModel } from 'lib_video_api';
import { NavHeaderBar } from 'lib_widget';
import { MorePageParams } from '../model/TabInfoModel';
import { FlexLayoutModel } from '../viewmodels/FlexLayoutModel';
import { AppStorageV2 } from '@kit.ArkUI';

@Builder
export function MorePageBuilder() {
  MorePage()
}

@ComponentV2
export struct MorePage {
  @Local vm: FlexLayoutModel = new FlexLayoutModel();
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;

  async aboutToAppear() {
    // 页面即将显示时初始化，传入默认索引0（推荐频道）
    this.vm.init(0);
  }

  build() {
    NavDestination() {
      // 导航栏
      NavHeaderBar({
        title: this.vm.title,
        rightPartBuilder: () => {
          this.titleBarBuilder()
        },
      })
      Scroll() {
        this.listBuilder()
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .onReachEnd(() => {
        this.vm.loadMore();
      })
    }
    .padding({
      bottom: this.windowModel.windowBottomPadding
    })

    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      // 页面就绪后处理参数（如从其他页面跳转携带的标题和索引）
      if (context.pathInfo.param) {
        const param = context.pathInfo.param as MorePageParams;
        this.vm.getTitle(param.title, param.currentIndex);
        // 强制触发视图更新，确保参数生效后数据同步渲染
      }
    })
    .backgroundColor($r('sys.color.background_primary'))
  }

  /**
   * 列表构建器（Grid布局，支持网格/列表切换）
   */
  @Builder
  listBuilder() {
    Column() {
      GridRow({ columns: this.vm.isGrid ? 2 : 1, gutter: 10 }) {
        ForEach(this.vm.videoModelList, (item: VideoModel) => {
          GridCol() {
            Column({ space: 6 }) {
              if (this.vm.isGrid) {
                // 网格布局样式
                Stack() {
                  Image(item.coverUrl)
                    .width('100%')
                    .aspectRatio(16 / 9)
                    .borderRadius(8)
                    .objectFit(ImageFit.Cover)

                  // 视频类型和集数标签
                  Row() {
                    Text(item.contentType === 'tv_movie' ? '电视剧' : '电影')
                      .fontColor('#FFFFFFFF')
                      .fontWeight(FontWeight.Bold)
                      .padding({
                        left: 3,
                        right: 3,
                        top: 1,
                        bottom: 1
                      })
                      .fontSize(8)
                      .lineHeight(9)
                      .backgroundColor('#FF2A2F43')
                      .border({ width: 1, color: '#1AFFFFFF', radius: 3 })

                    Text(`全${item.videoUrl?.length || 0}集`)
                      .fontColor('#FFFFFFFF')
                      .fontSize(8)
                      .lineHeight(9)
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                  .padding(4)
                }
                .alignContent(Alignment.Bottom)

                // 视频标题
                Text(item.title || '未知标题')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .textAlign(TextAlign.Start)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')

                // 视频简介
                Text(item.synopsis || '')
                  .fontSize(12)
                  .textAlign(TextAlign.Start)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                  .opacity(0.8)
              } else {
                // 列表布局样式
                Row({ space: 12 }) {
                  Image(item.coverUrl)
                    .width(52)
                    .height(72)
                    .borderRadius(4)
                    .objectFit(ImageFit.Cover)

                  Column({ space: 4 }) {
                    Text(item.title || '未知标题')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .textAlign(TextAlign.Start)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width('100%')

                    Text(item.synopsis || '')
                      .fontSize(12)
                      .textAlign(TextAlign.Start)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width('100%')
                      .opacity(0.8)

                    Text(`全${item.videoUrl?.length || 0}集`)
                      .fontSize(12)
                      .textAlign(TextAlign.Start)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width('100%')
                      .opacity(0.8)
                  }
                  .layoutWeight(1)
                  .justifyContent(FlexAlign.Start)
                }
                .width('100%')
                .padding({ top: 8, bottom: 8 })

                Divider()
              }
            }
            .alignItems(HorizontalAlign.Start)
            .onClick(() => {
              // 跳转播放页
              const param: Record<string, Object> = { 'videoId': item.videoId };
              RouterUtils.pushPathByName(RouterMap.PLAY_PAGE, param);
            })
          }
        }, (item: VideoModel) => JSON.stringify(item))
      }.width('100%')

      Column({ space: 8 }) {
        // 加载中：转圈动画 + 文字
        if (this.vm.isLoadingMore) {
          Text('加载中...')
            .fontSize(14)
            .fontColor('#99000000')
        } else if (!this.vm.hasMore && this.vm.videoModelList.length > 0) {
          Text('已加载完所有数据')
            .fontSize(14)
            .fontColor('#99000000')
        }
      }
      .padding(16)
      .justifyContent(FlexAlign.Center)
      .width('100%')
    }
    .padding({ left: 16, right: 16 })
    .alignItems(HorizontalAlign.Center)
    .width('100%')
  }

  /**
   * 标题栏右侧切换按钮（网格/列表）
   */
  @Builder
  titleBarBuilder() {
    Row() {
      Image(this.vm.isGrid ? $r('app.media.ic_Navigation_Right') : $r('app.media.ic_Navigation_left'))
        .width(40)
        .aspectRatio(1)
        .objectFit(ImageFit.Contain)
        .onClick(() => {
          this.vm.isGrid = !this.vm.isGrid;
        })
    }
    .justifyContent(FlexAlign.End)
    .layoutWeight(1)
    .padding({ right: 8 })
  }
}