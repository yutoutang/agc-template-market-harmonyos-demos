import { RecipeBriefInfo } from '../types/Index'

@ComponentV2
export struct RecommendedCard {
  @Param recipe: RecipeBriefInfo = new RecipeBriefInfo()
  @Param isToDelete: boolean = false
  @Param canDelete: boolean = false
  @Event jumpBloggerInfo: () => void = () => {
  }
  @Event changeDeleteState: (isToDelete: boolean) => void = () => {
  }
  @Event onClickCb: (id: number) => void = () => {
  }
  @Event changeSelect: (id: number, flag: boolean) => void = () => {
  }

  build() {
    Column() {
      Stack() {
        Image($r(`app.media.${this.recipe.thumbnail}`))
          .width('100%')
          .constraintSize({ maxWidth: 160 })
          .objectFit(ImageFit.Cover)
          .height(160)
          .borderRadius(8)
          .draggable(false)
        if (this.canDelete && this.isToDelete) {
          Row() {
            Checkbox()
              .width(20)
              .height(20)
              .selectedColor('#E84026')
              .unselectedColor('#33FFFFFF')
              .onChange((res: boolean) => {
                this.changeSelect(this.recipe.id, res)
              });
          }.width('100%').justifyContent(FlexAlign.End).padding({ bottom: 8, right: 8 });
        }
      }
      .borderRadius(8)
      .width('100%')
      .constraintSize({ maxWidth: 160 })
      .height(160)
      .clip(true)
      .align(Alignment.Bottom);

      Text(this.recipe.title)
        .width('100%')
        .constraintSize({ maxWidth: 160 })
        .margin({ top: 8, bottom: 4 })
        .fontColor($r('sys.color.font_primary'))
        .fontSize(14);
      Row() {
        Row({ space: 4 }) {
          Image($r(`app.media.${this.recipe.authorAvatar}`)).width(20).height(20).borderRadius(10);
          Text(this.recipe.author).fontSize(12).fontColor($r('sys.color.font_secondary'));
        }.onClick(() => {
          this.jumpBloggerInfo()
        })

        Row({ space: 5 }) {
          Image($r('app.media.ic_public_star_plain'))
            .fillColor($r('sys.color.font_secondary'))
            .width(15)
            .height(14);
          Text(this.formatCollection(this.recipe.likes))
            .fontSize(12)
            .fontColor($r('sys.color.font_secondary'));
        };
      }.width('100%').constraintSize({ maxWidth: 160 }).justifyContent(FlexAlign.SpaceBetween);
    }.width('100%').gesture(GestureGroup(GestureMode.Exclusive,
      LongPressGesture({ repeat: true })
        .onAction(() => {
          this.changeDeleteState(true);
        }),
      TapGesture({ count: 1, fingers: 1 })
        .onAction(() => {
          this.onClickCb(this.recipe.id)
        }),
    ),
    );
  }

  formatCollection(count: number): string {
    if (count > 1000) {
      return (count / 1000).toFixed(1) + 'K'
    }
    return count.toString()
  }
}
