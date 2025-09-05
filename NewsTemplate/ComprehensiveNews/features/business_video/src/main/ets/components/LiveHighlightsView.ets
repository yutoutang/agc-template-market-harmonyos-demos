import { BreakpointNameEnum, BreakpointType, CommonConstants } from 'lib_common';
import { VideoNewsData } from '../models/VideoModel';
import { LivestreamCard } from './LivestreamCard';

@ComponentV2
export struct LiveHighlightsView {
  @Param liveHighlightsList: VideoNewsData[] = [];
  @Param currentBreakpoint: BreakpointNameEnum = BreakpointNameEnum.SM

  lanesOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 2,
    md: 4,
    lg: 6,
    xl: 6,
  });

  getLanes() {
    const count = this.lanesOptions.getValue(this.currentBreakpoint);
    return count;
  }

  build() {
    List({
      space: this.currentBreakpoint === BreakpointNameEnum.SM ?
      CommonConstants.SPACE_L : CommonConstants.SPACE_XL
    }) {
      ForEach(this.liveHighlightsList, (item: VideoNewsData, index: number) => {
        ListItem() {
          LivestreamCard({
            cardData: item,
          })
        }
      }, (item: VideoNewsData, index: number) => item.id + index)
    }
    .width(CommonConstants.FULL_PERCENT)
    .edgeEffect(EdgeEffect.None)
    .scrollBar(BarState.Off)
    .padding({top: CommonConstants.PADDING_XL})
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST,
    })
    .lanes(
      this.getLanes(),
      this.currentBreakpoint === BreakpointNameEnum.SM ? 8 : 12
    )
  }
}