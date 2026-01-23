import { BasicDataSource } from '../common/BasicDataSource';
import { Constants } from '../common/Constant';
import { GridRowColSetting } from '../common/GridRowColSetting';
import { SearchItem } from '../types/Type';
import { getColor, getMedia, getString } from '@agctemplate/resources'

@ComponentV2
export struct HotSearch {
  @Param breakpoint: string = 'sm';
  @BuilderParam itemBuilderParam: WrappedBuilder<[SearchItem, number]>;
  @Event getMore: () => void = () => {
  }
  @Event selectHotSearchItem: (listItem: SearchItem, index?: number) => void = () => {
  }
  @Event queryHotSearchList: () => Promise<SearchItem[]> = () => Promise.resolve([]);
  @Param hotSearchList: SearchItem[] = []
  @Local dataSource: BasicDataSource<SearchItem> = new BasicDataSource()

  aboutToAppear(): void {
    // this.queryHotSearchList().then((hotSearchList) => {
    //   this.hotSearchList = hotSearchList;
    this.dataSource.setData(this.hotSearchList);
    // })
  };

  build() {
    Column() {
      Row() {
        Column() {
          Image(getMedia('app.media.hot'))
            .width(24)
            .height(24)
        }

        Text('热搜榜')
          .fontSize($r('sys.float.Subtitle_L'))
          .fontWeight(FontWeight.Bold)
          .fontFamily('HarmonyHeiTi')

        // Row({ space: Constants.SPACE_SPECIAL }) {
        //   Text('更多')
        //     .fontColor($r('sys.color.font_secondary'))
        //     .fontSize($r('sys.float.Body_M'))
        //     .fontWeight(FontWeight.Regular)
        //     .fontFamily('HarmonyHeiTi')
        //     .textAlign(TextAlign.End)
        //
        //   SymbolGlyph($r('sys.symbol.chevron_right'))
        //     .fontSize(Constants.CHEVRON_WIDTH)
        //     .fontColor([$r('sys.color.icon_tertiary')])
        // }
        // .onClick(() => {
        //   this.getMore()
        // })
      }
      .width(Constants.FULL_PERCENT)
      .height(Constants.HISTORY_HEIGHT)
      .justifyContent(FlexAlign.Start)
      .padding({
        left: Constants.PADDING_M,
        right: Constants.PADDING_M,
        top: Constants.PADDING_XL,
        bottom: Constants.PADDING_S,
      })
      .margin({ bottom: Constants.SPACE_S })

      List({ space: Constants.SPACE_S }) {
        LazyForEach(this.dataSource, (listItem: SearchItem, index: number) => {
          ListItem() {
            if (this.itemBuilderParam !== undefined) {
              this.itemBuilderParam.builder(listItem, index)
            } else {
              this.itemBuilder(listItem, index + 1)
            }
          }
          .onClick(() => {
            this.selectHotSearchItem(listItem)
          })
        }, (listItem: SearchItem) => JSON.stringify(listItem.title))
      }
      .padding({
        left: Constants.PADDING_M
      })
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.PARENT_FIRST
      })
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)
      .lanes(GridRowColSetting.getShowResult(this.breakpoint), 24)
      .width(Constants.FULL_PERCENT)
    }
    .borderRadius(16)
    .backgroundColor($r('sys.color.background_primary'))
    .padding({ bottom: Constants.PADDING_L })
    .margin({ top: Constants.PADDING_S })
  }

  getRankBackgroundColor(rankId?: number): Resource {
    switch (rankId) {
      case 1:
        return getColor('app.color.billboard_rank_top')
      case 2:
        return getColor('app.color.billboard_rank_next')
      case 3:
        return getColor('app.color.billboard_rank_third')
      default:
        return getColor('app.color.billboard_rank_other')
    }
  }

  getCoverEpisodeShowText(isEnd: boolean, episodes: number, latestUpdate: number) {
    return isEnd ? getString('app.string.cover_episode_info', episodes.toString()) :
      getString('app.string.cover_update_info', latestUpdate.toString())
  }

  @Builder
  episodeInfoBuilder(latestUpdate: number, episodes: number) {
    Column() {
      Text(this.getCoverEpisodeShowText(latestUpdate === episodes, episodes, latestUpdate))
        .padding({
          top: 1,
          right: 8,
          bottom: 1,
          left: 8
        })
        .borderRadius(14)
        .fontSize(10)
        .fontColor(Color.White)
        .backgroundColor($r('sys.color.mask_tertiary'))
        .height(16)
    }
    .padding({
      right: 2, bottom: 2,
    })
    .height(18)
    .alignItems(HorizontalAlign.End)
  }

  @Builder
  itemBuilder(listItem: SearchItem, index: number) {
    Column() {
      Row() {
        Column() {
          Stack() {
            Text(index.toString())
              .padding({
                top: 1,
                right: 8,
                bottom: 1,
                left: 8
              })
              .fontSize(10)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Medium)
              .borderRadius({
                topLeft: 8, bottomRight: 8
              })
              .backgroundColor(this.getRankBackgroundColor(index))
              .zIndex(100)
            Image(listItem.image)
              .width(78)
              .height(96)
              .borderRadius(8)
              .overlay(this.episodeInfoBuilder(listItem.episodes, listItem.latestUpdate),
                { align: Alignment.BottomEnd })
          }
          .alignContent(Alignment.TopStart)
        }

        Column() {
          Row() {
            Text(listItem.title)
              .maxLines(1)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)

            Row() {
              Image(getMedia('app.media.hot_search'))
                .width(16)
                .margin({ right: 2 })
              Text(index === 1 ? '180.4万' : index === 2 ? '146.4万' :
                index === 3 ? '80.4万' : index === 4 ? '63.7万' : '60.4万')
                .fontSize(12)
                .fontWeight(500)
                .fontColor('#e6000000')
            }
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.End)
            .layoutWeight(1)

          }
          .height(19)
          .width('100%')
          .padding({ right: 16 })
          .margin({
            bottom: 0
          })
          .alignItems(VerticalAlign.Top)

          Row() {
            ForEach(listItem.tags, (tag: string) => {
              Text(tag)
                .width(28)
                .height(16)
                .backgroundColor('#0d000000')
                .fontSize(10)
                .fontWeight(400)
                .fontColor('#e6000000')
                .textAlign(TextAlign.Center)
                .margin({ right: 8 })
                .borderRadius(4)
            }, (tag: string) => tag)
          }
          .height(16)
          .margin({ top: 8, bottom: 8 })
          .alignItems(VerticalAlign.Center)

          Row() {
            Text(listItem.intro)
              .maxLines(2)
              .fontSize(12)
              .fontColor(getColor('app.color.normal_font_color'))
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .height(38)
          .margin({ bottom: 8 })
          .padding({ right: 16 })

        }
        .width(244)
        .margin({
          left: 16
        })
        .alignItems(HorizontalAlign.Start)
      }
      .alignItems(VerticalAlign.Top)
    }
    .alignItems(HorizontalAlign.Start)
  }
}

@Extend(Text)
function textStyles() {
  .textAlign(TextAlign.Start)
  .width(Constants.FULL_PERCENT)
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .fontSize($r('sys.float.Body_M'))
}