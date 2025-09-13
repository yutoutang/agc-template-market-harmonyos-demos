import { CommonModifier } from '@ohos.arkui.modifier';
import { transformLayout } from './Utils';

export class ComponentModifier extends CommonModifier {
  private style: Record<string, string | number> = {}
  constructor(style: Record<string, string | number >) {
    super();
    this.style = style
  }

  applyNormalAttribute(instance: CommonAttribute): void {
    super.applyNormalAttribute?.(instance);

    instance.borderRadius(transformLayout(this.style)?.borderRadius)
    instance.backgroundColor($r(`app.sys.${this.style?.backgroundColor}`))
    instance.padding({
      left:transformLayout(this.style)?.paddingLeft,
      top:transformLayout(this.style)?.paddingTop,
      bottom:transformLayout(this.style)?.paddingBottom,
      right:transformLayout(this.style)?.paddingRight,
    })
    instance.margin({
      top:transformLayout(this.style)?.marginTop,
    })
    if (this.style?.width) {
      instance.width(this.style.width)
    }
    if (this.style?.height) {
      instance.height(this.style.height)
    }
  }
}