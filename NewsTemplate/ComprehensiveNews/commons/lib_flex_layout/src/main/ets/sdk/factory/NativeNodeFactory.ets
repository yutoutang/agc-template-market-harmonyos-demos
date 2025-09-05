import { BuilderNode, FrameNode, NodeController } from '@kit.ArkUI';
import { NodeBuilderConfig } from 'lib_native_components';
import { LayoutParams } from 'lib_news_api';
import { NodeParams } from '../model/Model';

export const nodeMap: Map<string, NodeControllerFactory | undefined> = new Map();

export class NodeControllerFactory extends NodeController {
  private rootNode: FrameNode | null = null;
  private nativeNode: BuilderNode<[LayoutParams]> | null = null;
  private isRemove: boolean = false;
  private uiContext ?: UIContext;

  makeNode(): FrameNode | null {
    if (this.isRemove) {
      return null;
    }
    if (this.rootNode != null) {
      return this.rootNode;
    }
    return null;
  }

  disposeFrameNode() {
    if (this.rootNode !== null && this.nativeNode !== null) {
      this.nativeNode.dispose()
      this.rootNode.dispose();
    }
  }

  initData(uiContext: UIContext, nodeParams: NodeParams) {
    this.uiContext = uiContext;
    this.rootNode = new FrameNode(this.uiContext);
    let buildNode = NodeBuilderConfig.instance.getBuilderNode(nodeParams.type)
    this.nativeNode = new BuilderNode(this.uiContext);
    this.nativeNode.build(buildNode, {
      nativeCardData: nodeParams.nativeCardData,
      currentIndex: nodeParams.scrollIndex,
      layout: nodeParams.layout,
      extraInfo: nodeParams.extraInfo,
    });
    this.rootNode.getRenderNode()?.appendChild(this.nativeNode.getFrameNode()?.getRenderNode());
  }
}

export const getNativeNodeController =
  (uiContext: UIContext, nodeParams: NodeParams,baseNode:NodeControllerFactory): NodeControllerFactory | undefined => {
    nodeMap.set(nodeParams.type, baseNode);
    baseNode.initData(uiContext, nodeParams);
    return nodeMap.get(nodeParams.type);
  }
