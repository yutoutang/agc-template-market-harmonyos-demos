import { CircleShape } from '@kit.ArkUI';

@ComponentV2
export struct CustomBadge {
  @Param isNewMessage: boolean = false;
  @Param maxCount: number = 99;
  @Param badgeH: number = 12;
  @BuilderParam bodyBuilder: () => void;

  build() {
    RelativeContainer() {
      Row() {
        this.bodyBuilder()
      }
      .id('body_id')

      Row() {
        this.circleBadge()
      }
      .alignRules({
        right: { anchor: 'body_id', align: HorizontalAlign.End },
        top: { anchor: 'body_id', align: VerticalAlign.Top }
      })
      .visibility(this.isNewMessage ? Visibility.None : Visibility.Visible)
    }
    .width('auto')
    .height('auto')
  }

  @Builder
  circleBadge() {
    Text('')
      .width(this.badgeH)
      .height(this.badgeH)
      .clipShape(new CircleShape({ width: this.badgeH, height: this.badgeH }))
      .fontSize($r('sys.float.Caption_M'))
      .fontColor($r('sys.color.font_on_primary'))
      .backgroundColor($r('sys.color.warning'))
      .textAlign(TextAlign.Center)
  }
}