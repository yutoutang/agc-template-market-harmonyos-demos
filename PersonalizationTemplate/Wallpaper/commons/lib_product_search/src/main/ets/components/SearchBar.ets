import { Constants } from '../commons/Constants';
import { HistorySearchItem } from '../commons/Types';
import { SearchController as BusinessSearchController } from '../controller/SearchController';
import { SearchVM } from '../viewmodels/SearchVM';

@ComponentV2
export struct SearchBar {
  @Consumer('searchNewWords') searchWords: string = '';
  @Param placeholderText: string = '';
  @Param disabled: boolean = false;
  @Param autoFocus: boolean = false; // 是否自动获取焦点
  @Param historyList: HistorySearchItem[] = [];
  @Param @Require vm: SearchVM;
  SEARCH_BAR_ID = 'search_bar';
  private searchInputController: SearchController = new SearchController();
  private businessSearchController: BusinessSearchController = BusinessSearchController.instance;
  @Event updateSearchWords: (value: string) => void = () => {
  };
  @Event clickBack: () => void = () => {
  };
  @Event submitSearch: (value: string) => void = () => {
  };
  @Event onInputFocus: () => void = () => {
  }; // 输入框焦点事件
  @Event searchComponent: () => void = () => {
  };

  aboutToAppear(): void {
    // 跳搜索页焦点
    if (this.autoFocus) {
      setTimeout(() => {
        this.getUIContext().getFocusController().requestFocus(this.SEARCH_BAR_ID);
      }, 100);
    }
  }

  build() {
    Row() {
      // 返回按钮
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
        this.searchWords = ''
        this.clickBack?.();
      });

      if (this.disabled) {
        // 禁用状态显示
        Row() {
          Text(this.searchWords)
            .fontSize(14)
            .fontColor(Constants.FONT_COLOR_LEVEL2);
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
        // 搜索输入框
        Search({
          value: $$this.searchWords,
          controller: this.searchInputController,
          placeholder: this.placeholderText || '请输入搜索内容',
        })
          .layoutWeight(1)
          .backgroundColor(Constants.BACKGROUND_COLOR_GREY_2)
          .searchButton('搜索', {
            fontSize: 14,
            fontColor: $r('sys.color.font_emphasize'),
          })
          .defaultFocus(this.autoFocus)// 焦点
          .enableKeyboardOnFocus(this.autoFocus)
          .searchIcon({ size: 0 })
          .textFont({ size: $r('sys.float.Body_L'),weight: FontWeight.Regular })
          .placeholderFont({ size: $r('sys.float.Body_L'),weight: FontWeight.Regular })
          .caretStyle({width: 1.5, color: $r('sys.color.font_emphasize') })
          .fontColor($r('sys.color.font_primary'))
          .maxLength(20)
          .id(this.SEARCH_BAR_ID)
          .onVisibleAreaChange([1], (_isExpanding: boolean, currentRatio: number) => {
            if (currentRatio === 1 && this.autoFocus) {
              this.getUIContext().getFocusController().requestFocus(this.SEARCH_BAR_ID);
            }
          })
          .onChange((value) => {
            this.updateSearchWords?.(value);
            this.onInputFocus?.();
            this.businessSearchController.updateSearchCondition(value);
          })
          .onSubmit((value) => {
            this.searchWords = value || this.placeholderText || this.historyList[0].label;
            this.vm.searchWords = this.searchWords;
            this.submitSearch?.(this.searchWords);
          })
          .onClick(() => {
            // 点击输入框时出现焦点
            this.getUIContext().getFocusController().requestFocus(this.SEARCH_BAR_ID);
            this.searchComponent()
          })
      }
    }
    .padding({
      left: Constants.SPACE_L,
      right: Constants.SPACE_L,
      bottom: Constants.SPACE_S,
    })
    .backgroundColor(Constants.BACKGROUND_COLOR)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
  }
}