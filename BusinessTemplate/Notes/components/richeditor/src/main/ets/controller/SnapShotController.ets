import { componentSnapshot } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { CommonUtils } from '../utils/CommonUtils';
import { ImageUtils } from '../utils/ImageUtils';
import { PopupUtils } from '../utils/PopupUtils';


@ObservedV2
export class SnapShotController {
  @Trace showScrollBar: BarState = BarState.On;
  @Trace componentMaskImage: PixelMap | undefined = undefined;
  @Trace snapPopupPosition: Position | undefined = { x: 0, y: 0 };
  @Trace mergedImage: PixelMap | undefined = undefined;
  @Trace isShowPreview: boolean = false;
  @Trace isLargePreview: boolean = false;
  yOffsetBefore: number = 0;
  @Trace curYOffset: number = 0;
  scroller: Scroller;
  screenWidth: number = AppStorage.get('screenWidth') || 0;
  screenHeight: number = AppStorage.get('screenHeight') || 0;
  scrollYOffsets: number[] = [];
  listComponentWidth: number = 0;
  listComponentHeight: number = 0;
  areaArray: image.PositionArea[] = [];
  scrollHeight: number = 0;
  snapShotId: string;
  uiContext: UIContext;

  constructor(snapShotId: string, scroller: Scroller, uiContext: UIContext) {
    this.snapShotId = snapShotId;
    this.scroller = scroller;
    this.uiContext = uiContext;
  }

  onceSnapshot = async () => {
    try {
      this.showScrollBar = BarState.Off;
      await this.beforeSnapshot();
      await this.snapAndMerge();
      await this.afterSnapshot();
      this.afterGeneratorImage();
    } catch (error) {
      console.error('截图失败, error:', error);
      // 恢复UI状态
      this.componentMaskImage = undefined;
      this.scrollYOffsets.length = 0;
      this.areaArray.length = 0;
      this.showScrollBar = BarState.On;
      this.isShowPreview = false;
      // 可以在这里添加错误提示
      // PromptUtils.showToast('截图失败，请重试');
    }
  };

  async beforeSnapshot() {
    try {
      this.yOffsetBefore = this.curYOffset;
      // Take a screenshot of the loaded List component as a cover image for the List component
      this.componentMaskImage = await componentSnapshot.get(this.snapShotId);
      if (!this.componentMaskImage) {
        throw new Error('获取组件截图失败');
      }

      this.scroller.scrollTo({
        xOffset: 0,
        yOffset: 0,
        animation: {
          duration: 200,
        },
      });
      this.snapPopupPosition = PopupUtils.calcPopupCenter(this.screenWidth, this.screenHeight, 100, 200);
      this.isShowPreview = true;
      // Delay ensures that the scroll has reached the top
      await CommonUtils.sleep(200);
    } catch (error) {
      console.error('截图前置处理失败, error:', error);
      throw new Error(`截图前置处理失败: ${error.message}`);
    }
  }

  async snapAndMerge() {
    try {
      this.scrollYOffsets.push(this.curYOffset);
      // Call the component screenshot interface to obtain the current screenshot
      const pixelMap = await componentSnapshot.get(this.snapShotId);
      if (!pixelMap) {
        throw new Error('获取组件截图失败');
      }

      // Gets the number of bytes per line of image pixels.
      let area: image.PositionArea =
        await ImageUtils.getSnapshotArea(this.uiContext, pixelMap, this.scrollYOffsets, this.listComponentWidth,
          this.listComponentHeight);
      this.areaArray.push(area);

      // Determine whether the bottom has been reached during the loop process
      if (!this.scroller.isAtEnd()) {
        CommonUtils.scrollAnimation(this.scroller, 200, this.scrollHeight);
        await CommonUtils.sleep(200);
        await this.snapAndMerge();
      } else {
        this.mergedImage =
          await ImageUtils.mergeImage(this.uiContext, this.areaArray,
            this.scrollYOffsets[this.scrollYOffsets.length - 1],
            this.listComponentWidth, this.listComponentHeight);
      }
    } catch (error) {
      console.error('截图合并处理失败, error:', error);
      throw new Error(`截图合并处理失败: ${error.message}`);
    }
  }

  async afterSnapshot() {
    try {
      this.scroller.scrollTo({
        xOffset: 0,
        yOffset: this.yOffsetBefore,
        animation: {
          duration: 200,
        },
      });
      await CommonUtils.sleep(200);
    } catch (error) {
      console.error('截图后置处理失败, error:', error);
      throw new Error(`截图后置处理失败: ${error.message}`);
    }
  }

  async afterGeneratorImage() {
    try {
      // Delay for transition animation
      await CommonUtils.sleep(200);
      this.snapPopupPosition = PopupUtils.calcPopupBottomLeft(this.screenHeight, 200);
      this.componentMaskImage = undefined;
      this.scrollYOffsets.length = 0;
      this.areaArray.length = 0;
      this.showScrollBar = BarState.On;
    } catch (error) {
      console.error('截图后生成图片处理失败, error:', error);
      // 这里不需要再抛出，因为这是最后的清理步骤
      this.componentMaskImage = undefined;
      this.scrollYOffsets.length = 0;
      this.areaArray.length = 0;
      this.showScrollBar = BarState.On;
    }
  }

  // 添加一个重置方法，用于错误恢复
  reset(): void {
    try {
      this.componentMaskImage = undefined;
      this.mergedImage = undefined;
      this.isShowPreview = false;
      this.isLargePreview = false;
      this.scrollYOffsets.length = 0;
      this.areaArray.length = 0;
      this.showScrollBar = BarState.On;
      this.snapPopupPosition = { x: 0, y: 0 };
    } catch (error) {
      console.error('重置控制器失败, error:', error);
    }
  }

  // 添加一个安全执行截图的方法，支持自定义错误处理
  async safeSnapshot(onError?: (error: Error) => void): Promise<boolean> {
    try {
      await this.onceSnapshot();
      return true;
    } catch (error) {
      console.error('安全执行截图失败, error:', error);
      onError?.(error as Error);
      this.reset();
      return false;
    }
  }
}