import { COLOR_LIST, HIGHLIGHT_COLOR_FILTER, ORIGIN_COLOR_FILTER, RICH_ID } from '../common/Constants';
import { AlignmentInfo } from '../model/AlignmentInfo';
import { RichEditorController } from '../controller/RichEditorController';
import { SnapShotController } from '../controller/SnapShotController';
import { SnapshotPreview } from './SnapshotPreview';
import { LengthMetrics } from '@kit.ArkUI';
import { HandwriteController, HandwriteComponent, PenHspInfo, PenType } from '@kit.Penkit';
import common from '@ohos.app.ability.common';

@ComponentV2
export struct RichEditorArea {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  private richEditorController: RichEditorController = RichEditorController.instance;
  @Param snapShotController: SnapShotController = new SnapShotController('', new Scroller(), this.getUIContext());
  @Local richEditorLayoutWeight: number = 0;
  @Param @Once @Require noteTitle: string;
  @Param @Once @Require noteContent: MutableStyledString;
  @Param @Once @Require noteId: string;
  @Event titleChange: (title: string) => void = () => {
  };

  @Local isEditing: boolean = false;
  private readonly MAX_TEXT_LENGTH: number = 20000;

  // 手写相关状态
  @Local isHandwriteMode: boolean = false;
  @Local penWidth: number = 5;
  @Local penColor: ResourceColor = Color.Black;
  ballpointPenWidth: number = 6;

  /** 由外部传入时与编辑页共用同一控制器，便于保存笔记时一并保存画布 */
  @Param handwriteController: HandwriteController = new HandwriteController();
  private handwritePath: string = '';
  private uiContext: UIContext = this.getUIContext() as UIContext;
  private hostContext: common.Context = this.uiContext.getHostContext() as Context;
  @Local private isHandwriteDirty: boolean = false;

  aboutToAppear(): void {
    this.handwritePath = this.hostContext.filesDir + '/' + `handwrite_${this.noteId}`;
  }

  // 保存手写内容
  private async saveHandwriteData(): Promise<void> {
    if (!this.handwriteController) {
      return;
    }
    try {
      await this.handwriteController.save(this.handwritePath);
      console.info(`手写内容已保存到: ${this.handwritePath}`);
      this.setHandwriteDirty(false);
    } catch (error) {
      console.error('保存手写内容失败:', error);
    }
  }

  // 加载手写内容（手写数据文件）
  private async loadHandwriteData(): Promise<void> {
    if (!this.handwriteController) {
      return;
    }
    try {
      if (this.handwritePath) {
        await this.handwriteController.load(this.handwritePath);
        console.info(`手写内容已从 ${this.handwritePath} 加载`);
      }
      this.setHandwriteDirty(false);
    } catch (error) {
      console.info('无手写历史记录或文件不存在，将创建新手写数据');
      this.setHandwriteDirty(false);
    }
  }

  private setHandwriteDirty(dirty: boolean): void {
    if (this.isHandwriteDirty === dirty) {
      return;
    }
    this.isHandwriteDirty = dirty;
    AppStorage.setOrCreate('handwrite_dirty_note_id', this.noteId);
    AppStorage.setOrCreate('handwrite_dirty', dirty);
  }

  // 调色盘选项栏
  @Builder
  colorPalette() {
    Column(){
      Row() {
        Text('A')
          .fontSize(10)
          .fontColor($r('sys.color.font_secondary'));
        Blank();
        Row() {
          Slider({
            value: this.richEditorController.fontSize.value,
            min: 14, //滑动最小值
            max: 30, //滑动最大值
            step: 4, //步长
            style: SliderStyle.InSet,
          })
            .trackThickness(20)
            // 刻度颜色
            .stepColor($r('sys.color.comp_background_secondary'))
            // 滑轨背景色
            .trackColor($r('sys.color.comp_background_secondary'))
            // 以滑动部分颜色
            .selectedColor($r('sys.color.comp_background_emphasize'))
            // 显示步长刻度
            .showSteps(true)
            .blockStyle({ type: SliderBlockType.IMAGE, image: $r('app.media.font_setting') })
            .blockSize({ width: 12, height: 12 })
            .onChange((value: number, mode: SliderChangeMode) => {
              this.richEditorController.fontSize = LengthMetrics.vp(value);
              this.richEditorController.onSelectionStyleChange(StyledStringKey.FONT, new TextStyle({
                fontWeight: this.richEditorController.currentBold ? FontWeight.Bold : FontWeight.Normal,
                fontStyle: this.richEditorController.currentItalics ? FontStyle.Italic : FontStyle.Normal,
                fontColor: COLOR_LIST[this.richEditorController.currentColor],
                fontSize: this.richEditorController.fontSize
              }));
            })
        }
        .width('90%')

        Blank();

        Text('A')
          .fontSize(16)
          .fontColor($r('sys.color.font_secondary'));
      }
      .width('100%')
      .height(50)
      .padding({
        left: '4%',
        right: '4%'
      })

      Flex({
        justifyContent: FlexAlign.SpaceAround,
        alignItems: ItemAlign.Center,
      }) {
        ForEach(COLOR_LIST, (color: ResourceColor, index: number) => {
          Stack() {
            Circle({ width: 16, height: 16 })
              .fill(color);

            Circle({ width: 24, height: 24 })
              .fillOpacity(0)
              .borderWidth(2)
              .borderRadius(12)
              .borderColor(this.richEditorController.currentColor === index ? Color.Red : Color.Black);
          }
          .onClick(() => {
            this.richEditorController.showToolBarIndex = 0;
            this.richEditorController.currentColor = index;
            this.richEditorController.onSelectionStyleChange(StyledStringKey.FONT, new TextStyle({
              fontWeight: this.richEditorController.currentBold ? FontWeight.Bold : FontWeight.Normal,
              fontStyle: this.richEditorController.currentItalics ? FontStyle.Italic : FontStyle.Normal,
              fontColor: COLOR_LIST[this.richEditorController.currentColor],
              fontSize: this.richEditorController.fontSize
            }));
          });
        }, (color: ResourceColor) => JSON.stringify(color));
      }
      .width('100%')
      .height(50);
    }
    .width('100%')
    .height(100);
  }

  // 编辑工具栏
  @Builder
  toolBar() {
    Flex({
      justifyContent: FlexAlign.SpaceAround,
      alignItems: ItemAlign.Center,
    }) {
      Image($r('app.media.font_color_size'))
        .width(24)
        .fillColor(COLOR_LIST[this.richEditorController.currentColor])
        .onClick(() => {
          if (this.richEditorController.showToolBarIndex !== 1) {
            this.richEditorController.showToolBarIndex = 1;
          } else {
            this.richEditorController.showToolBarIndex = 0;
          }
        });

      Image(this.richEditorController.paragraphAlignments[this.richEditorController.currentAlignment].icon)
        .width(24)
        .onClick(() => {
          if (this.richEditorController.showToolBarIndex !== 2) {
            this.richEditorController.showToolBarIndex = 2;
          } else {
            this.richEditorController.showToolBarIndex = 0;
          }
        });

      Image($r('app.media.ic_bold'))
        .width(24)
        .colorFilter(this.richEditorController.currentBold ? HIGHLIGHT_COLOR_FILTER : ORIGIN_COLOR_FILTER)
        .onClick(() => {
          this.richEditorController.currentBold = !this.richEditorController.currentBold;
          this.richEditorController.onSelectionStyleChange(StyledStringKey.FONT, new TextStyle({
            fontWeight: this.richEditorController.currentBold ? FontWeight.Bold : FontWeight.Normal,
            fontStyle: this.richEditorController.currentItalics ? FontStyle.Italic : FontStyle.Normal,
            fontColor: COLOR_LIST[this.richEditorController.currentColor],
            fontSize: this.richEditorController.fontSize
          }));
        });

      Image($r('app.media.ic_notepad_texttilt'))
        .width(24)
        .colorFilter(this.richEditorController.currentItalics ? HIGHLIGHT_COLOR_FILTER : ORIGIN_COLOR_FILTER)
        .onClick(() => {
          this.richEditorController.currentItalics = !this.richEditorController.currentItalics;
          this.richEditorController.onSelectionStyleChange(StyledStringKey.FONT, new TextStyle({
            fontWeight: this.richEditorController.currentBold ? FontWeight.Bold : FontWeight.Normal,
            fontStyle: this.richEditorController.currentItalics ? FontStyle.Italic : FontStyle.Normal,
            fontColor: COLOR_LIST[this.richEditorController.currentColor],
            fontSize: this.richEditorController.fontSize
          }));
        });

      Image($r('app.media.ic_underline'))
        .width(24)
        .colorFilter(this.richEditorController.currentDecoration === TextDecorationType.Underline ?
          HIGHLIGHT_COLOR_FILTER : ORIGIN_COLOR_FILTER)
        .onClick(() => {
          let isUnderline = this.richEditorController.currentDecoration === TextDecorationType.Underline;
          this.richEditorController.onSelectionStyleChange(StyledStringKey.DECORATION,
            new DecorationStyle({
              type: this.richEditorController.currentDecoration =
                isUnderline ? TextDecorationType.None : TextDecorationType.Underline
            }));
        });

      Image($r('app.media.ic_deleteline'))
        .width(24)
        .colorFilter(this.richEditorController.currentDecoration === TextDecorationType.LineThrough ?
          HIGHLIGHT_COLOR_FILTER : ORIGIN_COLOR_FILTER)
        .onClick(() => {
          let isLineThrough = this.richEditorController.currentDecoration === TextDecorationType.LineThrough;
          this.richEditorController.onSelectionStyleChange(StyledStringKey.DECORATION,
            new DecorationStyle({
              type: this.richEditorController.currentDecoration =
                isLineThrough ? TextDecorationType.None : TextDecorationType.LineThrough
            }));
        });

      Image($r('app.media.ic_shadow'))
        .width(24)
        .colorFilter(this.richEditorController.currentShadow ? HIGHLIGHT_COLOR_FILTER : ORIGIN_COLOR_FILTER)
        .onClick(() => {
          this.richEditorController.currentShadow = !this.richEditorController.currentShadow;
          this.richEditorController.onSelectionStyleChange(StyledStringKey.TEXT_SHADOW,
            this.richEditorController.currentShadow ?
              new TextShadowStyle({ radius: 2, type: ShadowType.BLUR, offsetX: 3, offsetY: 3, }) :
              new TextShadowStyle({ radius: 0 }));
        });

      Image(this.isHandwriteMode ? $r('app.media.ic_keyboard') : $r('app.media.ic_handwrite'))
        .width(24)
        .height(24)
        .colorFilter(this.isHandwriteMode ? HIGHLIGHT_COLOR_FILTER : ORIGIN_COLOR_FILTER)
        .onClick(async () => {
          this.richEditorController.showMoreFunction = false;
          if (this.isHandwriteMode) {
            await this.saveHandwriteData();
            this.showToast('手写内容已保存');
            this.isHandwriteMode = false;
            this.richEditorController.showToolBarIndex = 0;
          } else {
            this.handwritePath = this.hostContext.filesDir + '/' + `handwrite_${this.noteId}`;
            this.isHandwriteMode = true;
          }
        });

      // 选择图片图标
      SymbolGlyph($r('sys.symbol.picture_fill'))
        .fontSize(24)
        .onClick(() => {
          this.richEditorController.selectImage(this.getUIContext());
        });

      // 清除所有文本图标
      Image($r('app.media.ic_public_delete'))
        .width(24)
        .onClick(() => {
          this.richEditorController.clearAllContent(this.getUIContext());
        });
    }
    .height(60)
    .width('100%')
    .padding({
      left: 16,
      right: 16,
    })
    .backgroundColor('#EDEFF5');
  }

  // 显示提示
  private showToast(message: string): void {
    this.uiContext.getPromptAction().showToast({
      message: message,
      alignment: Alignment.Center,
      duration: 1500
    });
  }

  @Builder
  previewWindowComponent() {
    Column() {
      SnapshotPreview({
        context: this.getUIContext().getHostContext(),
        mergedImage: this.snapShotController.mergedImage,
        snapPopupPosition: this.snapShotController.snapPopupPosition,
        isLargePreview: this.snapShotController.isLargePreview,
        isShowPreview: this.snapShotController.isShowPreview,
        changeMergedImage: (mergedImage) => {
          this.snapShotController.mergedImage = this.snapShotController.mergedImage;
        },
        changeSnapPopupPosition: (snapPopupPosition) => {
          this.snapShotController.snapPopupPosition = snapPopupPosition;
        },
        changeIsShowPreview: (showPreview: boolean) => {
          this.snapShotController.isShowPreview = showPreview;
        },
        changeIsLargePreview: (largePreview: boolean) => {
          this.snapShotController.isLargePreview = largePreview;
        },
      });
    };
  }

  // 段落样式选项栏
  @Builder
  paragraphFormat() {
    Flex({
      justifyContent: FlexAlign.SpaceAround,
      alignItems: ItemAlign.Center,
    }) {
      ForEach(this.richEditorController.paragraphAlignments, (item: AlignmentInfo, index: number) => {
        Image(item.icon)
          .width(24)
          .colorFilter(this.richEditorController.currentAlignment === index ? HIGHLIGHT_COLOR_FILTER :
            ORIGIN_COLOR_FILTER)
          .onClick(item.click);
      }, (item: AlignmentInfo) => JSON.stringify(item));
    }
    .width('100%')
    .height(56);
  }

  // 文本内容变化回调
  contentChangedListener: StyledStringChangedListener = {
    onWillChange: (value: StyledStringChangeValue) => {
      return true;
    },
    onDidChange: (rangeBefore, rangeAfter) => {
      this.richEditorController.onDidChange(rangeAfter.start, rangeAfter.end);
      const styledString = this.richEditorController.controller.getStyledString();
      const content = styledString.getString();
      if (content.length > this.MAX_TEXT_LENGTH) {
        const extraLength = content.length - this.MAX_TEXT_LENGTH;
        styledString.removeString(this.MAX_TEXT_LENGTH, extraLength);
        this.richEditorController.controller.setStyledString(styledString);
        this.richEditorController.controller.setCaretOffset(this.MAX_TEXT_LENGTH);
        this.showToast(`已超出最大字数限制（${this.MAX_TEXT_LENGTH}字）`);
      }
    }
  }

  build() {
    Column() {
      Stack() {
        // 富文本编辑区（标题+正文）
        Column() {
          Scroll(this.snapShotController.scroller) {
            Column() {
              // 标题
              TextInput({
                placeholder: '标题',
                text: this.noteTitle,
                controller: this.richEditorController.textInputController
              })
                .placeholderColor($r('sys.color.font_secondary'))
                .placeholderFont({ size: $r('sys.float.Body_L'), weight: FontWeight.Bold })
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .fontWeight(FontWeight.Bold)
                .width('100%')
                .height(40)
                .backgroundColor(Color.Transparent)
                .borderRadius(0)
                .onChange((value: string) => {
                  this.noteTitle = value;
                  this.titleChange(value);
                })
                .margin({ top: 12 })
                .onClick(() => {
                  this.richEditorController.showMoreFunction = false;
                })

              // 正文
              RichEditor(this.richEditorController.options)
                .placeholder('开始书写你的笔记', { fontColor: $r('sys.color.font_tertiary'), font: { size: 14 } })
                .barState(BarState.Off)
                .id(RICH_ID)
                .onReady(() => {
                  this.richEditorController.controller.onContentChanged(this.contentChangedListener);
                  this.richEditorController.controller.setStyledString(this.noteContent)
                })
                .width('100%')
                .onEditingChange((editingStatus) => {
                  this.isEditing = editingStatus;
                  this.richEditorController.showMoreFunction = false;
                  if (editingStatus) {
                    this.richEditorLayoutWeight = 1;
                    // 键盘弹出后延迟滚动，使光标所在内容上移、不被键盘遮挡
                    setTimeout(() => {
                      const scroller = this.snapShotController.scroller;
                      const cur = scroller.currentOffset();
                      const liftVp = 220;
                      scroller.scrollTo({
                        xOffset: cur.xOffset,
                        yOffset: cur.yOffset + liftVp,
                        animation: { duration: 250, curve: Curve.EaseOut }
                      });
                    }, 280);
                  } else {
                    this.richEditorLayoutWeight = 0;
                  }
                })
                .layoutWeight(this.richEditorLayoutWeight)
                .onSelectionChange((range) => {
                  let content = this.richEditorController.controller.getStyledString().getString();
                  if (content === '' || range.end === content.length) {
                    return;
                  }
                  if (range.start === undefined || range.end === undefined) {
                    return;
                  }
                  setTimeout(() => {
                    let styleString = this.richEditorController.controller
                      .getStyledString().subStyledString(range.start, 1);
                    let styles = styleString.getStyles(0, 1, StyledStringKey.PARAGRAPH_STYLE);
                    if (styles.length > 0) {
                      let paragraphStyle = styles[0].styledValue as ParagraphStyle;
                      let textAlign = paragraphStyle.textAlign;
                      switch (textAlign) {
                        case TextAlign.Center:
                          this.richEditorController.currentAlignment = 1;
                          break;
                        case TextAlign.End:
                          this.richEditorController.currentAlignment = 2;
                          break;
                        case TextAlign.JUSTIFY:
                          this.richEditorController.currentAlignment = 3;
                          break;
                        case TextAlign.Start:
                          this.richEditorController.currentAlignment = 0;
                      }
                    }
                  }, 100);
                })
                .onClick(() => {
                  // 手写模式下不允许编辑笔记，这里点击时直接退出手写模式
                  if (this.isHandwriteMode) {
                    this.isHandwriteMode = false;
                  }
                })
            }
            .width('100%')
          }
          .scrollBar(BarState.Off)
          .id(this.snapShotController.snapShotId)
          .align(Alignment.Top)
          .width('100%')
          .height('100%')
          .onAreaChange((oldValue, newValue) => {
            this.snapShotController.listComponentWidth = newValue.width as number;
            this.snapShotController.listComponentHeight = newValue.height as number;
            this.snapShotController.scrollHeight = newValue.height as number;
          })
          .onDidScroll(() => {
            this.snapShotController.curYOffset = this.snapShotController.scroller.currentOffset().yOffset;
          });
        }
        .layoutWeight(1)
        .zIndex(this.isHandwriteMode ? 0 : 1)

        // 手写层：编辑模式下在底层仅展示；手写模式下在上层可画画
        HandwriteComponent({
          handwriteController: this.handwriteController,
          defaultPenType: PenType.PEN,
          defaultPenInfo: [{ penType: PenType.PEN, penWidth: this.penWidth },
            { penType: PenType.BALLPOINT_PEN, penWidth: this.ballpointPenWidth }] as PenHspInfo[],
          widthRatio: 1,
          heightRatio: 1,
          onInit: () => {
            this.loadHandwriteData();
          }
        })
          .backgroundColor(Color.Transparent)
          .width('100%')
          .height('100%')
          .zIndex(this.isHandwriteMode ? 1 : 0)
          .onTouch((event) => {
            if (!this.isHandwriteMode) {
              return;
            }
            this.setHandwriteDirty(true);
          })
      }
      .layoutWeight(1)

      // 底部工具栏
      if (this.isHandwriteMode) {
        // 手写笔模式：只显示当前工具栏（含切回键盘按钮），不能编辑文本
        this.toolBar();
      } else {
        // 编辑模式：正常的文本编辑工具栏
        if (this.richEditorController.showToolBarIndex === 1) {
          this.colorPalette();
        } else if (this.richEditorController.showToolBarIndex === 2) {
          this.paragraphFormat();
        }
        this.toolBar();
      }
    }
    .width('100%')
    .height('100%')
    .bindContentCover(this.snapShotController.isShowPreview, this.previewWindowComponent(), {
      modalTransition: ModalTransition.NONE,
      onWillDismiss: (action: DismissContentCoverAction) => {
        if (action.reason === DismissReason.PRESS_BACK) {
        }
      },
    });
  }
}
