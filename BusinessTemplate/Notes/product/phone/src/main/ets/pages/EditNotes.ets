import { RichEditorController, RichEditorArea, ChangeRecord, MORE_ACTION_LIST,
  MoreFunction, SnapShotController, ACTION_NAME,
  Note,
  SNAPSHOT_ID} from 'richeditor';
import { KeyboardAvoidMode } from '@kit.ArkUI';
import { Category, NoteService } from '@ohos_agcit/notes_datasource';
import { ThemeController } from '../controller/ThemeController';
import { unifiedDataChannel } from '@kit.ArkData';
import { pasteboard } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';

@Builder
export function EditNotesBuilder() {
  EditNotes();
}

@ComponentV2
struct EditNotes {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  richEditorController: RichEditorController = RichEditorController.instance;
  themeController: ThemeController = ThemeController.instance;
  noteService: NoteService = NoteService.instance;
  snapShotController: SnapShotController = new SnapShotController(SNAPSHOT_ID, new Scroller());
  @Local currentNote: Note = new Note(new MutableStyledString(''));
  @Local noteTitle: string = '';
  @Local isEditNote: boolean = false;


  aboutToAppear(): void {
    // 启用压缩模式避让软键盘
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE_WITH_CARET);

    this.getUIContext().getUIObserver().on('navDestinationSwitch', (info) => {
      if (info.to === 'navBar') {
        // 还原默认上抬模式
        this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);
      }
    });
  }

  aboutToDisappear(): void {
    this.richEditorController.currentIndex = -1;
    // 操作记录
    this.richEditorController.historyRecordArray = [];
    this.richEditorController.initState();
    // 取消监听
    this.getUIContext().getUIObserver().off('navDestinationSwitch');
  }

  copyNoteText() {
    if (this.currentNote?.description === '') {
      this.getUIContext().getPromptAction().showToast({
        message:'请输入内容后复制！',
        alignment: Alignment.Center,
        duration: 1500
      })
      return;
    }
    let copyText = this.currentNote?.description || '';
    let plainTextData = new unifiedDataChannel.UnifiedData();
    let plainText = new unifiedDataChannel.PlainText();
    plainText.details = {
      key: 'delayPlaintext',
      value: copyText,
    };
    plainText.textContent = copyText;
    plainText.abstract = 'delayTextContent';
    plainTextData.addRecord(plainText);
    let systemPasteboard: pasteboard.SystemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setUnifiedData(plainTextData);
    this.getUIContext().getPromptAction().showToast({
      message:'复制成功',
      alignment: Alignment.Center,
      duration: 1500
    })
  }
  /**
   * 显示更多选项视图
   */
  @Builder
  moreFunctionMenu(){
    Column(){
      List(){
        ForEach(MORE_ACTION_LIST, (item: MoreFunction) => {
          ListItem(){
            Row(){
              Image(item.icon)
                .width(24)
                .height(24)
                .margin({
                  left: 12,
                  right: 8
                })

              Text(item.name)
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'))
            }
            .width('100%')
            .height(48)
            .onClick(() => {
              if (item.name === ACTION_NAME.share) {
                this.snapShotController.onceSnapshot()
              } else if (item.name === ACTION_NAME.copy) {
                this.copyNoteText()
              }
            })
          }
        }, (item: MoreFunction) => JSON.stringify(item))
      }
      .divider({
        strokeWidth: 0.5
      })
      .scrollBar(BarState.Off)
    }
    .width(114)
    .backgroundColor($r('app.color.bg_more_function'))
    .margin({ top: 4, bottom: 4 })
  }

  @Builder
  toolBar() {
    if (this.richEditorController.showMoreFunction === true){
      Row(){
        Image($r('app.media.show_more_function'))
          .width(40)
          .height(40)
          .bindMenu(this.moreFunctionMenu)
      }
      .height('100%')
      .width(150)
      .justifyContent(FlexAlign.End)
      .margin({
        right: 16,
      });
    } else {
      Row({ space: 12 }) {
        Image(this.richEditorController.currentIndex < 1 ? $r('app.media.undo_expire') : $r('app.media.undo_effect'))
          .width(40)
          .height(40)
          .onClick(() => {
            this.richEditorController.onDo();
          });

        Image(this.richEditorController.currentIndex >= this.richEditorController.historyRecordArray.length - 1 ?
        $r('app.media.redo_expire') : $r('app.media.redo_effect'))
          .width(40)
          .height(40)
          .onClick(() => {
            this.richEditorController.reDo();
          });

        Image($r('app.media.save'))
          .height(40)
          .width(40)
          .onClick(() => {
            if (this.saveNote()){
              // 点击保存后退出选中状态
              this.richEditorController.controller.setSelection(0, 0);
              // 退出编辑状态
              this.richEditorController.textInputController.stopEditing();
              this.richEditorController.controller.stopEditing();
              this.richEditorController.showMoreFunction = true;
            }
          });
      }
      .height('100%')
      .width(150)
      .justifyContent(FlexAlign.Center)
      .margin({
        right: 16,
      });
    }
  }

  /**
   * 保存笔记
   */
  saveNote(): boolean {
    let styledString = this.richEditorController.controller.getStyledString();
    let content = styledString.getString();
    // 若新增笔记 内容和标题为空，不保存
    // 修改笔记   内容和标题为空，按返回无响应
    if (content === '' && this.noteTitle === '') {
      return this.isEditNote ? false: true;
    }

    if (this.isEditNote) {
      this.currentNote.updateContent(styledString, this.noteTitle);
    } else {
      this.currentNote.title = this.noteTitle
      this.currentNote.styledString = this.richEditorController.controller.getStyledString();
      this.currentNote.description = this.currentNote.styledString.getString();
      this.noteService.addNote(this.currentNote);
      this.isEditNote = true;
    }
    return true;
  }

  backDialogController: CustomDialogController = new CustomDialogController({
    builder: () => {
      this.backDialog();
    },
    alignment: DialogAlignment.Center
  });

  @Builder
  backDialog() {
    Column({ space: 18 }) {
      Text('确认返回')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))

      Column(){
        Text('当前笔记尚未保存，立刻返回则')
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'))

        Text('无法保存当前笔记内容，是否确定返回？')
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'))
      }

      Flex({justifyContent: FlexAlign.SpaceAround}){
        Row(){
          Text('取消')
            .fontColor($r('sys.color.icon_emphasize'))
            .fontSize(16)
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
        .onClick(() => {
          this.backDialogController.close();
        })

        Row(){
          Text('确定')
            .fontColor($r('sys.color.icon_emphasize'))
            .fontSize(16)
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
        .onClick(() => {
          this.backDialogController.close();
          this.appPathStack.pop()
        })
      }
      .padding({
        top: 10
      })
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.themeController.dialogBgWhite)
    .borderRadius(32)
    .height(158)
    .width('92%')
  }

  build() {
    NavDestination() {
      Column() {
        RichEditorArea({
          noteTitle: this.currentNote.title,
          noteContent: this.currentNote.styledString,
          snapShotController: this.snapShotController,
          titleChange: (title: string) => {
            this.noteTitle = title;
          },
        })
      }
      .height('100%')
      .width('100%');
    }
    .menus(this.toolBar())
    .onReady((cxt: NavDestinationContext) => {
      let params = cxt.pathInfo.param as Record<string, Object>;
      let noteId = params.noteId as string;
      if (noteId === '') {
        this.isEditNote = false;
      } else {
        this.isEditNote = true;
        let note = this.noteService.getNoteById(noteId);
        if (note) {
          this.currentNote = note;
        }
      }

      this.richEditorController.currentIndex = 0;
      this.richEditorController.historyRecordArray.push(new ChangeRecord(this.currentNote.styledString))
      this.currentNote.categoryId = (params.currentCategory as Category).id;
    })
    .onBackPressed(() => {
      // 若已处于显示更多选项状态，直接返回，否则先退出编辑态，处于更多选项状态
      if (this.richEditorController.showMoreFunction) {
        this.appPathStack.pop();
        return true;
      }

      // 按返回键弹出弹窗
      this.backDialogController.open();
      return true;
    });
  }
}