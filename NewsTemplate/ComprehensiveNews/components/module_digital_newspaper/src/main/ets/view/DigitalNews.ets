import { LengthMetrics } from '@kit.ArkUI';
import { DateSelect } from '../components/DateSelect'
import { NewsSwiper } from '../components/NewsSwiper'
import { LayoutView } from '../components/LayoutView';
import { DirectoryView } from '../components/DirectoryView';
import { NewsSourceView } from '../components/NewsSourceView';
import { NewsArea } from '../model/NewsArea';
import { NewsSource } from '../model/NewsSource';
import { NewsShareData, NewsPage, NewsPageWithAreaInfo } from '../model/NewspaperPage';
import { Constant } from '../common/Constant';
import { CircleButtonModifier } from '../common/CircleButtonModifier';
import { AreaModel } from '../common/AreaModel';

@ComponentV2
export struct DigitalNews {
  // 报纸版面列表
  @Param newspaperPages: NewsPage[] = [];
  // 报纸来源列表
  @Param newsSourceList: NewsSource[] = [];
  // 主题色
  @Param themeColor: ResourceColor = $r('sys.color.brand');
  // 所选择的日期
  @Param selectDate: Date = new Date();
  // 所选择的报纸来源
  @Param selectNewsSource: NewsSource = new NewsSource();
  // 日期变化回调
  @Event onDateChange: (date: Date) => void = () => {
  };
  // 新闻来源变化回调
  @Event onNewsSourceChange: (source: NewsSource) => void = () => {
  };
  // 版面数字变化回调
  @Event onLayoutPageChange: (pageNum: number) => void = () => {
  };
  // 新闻区域点击回调
  @Event onAreaClick: (area: NewsArea) => void = () => {
  };
  // 关闭回调
  @Event onClose: () => void = () => {
  };
  // 自定义分享区域
  @BuilderParam shareBuilder?: ($$: NewsShareData) => void;
  @Provider() containerSize: AreaModel = new AreaModel();
  @Local newsPaperList: NewsPageWithAreaInfo[] = [];
  @Local swiperController: SwiperController = new SwiperController();
  @Local currentPage: number = 0;
  @Local shareData: NewsShareData = new NewsShareData();
  @Local btnModifier: CircleButtonModifier = new CircleButtonModifier();
  @Local isDirectionRow: boolean = false;
  private readonly BAR_HEIGHT: number = 2 * Constant.BOTTOM_LAYOUT_HEIGHT;
  private readonly TIP_HEIGHT: number = 32;

  aboutToAppear(): void {
    this.setSource();
    this.onListChange();
  }

  @Monitor('newspaperPages')
  onListChange() {
    this.newsPaperList = this.newspaperPages.map(v => new NewsPageWithAreaInfo(v));
    this.currentPage = 0;
    if (this.newspaperPages[this.currentPage]) {
      this.shareData.data = this.newspaperPages[this.currentPage];
    }
  }

  @Monitor('currentPage')
  onCurrentPageChange() {
    this.shareData.data = this.newspaperPages[this.currentPage];
  }

  setSource() {
    if (!this.selectNewsSource.id && this.newsSourceList.length) {
      this.selectNewsSource.id = this.newsSourceList[0].id;
      this.selectNewsSource.name = this.newsSourceList[0].name;
    }
  }

  onMainAreaChange(area: Area) {
    this.containerSize.bottomHeight = this.BAR_HEIGHT;
    this.containerSize.width = area.width as number;
    this.containerSize.height = area.height as number - this.containerSize.bottomHeight;
    const containerRatio = this.containerSize.width / this.containerSize.height;
    this.isDirectionRow = containerRatio >= Constant.WIDE_SCREEN_RATIO
    if (!this.isDirectionRow) {
      this.containerSize.bottomHeight = this.BAR_HEIGHT + this.TIP_HEIGHT;
      this.containerSize.height = area.height as number - this.containerSize.bottomHeight;
    }
  }

  @Computed
  get swiperTipRule() {
    if (this.isDirectionRow) {
      return {
        center: { anchor: Constant.SWIPER_ID, align: VerticalAlign.Center },
        left: { anchor: Constant.SWIPER_ID, align: HorizontalAlign.End },
      } as AlignRuleOption;
    }
    return {
      top: { anchor: Constant.SWIPER_ID, align: VerticalAlign.Bottom },
      middle: { anchor: Constant.SWIPER_ID, align: HorizontalAlign.Center },
    } as AlignRuleOption;
  }

  build() {
    Column() {
      this.topToolBuilder()
      this.mainBuilder()
      this.bottomToolBuilder()
    }
    .width(Constant.FULL_PERCENT)
    .layoutWeight(1)
  }

  @Builder
  topToolBuilder() {
    Row({ space: Constant.PADDING_S }) {
      DateSelect({
        selectedDate: this.selectDate,
        themeColor: this.themeColor,
        onDateSelected: (date: Date) => {
          this.onDateChange(date);
        },
      })
      Blank()
      if (this.shareBuilder) {
        this.shareBuilder(this.shareData)
      }
      Button() {
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize(24)
          .fontColor([$r('sys.color.font_on_primary')])
      }
      .attributeModifier(this.btnModifier)
      .onClick(() => {
        this.onClose();
      })
    }
    .width(Constant.FULL_PERCENT)
    .padding({
      top: Constant.PADDING_S,
      bottom: Constant.PADDING_S,
    })
  }

  @Builder
  mainBuilder() {
    Column() {
      RelativeContainer() {
        Column() {
          NewsSwiper({
            controller: this.swiperController,
            currentPage: this.currentPage!!,
            newspaperPages: this.newsPaperList,
            jumpNewsDetail: (area) => {
              this.onAreaClick(area);
            },
          })
        }
        .id(Constant.SWIPER_ID)
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
        })

        Row({ space: Constant.PADDING_S }) {
          Flex({
            direction: this.isDirectionRow ? FlexDirection.Column : FlexDirection.Row,
            alignItems: ItemAlign.Center,
            justifyContent: FlexAlign.Center,
            space: { main: new LengthMetrics(Constant.PADDING_S) },
          }) {
            Text('滑动查看下一版')
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_on_primary'))

            SymbolGlyph($r('sys.symbol.arrow_down'))
              .fontSize($r('sys.float.Body_L'))
              .fontColor([$r('sys.color.font_on_primary')])
          }
          .width(this.isDirectionRow ? 16 : Constant.DEFAULT_AUTO)
          .margin({
            left: this.isDirectionRow ? Constant.PADDING_TIP : 0,
            top: this.isDirectionRow ? 0 : Constant.PADDING_S,
            bottom: this.isDirectionRow ? 0 : Constant.PADDING_S,
          })
        }
        .id(Constant.SWIPER_TIP_ID)
        .alignRules(this.swiperTipRule)
      }
      .visibility(this.newspaperPages.length > 0 ? Visibility.Visible : Visibility.Hidden)
    }
    .layoutWeight(1)
    .padding({
      top: Constant.PADDING_S,
      bottom: Constant.PADDING_S,
    })
    .onAreaChange((_o, n) => {
      this.onMainAreaChange(n);
    })
  }

  @Builder
  bottomToolBuilder() {
    Row() {
      LayoutView({
        totalCount: this.newsPaperList.length,
        curIndex: this.currentPage,
        themeColor: this.themeColor,
        onItemClick: (index: number) => {
          this.currentPage = index;
          this.swiperController.changeIndex(index, true);
          this.onLayoutPageChange(index);
        },
      })

      DirectoryView({
        content: this.newsPaperList,
        curIndex: this.currentPage,
        text: '目录',
        contentIcon: $r('sys.symbol.doc_plaintext'),
        themeColor: this.themeColor,
        onItemClick: (area: NewsArea) => {
          this.onAreaClick(area);
        },
        onPageChange: (index: number) => {
          this.currentPage = index;
        },
      })

      NewsSourceView({
        list: this.newsSourceList,
        curNewsSource: this.selectNewsSource,
        text: '报纸',
        newsIcon: $r('sys.symbol.doc_text'),
        themeColor: this.themeColor,
        onItemClick: (item: NewsSource) => {
          this.onNewsSourceChange(item);
        },
      })
    }
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceAround)
    .padding({
      bottom: Constant.PADDING_S,
    })
  }
}