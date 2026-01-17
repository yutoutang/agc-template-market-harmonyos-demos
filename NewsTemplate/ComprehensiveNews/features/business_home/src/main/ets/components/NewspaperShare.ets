import { CircleButtonModifier } from 'lib_common';
import { Share } from 'lib_widget';
import { NewsShareData, NewsSource } from 'module_digital_newspaper';

@ComponentV2
export struct NewspaperShare {
  @Require @Param newspaper: NewsShareData;
  @Param newsSource: NewsSource = new NewsSource();
  @Local buttonModifier: CircleButtonModifier = new CircleButtonModifier();

  build() {
    Column() {
      Share({
        shareData: {
          recordId: this.newspaper.data.id.toString() ?? 'news_id',
          title: this.newspaper.data.newsName,
          subTitle: this.newsSource.name,
          createTime: new Date(this.newspaper.data.paperTime).getTime(),
          coverUrl: this.newspaper.data.newsImg,
          landingPageUrl: this.newspaper.data.newsImg,
        },
        shareRenderBuilder: () => {
          this.shareCommentBuilder()
        },
      })
    }
  }

  @Builder
  shareCommentBuilder() {
    Button() {
      SymbolGlyph($r('sys.symbol.share'))
        .fontSize(24)
        .fontColor([$r('sys.color.font_on_primary')])
    }
    .attributeModifier(this.buttonModifier)
  }
}