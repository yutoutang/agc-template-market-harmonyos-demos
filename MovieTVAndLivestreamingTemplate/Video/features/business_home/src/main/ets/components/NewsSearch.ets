import { CommonConstants, RouterMap, RouterUtils } from 'lib_common';
import { VideoModel, VideoResponse } from 'lib_video_api';
import { NavHeaderBar } from 'lib_widget';
import { Highlight } from 'module_highlight';
import { promptAction } from '@kit.ArkUI';
import { NewsSearchViewModel } from '../viewmodels/NewsSearchViewModel';

@Builder
export function NewsSearchBuilder() {
  NewsSearch()
}

@ComponentV2
export struct NewsSearch {
  controller: SearchController = new SearchController();
  @Local vm: NewsSearchViewModel = new NewsSearchViewModel();
  @Local isSearchCommit: boolean = false;

  aboutToAppear() {
    this.vm.init()
  }

  build() {
    NavDestination() {
      NavHeaderBar({
        rightPartBuilder: () => {
          this.searchBuilder()
        },
      })
      Scroll() {
        Column() {
          if (this.vm.searchValue.trim() !== '') {
            this.searchResultListBuilder()
            this.relatedWorksBuilder()
          } else {
            this.historySearch()
            this.recommendBuilder()
            this.hotTopChartList()
          }
        }
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1)
      .align(Alignment.Top)
    }
    .onReady((context) => {
      const param = context.pathInfo.param as string
      if (param) {
        this.vm.searchValue = param
        this.vm.search(this.vm.searchValue)
      }
    })
    .hideTitleBar(true)
    .backgroundColor('#FFF1F3F5')
    .padding({ top: 8, bottom: this.vm.windowModel.windowBottomPadding })
  }

  @Builder
  searchBuilder() {
    Search({ value: $$this.vm.searchValue, controller: this.controller, placeholder: this.vm.placeValue })
      .maxLength(20)
      .fontColor($r('sys.color.font_primary'))
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .textFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Regular })
      .layoutWeight(1)
      .defaultFocus(true)
      .placeholderColor($r('sys.color.font_secondary'))
      .onChange((value) => {
        this.vm.searchValue = value
        this.vm.searchChange(this.vm.searchValue)
      })
      .onFocus(() => {
        this.isSearchCommit = false
      })
      .onSubmit(() => {
        if (this.vm.searchValue.trim().length > 20) {
          promptAction.showToast({ message: '请输入小于20个字符的搜索内容' });
          return
        }
        this.vm.addSearchHistory(this.vm.searchValue);
        this.isSearchCommit = true
      })
  }

  // 历史
  @Builder
  historySearch() {
    Column({ space: 12 }) {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Text('历史搜索')
          .fontSize(16)
          .lineHeight(20)
          .fontColor('#E6000000')
          .fontWeight(FontWeight.Medium)

        if (this.vm.isEditing) {
          Row({ space: 6 }) {
            Text('全部删除')
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
              .onClick(() => {
                this.vm.clearHistory()
              })
            Text('|')
              .fontSize(10)
              .fontColor($r('sys.color.font_secondary'))
            Text('完成')
              .fontSize(12)
              .fontColor($r('sys.color.font_secondary'))
              .onClick(() => {
                this.vm.isEditing = !this.vm.isEditing
              })
          }
        } else {
          Image($r('app.media.clear')).width(24).height(24)
            .onClick(() => {
              this.vm.isEditing = !this.vm.isEditing
            })
        }
      }

      Flex({ justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
        Row() {
          Text('暂无历史搜索')
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
        }
        .visibility(this.vm.searchHistory.historyList.length <= 0 ? Visibility.Visible : Visibility.None)
        .width('100%')
        .justifyContent(FlexAlign.Center)

        ForEach(this.vm.searchHistory.historyList, (item: string, index: number) => {
          Row({ space: 6 }) {
            Text(item)
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textAlign(TextAlign.Center)
              .textOverflow({
                overflow: TextOverflow.Ellipsis
              })
            Row() {
              Text('X')
                .fontSize(8)
                .fontColor($r('sys.color.font_primary'))
            }
            .borderRadius(14)
            .backgroundColor('#FFF1F3F5')
            .padding({
              left: 4,
              right: 4,
              top: 2,
              bottom: 2,
            })
            .visibility(this.vm.isEditing ? Visibility.Visible : Visibility.None)
          }
          .padding({
            left: 12,
            right: this.vm.isEditing ? 5 : 12,
            top: 4,
            bottom: 4,
          })
          .onClick(() => {
            if (this.vm.isEditing) {
              this.vm.searchHistory.historyList = this.vm.searchHistory.historyList.filter((_, i) => i !== index)
            } else {
              this.vm.searchValue = item
              this.vm.search(this.vm.searchValue)
              this.controller.stopEditing()
              this.isSearchCommit = true
            }
          })
          .margin({ right: 12, bottom: 12 })
          .borderRadius(14)
          .backgroundColor('#0D000000')
          .visibility(this.vm.searchHistory.historyList?.length <= 0 ? Visibility.None : Visibility.Visible)
        }, (item: string, index: number) => item + index)
      }
    }
    .padding({
      left: CommonConstants.PADDING_PAGE,
      right: CommonConstants.PADDING_PAGE
    })
    .margin({ top: 16 })
    .visibility(this.vm.searchHistory.historyList.length > 0 ? Visibility.Visible : Visibility.None)
  }

  //猜你喜欢
  @Builder
  recommendBuilder() {
    Column({ space: 12 }) {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Text('猜你喜欢')
          .fontSize(16)
          .lineHeight(20)
          .fontColor('#E6000000')
          .fontWeight(FontWeight.Medium)
        Row({ space: 5 }) {

          Text('换一换')
            .fontSize(13)
            .lineHeight(18)
            .fontColor('#99000000')
          Image($r('app.media.flushed')).width(24).aspectRatio(1)
        }
        .onClick(() => {
          this.vm.refreshRecommendSearch();
        })
      }

      Flex({ justifyContent: FlexAlign.Start, wrap: FlexWrap.Wrap }) {
        Row() {
          Text('推荐搜索')
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'))
        }
        .visibility(this.vm.allSwiperList.length <= 0 ? Visibility.Visible : Visibility.None)
        .width('100%')
        .justifyContent(FlexAlign.Center)

        ForEach(this.vm.recommendSearchList, (item: VideoModel) => {
          Row() {
            Text(item.title)
              .fontSize(14)
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Medium)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .padding({
            left: 12,
            right: 12,
            top: 4,
            bottom: 4,
          })
          .onClick(() => {
            this.vm.searchValue = item.title
            this.vm.search(this.vm.searchValue)
            this.controller.stopEditing()
            this.isSearchCommit = true
          })
          .margin({ right: 12, bottom: 12 })
          .visibility(this.vm.allSwiperList.length <= 0 ? Visibility.None : Visibility.Visible)
        }, (item: VideoModel) => JSON.stringify(item))
      }
    }
    .padding({
      left: CommonConstants.PADDING_PAGE,
      right: CommonConstants.PADDING_PAGE
    })
    .margin({ top: 16 })
  }

  //搜索结果
  @Builder
  searchResultListBuilder() {
    List({ space: 20 }) {
      if (this.vm.searchResultList.length <= 0) {
        ListItem() {
          Column() {
            Image($r('app.media.search_no_result')).width(120).height(120)
            Text('暂无搜索结果')
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))
          }
        }
        .width('100%')
        .height('100%')
      } else {
        ForEach(this.vm.searchResultList, (item: VideoModel) => {
          ListItem() {
            Column() {
              Row({ space: 10 }) {
                Image($r('app.media.ic_search_result'))
                  .width(24)
                  .height(24)
                  .borderRadius(7)
                Highlight({
                  // 1. 关键词：过滤空值，确保数组非空（避免搜索值为空时异常）
                  keywords: this.vm.searchValue.trim() ? [this.vm.searchValue.trim()] : [],
                  // 2. 源文本：传递完整标题，不截断
                  sourceString: item.title || '',
                  // 3. 非高亮颜色：与页面文本颜色一致（#E6000000）
                  textColor: '#E6000000',
                  // 4. 高亮颜色：设为目标色（如你之前的#FFFD603E，或红色#FF0000）
                  highLightColor: '#FFFD603E',
                  // 5. 文字大小：与原Text样式一致（14）
                  textFontSize: 16,
                  // 6. 高亮文字大小：与非高亮一致，保持样式统一
                  highLightFontSize: 16,
                  // 7. 文字字重：高亮部分加粗，突出显示
                  textFontWeight: FontWeight.Medium,
                  // 8. 最大行数：1行，避免换行
                  maxLines: 1,
                  // 9. 溢出处理：超出部分显示省略号
                  overflow: TextOverflow.Ellipsis
                }).width('100%') // 占满父容器宽度，确保溢出省略生效
              }
              .width('100%')
              .padding({
                top: 12, bottom: 12
              })
              .onClick(() => {
                this.vm.searchValue = item.title
                this.vm.search(this.vm.searchValue)
                this.controller.stopEditing()
                this.isSearchCommit = true
              })

              Divider()
            }
          }
        }, (item: VideoModel) => JSON.stringify(item))
      }
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .layoutWeight(1)
    .padding({ left: 16, right: 16 })
    .visibility(this.isSearchCommit ? Visibility.None : Visibility.Visible)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  // 热搜
  @Builder
  hotTopChartList() {
    Column({ space: 15 }) {
      Text('热搜榜')
        .width('100%')
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .fontSize(18)
        .margin({ left: 4, top: 4 })
      Grid() {
        ForEach(this.vm.hitList, (item: VideoModel, index: number) => {
          GridItem() {
            Row({ space: 6 }) {
              Text(`${index + 1}`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(index === 0 || index === 1 || index === 2 ? '#FFE84026' : $r('sys.color.font_secondary'))
                .width(30)
                .textAlign(TextAlign.Center)
                .margin({ right: 10 })
              Image(item.coverUrl)
                .width(56)
                .height(75)
                .objectFit(ImageFit.Cover)
                .borderRadius(7)
                .onClick(() => {
                  const param: Record<string, Object> = {
                    'videoId': item.videoId
                  }
                  RouterUtils.pushPathByName(RouterMap.PLAY_PAGE, param);
                })
              Column({ space: 10 }) {
                Row({ space: 6 }) {
                  Text(item.title)
                    .fontSize(14)
                    .textAlign(TextAlign.Start)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .fontWeight(FontWeight.Medium)

                  if (index === 0) {

                    Text('爆')
                      .fontSize(11)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#FFFFFF')
                      .backgroundColor('#FF5722')
                      .borderRadius(3)
                      .padding({
                        left: 3,
                        right: 3,
                        top: 1,
                        bottom: 1
                      })
                  }
                }
                .width('100%')
                .justifyContent(FlexAlign.Start)

                Text(`${item.playCount}次播放`)
                  .fontSize(12)
                  .lineHeight(14)
                  .fontColor('#99000000')
                  .width('100%')
                  .textAlign(TextAlign.Start)// 居左对齐
                  .maxLines(1)// 最大行数为1行
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .layoutWeight(1)
            }
            .justifyContent(FlexAlign.Start)
          }
        }, (item: VideoModel) => JSON.stringify(item))
      }
      .columnsTemplate('1fr')
      .rowsGap(10)
      .columnsGap(10)
    }
    .padding(12)
    .backgroundColor('#FFFFFFFF')
    .margin(16)
    .borderRadius(20)
  }

  // 相关内容
  @Builder
  relatedWorksBuilder() {
    Column() {
      if (this.vm.searchResultList.length <= 0) {
        Column() {
          Image($r('app.media.search_no_result')).width(120).height(120)
          Text('暂无搜索结果')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Column() {
          Text('相关内容')
            .fontSize(18)
            .lineHeight(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#E6000000')
            .padding({ top: 16, bottom: 16 })
            .width('100%')
          GridRow({
            columns: 2,
            gutter: 8,
          }) {
            ForEach(this.vm.searchResultList, (item: VideoResponse) => {
              GridCol() {
                Column({ space: 8 }) {
                  Image(item.coverUrl)
                    .width('100%')
                    .aspectRatio(16 / 9)
                    .borderRadius(8)
                  // 核心修改：用Highlight组件替换Text，实现关键词红色高亮
                  Highlight({
                    // 1. 关键词：过滤空值，确保数组非空（避免搜索值为空时异常）
                    keywords: this.vm.searchValue.trim() ? [this.vm.searchValue.trim()] : [],
                    // 2. 源文本：传递完整标题，不截断
                    sourceString: item.title || '',
                    textColor: '#E6000000',
                    // 4. 高亮颜色：设为目标色（如你之前的#FFFD603E，或红色#FF0000）
                    highLightColor: '#FFFD603E',
                    // 5. 文字大小：与原Text样式一致（14）
                    textFontSize: 14,
                    // 6. 高亮文字大小：与非高亮一致，保持样式统一
                    highLightFontSize: 14,
                    // 7. 文字字重：高亮部分加粗，突出显示
                    textFontWeight: FontWeight.Medium,
                    // 8. 最大行数：1行，避免换行
                    maxLines: 1,
                    // 9. 溢出处理：超出部分显示省略号
                    overflow: TextOverflow.Ellipsis
                  })
                    .width('100%') // 占满父容器宽度，确保溢出省略生效
                  Text(item.synopsis)
                    .fontColor('#99000000')
                    .fontSize(10)
                    .lineHeight(11)
                    .width('100%')
                    .textAlign(TextAlign.Start)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .onClick(() => {
                  const param: Record<string, Object> = {
                    'videoId': item.videoId
                  }
                  RouterUtils.pushPathByName(RouterMap.PLAY_PAGE, param);
                })
              }
              .width(100)
            }, (item: VideoResponse) => JSON.stringify(item))
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start) // 确保内容从顶部开始
        .padding({ left: 16, right: 16, bottom: this.vm.windowModel.windowBottomPadding })
      }
    }.visibility(this.isSearchCommit ? Visibility.Visible : Visibility.None)
  }
}