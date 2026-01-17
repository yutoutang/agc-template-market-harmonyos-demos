import { DigitalNews, NewsShareData } from 'module_digital_newspaper';
import { NewspaperShare } from '../components/NewspaperShare';
import { ENewsViewModel } from '../viewmodels/ENewsViewModel';

@Builder
export function ENewsPageBuilder() {
  ENewsPage()
}

@ComponentV2
struct ENewsPage {
  @Local vm: ENewsViewModel = new ENewsViewModel();

  async aboutToAppear(): Promise<void> {
    this.vm.queryRouteParams();
    await this.vm.queryNewsSourceList();
    this.vm.queryNewspaperPages();
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          DigitalNews({
            newspaperPages: this.vm.newspaperPages,
            newsSourceList: this.vm.newsSourceList,
            selectNewsSource: this.vm.selectNewsSource,
            selectDate: this.vm.selectDate,
            themeColor: $r('app.color.app_theme'),
            shareBuilder: (data: NewsShareData) => {
              this.shareBuilder(data);
            },
            onDateChange: (date) => {
              this.vm.onDateChange(date);
            },
            onNewsSourceChange: (source) => {
              this.vm.onNewsSourceChange(source);
            },
            onAreaClick: (area) => {
              this.vm.jumpNewsDetail(area);
            },
            onClose: () => {
              this.vm.getNavStack().pop();
            },
          })
        }
        .padding({
          left: this.vm.breakPointModel.pagePadding,
          right: this.vm.breakPointModel.pagePadding,
          top: this.vm.windowModel.windowTopPadding,
          bottom: this.vm.windowModel.windowBottomPadding,
        })
      }
      .layoutWeight(1)
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.e_news_page_bg'))
  }

  @Builder
  shareBuilder(data: NewsShareData) {
    NewspaperShare({
      newspaper: data,
      newsSource: this.vm.selectNewsSource,
    })
  }
}