import { AppStorageV2, curves, SymbolGlyphModifier } from '@kit.ArkUI';
import {
  BreakpointModel,
  BreakpointNameEnum,
  CircleButtonModifier,
  RouterMap,
  RouterUtils,
} from 'lib_common';

@ComponentV2
export struct NewsSearchTransition {
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local buttonModifier: CircleButtonModifier = new CircleButtonModifier();
  @Param componentId: string = ''
  @Param isVideo: boolean = false
  @Param indicatorIndex: number = 0

  @Computed
  get isSmOrMdDevice() {
    const breakpointNames = [BreakpointNameEnum.SM, BreakpointNameEnum.MD]
    return breakpointNames.includes(this.breakpointModel.currentBreakpoint);
  }
  @Computed
  get searchColor() {
    if (this.isVideo) {
      return this.indicatorIndex > 1 ? $r('sys.color.font_secondary') : '#99FFFFFF'
    }
    return $r('sys.color.font_secondary')
  }

  @Computed
  get searchBgColor() {
    if (this.isVideo) {
        return this.indicatorIndex > 1 ? $r('app.color.comment_input_bg') : '#393a3d'
    }
    return $r('app.color.comment_input_bg');
  }

  pushLongTakeToSearchPage(componentId: string) {
    this.getUIContext().animateTo({
      curve: curves.interpolatingSpring(0, 1, 342, 38),
    }, () => {
      RouterUtils.pushPathByName(RouterMap.NEWS_SEARCH, componentId, () => {
      }, false);
    })
  }

  pushToSearchPage() {
    RouterUtils.pushPathByName(RouterMap.NEWS_SEARCH);
  }

  build() {
    Column() {
      Column({ space: 20 }) {
        Search({ placeholder: '搜索' })
          .placeholderColor(this.searchColor)
          .width(400)
          .geometryTransition('news_search_transition_' + this.componentId, { follow: true })
          .backgroundColor(this.searchBgColor)
          .defaultFocus(false)
          .focusOnTouch(false)
          .focusable(false)
          .accessibilityText('搜索按钮')
          .searchIcon(new SymbolGlyphModifier($r('sys.symbol.magnifyingglass')).fontColor([this.searchColor]))
          .onClick(() => {
            this.pushLongTakeToSearchPage(this.componentId);
          })
      }
      .visibility(this.isSmOrMdDevice ? Visibility.None : Visibility.Visible)

      Button() {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontColor([this.isVideo ?
            this.indicatorIndex > 1 ? $r('sys.color.font_primary') : Color.White : $r('sys.color.font_primary')])
          .fontWeight(FontWeight.Normal)
          .fontSize(24)
      }
      .attributeModifier(this.buttonModifier)
      .accessibilityText('搜索')
      .onClick(() => {
        this.pushToSearchPage();
      })
      .visibility(this.isSmOrMdDevice ? Visibility.Visible : Visibility.None)
    }
  }
}
