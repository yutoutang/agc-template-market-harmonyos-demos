import { Constants } from '../commons/Constants';

@ComponentV2
export struct SearchBar {
  @Param
  placeholder: string = ''
  @Param
  searchWords: string = '';
  @Param
  disabled: boolean = false;
  @Event
  updateSearchWords: (value: string) => void = () => {
  };
  @Event
  clickBack: () => void = () => {
  };
  @Event
  submitSearch: (value: string) => void = () => {
  };
  controller: SearchController = new SearchController();
  SEARCH_BAR_ID = 'search_bar';

  build() {
    Row() {
      Row() {
        Image($r('app.media.ic_left_arrow'))
          .width(24)
          .height(24)
          .fillColor(Constants.FONT_COLOR_LEVEL1);
      }
      .width(40)
      .height(40)
      .borderRadius(Constants.BORDER_RADIUS_CAPSULE)
      .backgroundColor(Constants.BACKGROUND_COLOR_GREY_2)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .margin({ right: Constants.SPACE_S })
      .onClick(() => {
        this.clickBack?.();
      });

      if (this.disabled) {
        Row() {
          Text(this.searchWords)
            .fontColor(Constants.FONT_COLOR_LEVEL2)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .height(40)
        .layoutWeight(1)
        .padding({ left: Constants.SPACE_L })
        .margin({
          top: Constants.SPACE_S,
          bottom: Constants.SPACE_S,
        })
        .borderRadius(Constants.BORDER_RADIUS_CAPSULE)
        .backgroundColor(Constants.BACKGROUND_COLOR_GREY_2)
        .onClick(() => {
          this.clickBack?.();
        });
      } else {
        Search({
          value: this.searchWords,
          controller: this.controller,
          placeholder: this.placeholder ? this.placeholder : '请输入搜索内容',
        })
          .layoutWeight(1)
          .backgroundColor(Constants.BACKGROUND_COLOR_GREY_2)
          .searchButton('搜索', {
            fontColor: Constants.THEME_COLOR,
          })
          .defaultFocus(true)
          .enableKeyboardOnFocus(true)
          .searchIcon({ size: 0 })
          .caretStyle({ color: Constants.THEME_COLOR })
          .id(this.SEARCH_BAR_ID)
          .onVisibleAreaChange([1], (_isExpanding: boolean, currentRatio: number) => {
            if (currentRatio === 1) {
              this.getUIContext().getFocusController().requestFocus(this.SEARCH_BAR_ID);
            }
          })
          .onChange((value) => {
            this.updateSearchWords?.(value);
          })
          .onSubmit((value) => {
            this.submitSearch?.(value ? value : this.placeholder);
          });
      }
    }
    .padding({
      left: Constants.SPACE_L,
      right: Constants.SPACE_S,
    })
    .backgroundColor(Constants.BACKGROUND_COLOR)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);

  }
}