import { BuilderNode, NodeController } from '@kit.ArkUI';

class Params {
  text: string = '';

  constructor(text: string) {
    this.text = text;
  }
}

// 开发者可以通过@Builder装饰器实现布局构建
@Builder
function buildText(params: Params) {
  Column() {
    Text(params.text)
      .fontSize(20)
      .fontColor($r('sys.color.font_on_primary'))
      .textAlign(TextAlign.Center)
  }
  .width('100%') // 宽度方向充满画中画窗口
  .height('100%') // 高度方向充满画中画窗口
  .justifyContent(FlexAlign.Center)
  .backgroundColor(params.text === '' ? Color.Transparent : Color.Black)
}

// 开发者可通过继承NodeController实现自定义UI控制器
export class TextNodeController extends NodeController {
  private message: string;
  private textNode: BuilderNode<[Params]> | null = null;

  constructor(message: string) {
    super();
    this.message = message;
  }

  // 通过BuilderNode加载自定义布局
  makeNode(context: UIContext): FrameNode | null {
    this.textNode = new BuilderNode(context);
    this.textNode.build(wrapBuilder<[Params]>(buildText), new Params(this.message));
    return this.textNode.getFrameNode();
  }

  // 开发者可自定义该方法实现布局更新
  update(message: string) {
    console.log(`update message: ${message}`);
    if (this.textNode !== null) {
      this.textNode.update(new Params(message));
    }
  }
}