import { UIContext } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { NodeController, BuilderNode, FrameNode } from '@kit.ArkUI';

// 定义接口
interface ViewModelInterface {
  // 声明公共方法或属性

}

class MyViewModel implements ViewModelInterface {
}

class Data {
  url: Resource = $rawfile('huge.html');
  controller: WebviewController = new webview.WebviewController();
  vm: ViewModelInterface = new MyViewModel(); // 具体实现类
  webID?: string = 'WebPage';
  onPageEnd?: Function = () => {
  }
}

let shouldInactive: boolean = true;

@Builder
function webBuilder(data: Data) {
  Column() {
    Web({ src: data.url, controller: data.controller })
      .geolocationAccess(false)
      .domStorageAccess(true)
      .fileAccess(false)
      .zoomAccess(true)
      .fileAccess(true)
      .mixedMode(MixedMode.None)
      .verticalScrollBarAccess(false)
      .width('100%')
      .height('100%')
      .onPageBegin(() => {
        data.controller.onActive();
      })

      .onPageEnd(async () => {
        const SCRIPT = '[document.documentElement.scrollWidth, document.documentElement.scrollHeight]';
        try {
          data.controller.runJavaScriptExt(SCRIPT).then((result) => {
            if (result.getType() === webview.JsMessageType.ARRAY) {
              const h5Width = (result.getArray() as number[])[0];
              const h5Height = (result.getArray() as number[])[1];
              data.onPageEnd?.(h5Width, h5Height)
            }
          })
        } catch (error) {

        }

      })
      .onControllerAttached(() => {
        data.controller?.registerJavaScriptProxy(data.vm, 'appCall', ['initWebData'])
      })
      .onFirstMeaningfulPaint(() => {
        if (!shouldInactive) {
          return;
        }
        data.controller.onInactive();
        shouldInactive = false;
      })
  }
}


export class MyNodeController extends NodeController {
  private rootNode: BuilderNode<Data[]> | null = null;
  private root: FrameNode | null = null;

  makeNode(uiContext: UIContext): FrameNode | null {
    if (this.rootNode != null) {
      const parent: FrameNode = this.rootNode.getFrameNode()?.getParent() as FrameNode;
      if (parent) {
        parent.removeChild(this.rootNode.getFrameNode());
        this.root = null;
      }
      this.root = new FrameNode(uiContext);
      this.root.appendChild(this.rootNode.getFrameNode());
      return this.root;
    }
    return null;
  }

  initWeb<T extends ViewModelInterface>(url: string, uiContext: UIContext, control: WebviewController, type: string,
    vm: T, webID?: string, onPageEnd?: Function): void {
    if (this.rootNode != null) {
      return;
    }

    this.rootNode = new BuilderNode(uiContext)
    let urlHtml: Resource | string = ''
    if (type === '1') {
      urlHtml = $rawfile('simple.html')
    } else if (type === '2') {
      urlHtml = $rawfile('huge.html')
    } else if (type === '3') {
      urlHtml = $rawfile('export.html')
    }

    this.rootNode.build(wrapBuilder<Data[]>(webBuilder), {
      url: urlHtml,
      controller: control,
      vm,
      webID,
      onPageEnd
    })
  }
}

let nodeMap: Map<string, MyNodeController | undefined> = new Map();
let controllerMap: Map<string, WebviewController | undefined> = new Map();

export const createNWeb =
  <T extends ViewModelInterface>(url: string, uiContext: UIContext, type: string, vm: T, controller: WebviewController,
    webID?: string, onPageEnd?: Function) => {
    let baseNode: MyNodeController = new MyNodeController();
    baseNode.initWeb(url, uiContext, controller, type, vm, webID, onPageEnd);
    controllerMap.set(url, controller)
    nodeMap.set(url, baseNode);
  }

export const getNWeb = (url: string): MyNodeController | undefined => {
  return nodeMap.get(url);
}