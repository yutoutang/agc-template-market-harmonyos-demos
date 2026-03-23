import { AlignmentInfo } from '../model/AlignmentInfo';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { PickerUtil } from '../utils/PickerUtil';
import { COLOR_LIST } from '../common/Constants';
import { ChangeRecord } from '../model/ChangeRecord';
import { display, LengthMetrics } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

@ObservedV2
export class RichEditorController {
  private static _instance: RichEditorController;

  public static get instance() {
    if (!RichEditorController._instance) {
      RichEditorController._instance = new RichEditorController();
    }
    return RichEditorController._instance;
  }

  private static readonly MAX_IMAGE_COUNT: number = 20;
  private static readonly MAX_IMAGE_SIZE_BYTES: number = 20 * 1024 * 1024;

  textInputController: TextInputController = new TextInputController();
  controller: RichEditorStyledStringController = new RichEditorStyledStringController();
  options: RichEditorStyledStringOptions = { controller: this.controller };
  // 当前文本是否加粗
  @Trace currentBold: boolean = false;
  // 当前文本是否斜体
  @Trace currentItalics: boolean = false;
  // 是否手写笔模式
  @Trace isHandwriteMode: boolean = false;
  // 当前文本是否有阴影
  @Trace currentShadow: boolean = false;
  // 当前文本装饰线
  @Trace currentDecoration: TextDecorationType = TextDecorationType.None;
  // 显示的拓展工具栏索引号 0-关闭扩展工具栏 1-显示调色盘选项栏 2-显示段落样式选项栏
  @Trace showToolBarIndex: number = 0;
  // 当前文本颜色
  @Trace currentColor: number = 0;
  // 字体大小
  @Trace fontSize: LengthMetrics = LengthMetrics.vp(18);
  // 当前段落对齐样式
  @Trace currentAlignment: number = 0;
  // 指向当前操作记录
  @Trace currentIndex: number = -1;
  // 操作记录
  @Trace historyRecordArray: Array<ChangeRecord> = [];
  // 是否展示
  @Trace showMoreFunction: boolean = true;
  // 段落对齐样式以及点击回调
  paragraphAlignments: AlignmentInfo[] = [
    {
      icon: $r('app.media.ic_alignment_left'),
      click: () => {
        this.setParagraphAlignment(TextAlign.Start);
        this.currentAlignment = 0;
        this.showToolBarIndex = 0;
      },
    },
    {
      icon: $r('app.media.ic_alignment_center'),
      click: () => {
        this.setParagraphAlignment(TextAlign.Center);
        this.currentAlignment = 1;
        this.showToolBarIndex = 0;
      },
    },
    {
      icon: $r('app.media.ic_alignment_right'),
      click: () => {
        this.setParagraphAlignment(TextAlign.End);
        this.currentAlignment = 2;
        this.showToolBarIndex = 0;
      },
    },
    {
      icon: $r('app.media.ic_alignment_justify'),
      click: () => {
        this.setParagraphAlignment(TextAlign.JUSTIFY);
        this.currentAlignment = 3;
        this.showToolBarIndex = 0;
      },
    },
  ];

  onDo() {
    if (this.currentIndex < 1) {
      return;
    }

    this.controller.setStyledString(this.historyRecordArray[--this.currentIndex].styledString);
  }

  reDo() {
    if (this.currentIndex >= this.historyRecordArray.length - 1) {
      return;
    }

    this.controller.setStyledString(this.historyRecordArray[++this.currentIndex].styledString);
  }

  /**
   * 编辑区域发生变化时调用方法
   * @param start
   * @param end
   */
  onDidChange(start: number | undefined, end: number | undefined) {
    if (start !== undefined && end !== undefined) {
      if (end - start <= 0) {
        return;
      }
      // 设置文本字体样式
      const textStyle: TextStyle = new TextStyle({
        fontWeight: this.currentBold ? FontWeight.Bold : FontWeight.Normal,
        fontStyle: this.currentItalics ? FontStyle.Italic : FontStyle.Normal,
        fontSize: this.fontSize,
        fontColor: COLOR_LIST[this.currentColor],
      });
      // 设置文本装饰线样式
      let decorationStyle = new DecorationStyle({
        type: this.currentDecoration,
      });
      // 设置文本阴影
      let textShadowStyle = this.currentShadow ?
        new TextShadowStyle({
          radius: 2,
          type: ShadowType.BLUR,
          offsetX: 3,
          offsetY: 3,
        })
        : new TextShadowStyle({ radius: 0 });

      let textAlign = TextAlign.Start;
      switch (this.currentAlignment) {
        case 0:
          textAlign = TextAlign.Start;
          break;
        case 1:
          textAlign = TextAlign.Center;
          break;
        case 2:
          textAlign = TextAlign.End;
          break;
        case 3:
          textAlign = TextAlign.JUSTIFY;
          break;
      }
      let paragraphStyle = new ParagraphStyle({
        textAlign: textAlign,
      });
      // 获取富文本组件显示的属性字符串
      const richEditorStyledString = this.controller.getStyledString();
      richEditorStyledString.setStyle({
        start: start,
        length: end - start,
        styledKey: StyledStringKey.FONT,
        styledValue: textStyle,
      });

      richEditorStyledString.setStyle({
        start: start,
        length: end - start,
        styledKey: StyledStringKey.DECORATION,
        styledValue: decorationStyle,
      });

      richEditorStyledString.setStyle({
        start: start,
        length: end - start,
        styledKey: StyledStringKey.TEXT_SHADOW,
        styledValue: textShadowStyle,
      });

      richEditorStyledString.setStyle({
        start: start,
        length: end - start,
        styledKey: StyledStringKey.TEXT_SHADOW,
        styledValue: textShadowStyle,
      });

      richEditorStyledString.setStyle({
        start: start,
        length: end - start,
        styledKey: StyledStringKey.PARAGRAPH_STYLE,
        styledValue: paragraphStyle,
      });

      // 使变更样式后的属性字符串展示在组件上
      this.controller.setStyledString(richEditorStyledString);
      this.controller.setCaretOffset(end);

      this.addHistoryRecord(richEditorStyledString);
    }
  }

  /**
   * 增加历史记录
   * @param styledString
   */
  addHistoryRecord(styledString: MutableStyledString) {
    this.currentIndex++;
    this.historyRecordArray.push(new ChangeRecord(styledString));
  }

  /**
   * 选中样式发生变化时调用方法
   * @param styledKey
   * @param styledValue
   */
  onSelectionStyleChange(styledKey: StyledStringKey, styledValue: StyledStringValue) {
    let richEditorSelection = this.controller.getSelection();
    let start = richEditorSelection.start ? richEditorSelection.start : 0;
    let end = richEditorSelection.end ? richEditorSelection.end : 0;
    if (start < 0 || end <= start) {
      return;
    }

    // 获取组件展示的属性字符串
    let richEditorStyledString: MutableStyledString = this.controller.getStyledString();
    richEditorStyledString.setStyle({
      start: start,
      length: end - start,
      styledKey: styledKey,
      styledValue: styledValue,
    });

    // 获取选中范围，用于视图渲染后重新选中
    let selectRange = this.controller.getSelection();
    // 使变更样式后的属性字符串展示在组件上
    this.controller.setStyledString(richEditorStyledString);
    this.currentIndex++;
    this.addHistoryRecord(richEditorStyledString);
    this.reSelect(selectRange.start, selectRange.end);
  }

  /**
   * 设置段落对齐样式
   * @param textAlign
   */
  setParagraphAlignment(textAlign: TextAlign) {
    let paragraphStyle = new ParagraphStyle({
      textAlign: textAlign,
    });
    const richEditorStyledString = this.controller.getStyledString();
    if (richEditorStyledString.length === 0) {
      return;
    }
    // 光标选中范围
    let selectRange: Range = { start: -1, end: -1 };
    // 段落移动范围
    let range = this.getParagraphRange(selectRange);

    richEditorStyledString.setStyle({
      start: range.start,
      length: range.end - range.start,
      styledKey: StyledStringKey.PARAGRAPH_STYLE,
      styledValue: paragraphStyle,
    });
    this.controller.setStyledString(richEditorStyledString);
    // 设置光标位置
    this.controller.setCaretOffset(selectRange.start);
    // 设置选中区域
    this.controller.setSelection(selectRange.start, selectRange.end);
    this.addHistoryRecord(richEditorStyledString);
  }

  /**
   * 获取选中范围和段落移动范围
   * @param selectRange 选中范围，为选中范围赋值
   * @returns 段落移动范围
   */
  getParagraphRange(selectRange: Range): Range {
    // 获取文本内容
    let content: string = this.controller.getStyledString().getString();
    // 获取光标所在位置
    let start = this.controller.getSelection().start;
    let end = this.controller.getSelection().end;

    if (start === undefined || end === undefined) {
      selectRange.start = 0;
      selectRange.end = content.length;
      return { start: 0, end: content.length };
    }

    // 光标所在位置
    selectRange.start = start;
    selectRange.end = end;

    // 中间独占一行
    if (start === end && content.charAt(start - 1) === '\n' && content.charAt(end) === '\n') {
      return { start: start, end: start + 1 };
    }
    // 末尾独占一行
    if (start === end && content.charAt(start - 1) === '\n' && end === content.length) {
      return { start: start - 1, end: start };
    }

    // 找到段落起始位置
    while (content.charAt(start - 1) !== '\n' && start !== 0) {
      start--;
    }
    // 找到段落结束位置
    while (content.charAt(end) !== '\n' && end < content.length) {
      end++;
    }
    return { start: start, end: end };
  }

  /**
   * 重新选中状态
   * @param start
   * @param end
   */
  reSelect(start: number | undefined, end: number | undefined) {
    if (start !== undefined && end !== undefined) {
      if (end - start <= 0) {
        return;
      }
      this.controller.setSelection(start, end);
    }
  }

  /**
   * 恢复初始状态
   */
  initState() {
    this.currentBold = false;
    this.currentItalics = false;
    this.currentShadow = false;
    this.currentDecoration = TextDecorationType.None;
    this.showToolBarIndex = 0;
    this.currentColor = 0;
    this.currentAlignment = 0;
    this.showMoreFunction = true;
  }

  /**
   * 清除所有内容
   * @param context
   */
  clearAllContent(context: UIContext) {
    context.showAlertDialog(
      {
        message: '是否确认删除所有文字?',
        autoCancel: true,
        alignment: DialogAlignment.Center,
        primaryButton: {
          value: '取消',
          action: () => {
          },
        },
        secondaryButton: {
          enabled: true,
          defaultFocus: true,
          style: DialogButtonStyle.DEFAULT,
          fontColor: Color.Red,
          value: '确认',
          action: () => {
            const richEditorStyledString = this.controller.getStyledString();
            if (richEditorStyledString.length === 0) {
              return;
            }
            richEditorStyledString.removeString(0, richEditorStyledString.length);
            this.controller.setStyledString(richEditorStyledString);
            this.initState();
          },
        },
        cancel: () => {
        },
        onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
          if (dismissDialogAction.reason === DismissReason.PRESS_BACK ||
            dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
            dismissDialogAction.dismiss();
          }
        },
      },
    );
  }

  private getImageCount(): number {
    const styledString = this.controller.getStyledString();
    const content = styledString.getString();
    if (!content || content.length === 0) {
      return 0;
    }
    const styles: Array<SpanStyle> = styledString.getStyles(0, content.length);
    let count = 0;
    for (let style of styles) {
      if (style.styledKey === StyledStringKey.IMAGE) {
        count++;
      }
    }
    return count;
  }

  /**
   * 选择图片
   */
  selectImage(uiContext: UIContext) {
    const currentImageCount = this.getImageCount();
    if (currentImageCount >= RichEditorController.MAX_IMAGE_COUNT) {
      uiContext.getPromptAction().showToast({
        message: `最多只能插入${RichEditorController.MAX_IMAGE_COUNT}张图片`,
        duration: 1500
      });
      return;
    }

    PickerUtil.selectPhoto({
      maxSelectNumber: 1,
    }).then((uris) => {
      console.info('select photo successfully, uri: ' + uris);
      if (!uris || uris.length === 0) {
        return;
      }
      let imageUri = uris[0];

      try {
        const stat = fileIo.statSync(imageUri);
        if (stat && stat.size > RichEditorController.MAX_IMAGE_SIZE_BYTES) {
          uiContext.getPromptAction().showToast({
            message: '单张图片大小不能超过20MB',
            duration: 1500
          });
          return;
        }
      } catch (err) {
        console.error('获取图片大小失败', err);
      }

      const imageCountAfterInsert = this.getImageCount() + 1;
      if (imageCountAfterInsert > RichEditorController.MAX_IMAGE_COUNT) {
        uiContext.getPromptAction().showToast({
          message: `图片数量不能超过${RichEditorController.MAX_IMAGE_COUNT}张`,
          duration: 1500
        });
        return;
      }

      // 获取图片信息
      let pixelMap: image.PixelMap = RichEditorController.loadImage(imageUri);
      let info = pixelMap.getImageInfoSync();
      let width = info.size.width;
      let height = info.size.height;

      // 宽度超过最大尺寸时，等比例缩放 占屏幕的90%
      let displayWidth = uiContext.px2vp(display.getDefaultDisplaySync().width) * 0.9;
      if (width > displayWidth) {
        width = displayWidth;
        height = width / info.size.width * height;
      }

      // 创建图片富文本对象
      let imageStyledString = new MutableStyledString(new ImageAttachment({
        value: pixelMap,
        objectFit: ImageFit.Auto,
        size: { width: width, height: height },
      }));
      // 获取当前的富文本内容
      let richEditorStyledString: MutableStyledString = this.controller.getStyledString();

      // 获取当前光标位置
      let currentOffset = this.controller.getCaretOffset();

      // 在光标位置插入图片
      richEditorStyledString.insertStyledString(currentOffset, imageStyledString);

      // 添加图片后自动向下插入一行
      richEditorStyledString.insertString(currentOffset + 1, '\n');

      // 使插入图片后的属性字符串展示在组件上
      this.controller.setStyledString(richEditorStyledString);
      this.controller.setCaretOffset(currentOffset + 2);
    });
  }

  private static loadImage(name: string): image.PixelMap {
    let imageSource: image.ImageSource;
    let fileSource = fileIo.openSync(name, fileIo.OpenMode.READ_ONLY);
    try {
      imageSource = image.createImageSource(fileSource.fd);
    } catch (err) {
      let error = err as BusinessError;
      console.error(`创建ImageSource失败 ~ code: ${error.code} -·- message: ${error.message}`);
      throw new Error(`创建ImageSource失败: ${error.message}`);
    }
    return imageSource.createPixelMapSync();
  }
}

interface Range {
  start: number;
  end: number;
}