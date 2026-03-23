/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import {
  ACTION_NAME,
  ChangeRecord,
  MORE_ACTION_LIST,
  MoreFunction,
  Note,
  RichEditorArea,
  RichEditorController,
  SNAPSHOT_ID,
  SnapShotController,
} from 'richeditor';
import { AppStorageV2, KeyboardAvoidMode } from '@kit.ArkUI';
import { Category, NoteService } from '@ohos_agcit/notes_datasource';
import { ThemeController } from '../controller/ThemeController';
import { unifiedDataChannel } from '@kit.ArkData';
import { pasteboard, BusinessError } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';
import { KVStore, SerializeUtil } from 'serializer';
import common from '@ohos.app.ability.common';
import { GesturesShareService, NoteSharePayload } from 'grabthransfer';
import { ContinueModel, ContinueUtils } from 'continue';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { commentManager } from '@kit.AppGalleryKit';
import { AppUtil } from '@ohos_agcit/notes_utils';
import { HandwriteController } from '@kit.Penkit';

@Builder
export function EditNotesBuilder() {
  EditNotes();
}

@ComponentV2
struct EditNotes {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Consumer() kvStore: KVStore | undefined = undefined;
  @Local continueModel: ContinueModel = AppStorageV2.connect(ContinueModel, () => new ContinueModel())!;
  @Local handwriteController: HandwriteController = new HandwriteController();
  @Local isContinueRestored: boolean = false; // 接续是否已恢复
  @Local hasShownRateDialog: boolean = false; // 本次会话是否已弹出过评分
  richEditorController: RichEditorController = RichEditorController.instance;
  themeController: ThemeController = ThemeController.instance;
  noteService: NoteService = NoteService.instance;
  snapShotController: SnapShotController = new SnapShotController(SNAPSHOT_ID, new Scroller(), this.getUIContext());
  uiContext: UIContext = this.getUIContext() as UIContext;
  hostContext: common.Context = this.uiContext.getHostContext() as Context;
  @Local currentNote: Note = new Note(new MutableStyledString(''));
  @Local noteTitle: string = '';
  @Local isEditNote: boolean = false;
  // 隔空传送服务
  private gesturesShareService: GesturesShareService = GesturesShareService.getInstance();
  private noteSharePayloadCache: string | null = null;
  private noteShareCacheTimerId: number = -1;

  aboutToAppear(): void {
    // 启用压缩模式避让软键盘
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE_WITH_CARET);

    this.getUIContext().getUIObserver().on('navDestinationSwitch', (info) => {
      if (info.to === 'navBar') {
        // 还原默认上抬模式
        this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);
      }
    });

    // 开启隔空传送监听
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.gesturesShareService = GesturesShareService.getInstance(context);
    this.gesturesShareService.startGestureListening();

    // 保存当前笔记的接续状态
    if (this.isEditNote && this.currentNote.id) {
      ContinueUtils.updateContinueData(this.currentNote.id, this.currentNote.title);
    }

    // 检查并处理接续场景（目标端）
    if (ContinueUtils.isContinueScene()) {
      this.handleContinueRestore();
    }

    // 定时刷新隔空传送缓存，手势时同步取缓存即可传内容
    this.noteShareCacheTimerId = setInterval(() => {
      this.refreshNoteSharePayloadCache();
    }, 2000);
    this.refreshNoteSharePayloadCache();
  }

  aboutToDisappear(): void {
    this.richEditorController.currentIndex = -1;
    // 操作记录
    this.richEditorController.historyRecordArray = [];
    this.richEditorController.initState();
    // 取消监听
    this.getUIContext().getUIObserver().off('navDestinationSwitch');

    if (this.noteShareCacheTimerId >= 0) {
      clearInterval(this.noteShareCacheTimerId);
      this.noteShareCacheTimerId = -1;
    }
    this.noteSharePayloadCache = null;
    this.gesturesShareService.setNotePayloadGetter(undefined);
    this.gesturesShareService.stopGestureListening();

    // 清除接续标记（如果是目标端）
    if (this.continueModel.isTargetDevice) {
      ContinueUtils.clearContinueFlag();
    }

    // 确保页面退出时恢复默认避让模式
    AppUtil.setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
  }

  /**
   * 刷新隔空传送缓存（定时调用），手势时同步返回此缓存即可传内容
   */
  private refreshNoteSharePayloadCache(): void {
    const note = this.currentNote;
    SerializeUtil.serialize(note.styledString, this.getUIContext()).then((serializedStyledString: string) => {
      const payload: NoteSharePayload = {
        title: note.title || '我的笔记',
        categoryId: note.categoryId || '-1',
        serializedStyledString,
        description: note.description || '',
        createTime: note.createTime || '',
        updateTime: note.updateTime || '',
      };
      try {
        this.noteSharePayloadCache = JSON.stringify(payload);
      } catch (err) {
        let error = err as Error;
        console.error(`JSON序列化失败: ${error.message}`);
        throw new Error(`序列化分享数据失败: ${error.message}`);
      }
    }).catch(() => {
      this.noteSharePayloadCache = null;
    });
  }

  /**
   * 处理接续恢复（目标端）
   */
  private handleContinueRestore(): void {
    const continueModel: ContinueModel = AppStorageV2.connect(ContinueModel, () => new ContinueModel())!;

    if (!continueModel.noteId) {
      return;
    }

    // 1. 加载接续的笔记
    const note = this.noteService.getNoteById(continueModel.noteId);
    if (!note) {
      this.showToast('接续的笔记不存在或已删除');
      ContinueUtils.clearContinueFlag();
      return;
    }

    // 2. 更新当前笔记
    this.currentNote = note;
    this.noteTitle = note.title;
    this.isEditNote = true;

    // 3. 显示接续提示
    setTimeout(() => {
      this.showToast(`已接续到笔记: ${continueModel.noteTitle}`);
    }, 300);

    // 4. 清除接续标记（在页面加载完成后）
    setTimeout(() => {
      ContinueUtils.clearContinueFlag();
    }, 1000);
  }

  /**
   * 从控制器获取对齐方式
   */
  private getTextAlignFromController(): TextAlign {
    switch (this.richEditorController.currentAlignment) {
      case 0:
        return TextAlign.Start;
      case 1:
        return TextAlign.Center;
      case 2:
        return TextAlign.End;
      case 3:
        return TextAlign.JUSTIFY;
      default:
        return TextAlign.Start;
    }
  }

  /**
   * 显示提示
   */
  private showToast(message: string): void {
    this.getUIContext().getPromptAction().showToast({
      message: message,
      alignment: Alignment.Center,
      duration: 2000,
    });
  }

  copyNoteText() {
    if (this.currentNote?.description === '') {
      this.getUIContext().getPromptAction().showToast({
        message: '请输入内容后复制！',
        alignment: Alignment.Center,
        duration: 1500,
      });
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
      message: '复制成功',
      alignment: Alignment.Center,
      duration: 1500,
    });
  }

  /**
   * 显示更多选项视图
   */
  @Builder
  moreFunctionMenu() {
    Column() {
      List() {
        ForEach(MORE_ACTION_LIST, (item: MoreFunction) => {
          ListItem() {
            Row() {
              Image(item.icon)
                .width(24)
                .height(24)
                .margin({
                  left: 12,
                  right: 8,
                });

              Text(item.name)
                .fontSize(14)
                .fontColor($r('sys.color.font_primary'));
            }
            .width('100%')
            .height(48)
            .onClick(() => {
              if (item.name === ACTION_NAME.share) {
                this.snapShotController.onceSnapshot();
              } else if (item.name === ACTION_NAME.copy) {
                this.copyNoteText();
              }
            });
          };
        },  (item: MoreFunction) => {
          try {
            return JSON.stringify(item);
          } catch (err) {
            console.error(`JSON.stringify失败: ${(err as Error).message}`);
            return '';
          }
        });
      }
      .divider({
        strokeWidth: 0.5,
      })
      .scrollBar(BarState.Off);
    }
    .width(114)
    .backgroundColor($r('app.color.bg_more_function'))
    .margin({ top: 4, bottom: 4 });
  }

  @Builder
  toolBar() {
    if (this.richEditorController.showMoreFunction === true) {
      Row() {
        Image($r('app.media.show_more_function'))
          .width(40)
          .height(40)
          .bindMenu(this.moreFunctionMenu);
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
          .onClick(async () => {
            let isSucc = await this.saveNote();
            if (isSucc) {
              console.log('!!!---true');
              // 点击保存后退出选中状态
              this.richEditorController.controller.setSelection(0, 0);
              // 退出编辑状态
              this.richEditorController.textInputController.stopEditing();
              this.richEditorController.controller.stopEditing();
              this.richEditorController.showMoreFunction = true;
            } else {
              console.log('!!!---false');
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

  private isCurrentHandwriteDirty(): boolean {
    const dirty = AppStorage.get<boolean>('handwrite_dirty');
    const noteId = AppStorage.get<string>('handwrite_dirty_note_id');
    return dirty === true && noteId === this.currentNote.id;
  }

  /**
   * 保存笔记
   */
  async saveNote(): Promise<boolean> {
    let styledString: MutableStyledString = this.richEditorController.controller.getStyledString();
    let content = styledString.getString();
    const hasTextOrTitle = !(content === '' && this.noteTitle === '');
    const hadHandwriteDirty = this.isCurrentHandwriteDirty();

    // 保存手写内容（无论是否处于手写模式，只要画布有改动就应保存）
    if (this.handwriteController && this.currentNote.id && hadHandwriteDirty) {
      try {
        const handwritePath = this.hostContext.filesDir + '/' + `handwrite_${this.currentNote.id}`;
        await this.handwriteController.save(handwritePath);
        console.info('手写内容已保存');
        AppStorage.setOrCreate('handwrite_dirty_note_id', this.currentNote.id);
        AppStorage.setOrCreate('handwrite_dirty', false);
      } catch (error) {
        console.error('保存手写内容失败:', error);
      }
    }

    if (!hasTextOrTitle && !hadHandwriteDirty) {
      return this.isEditNote ? false : true;
    }

    if (this.isEditNote) {
      if (hasTextOrTitle) {
        this.currentNote.updateContent(styledString, this.noteTitle);
      }
      this.noteService.updateNote(this.currentNote, this.kvStore, this.uiContext, this.hostContext);
    } else {
      this.currentNote.title = this.noteTitle;
      this.currentNote.styledString = this.richEditorController.controller.getStyledString();
      this.currentNote.description = this.currentNote.styledString.getString();
      this.currentNote.handwriteFileName = `handwrite_${this.currentNote.id}`;
      this.noteService.addNote(this.currentNote, this.kvStore, this.uiContext);
      this.isEditNote = true;

      // 全局第一次新建笔记并成功保存后，尝试拉起应用内评分弹窗
      this.showRateDialogOnce();
    }

    // 更新接续数据（确保当前笔记可以作为源端接续）
    if (this.isEditNote && this.currentNote.id) {
      ContinueUtils.updateContinueData(this.currentNote.id, this.currentNote.title);
    }

    return true;
  }

  /**
   * 全局仅在第一次新建笔记成功后拉起评分弹窗
   */
  private async showRateDialogOnce(): Promise<void> {
    // 本页会话内已弹出过，直接返回
    if (this.hasShownRateDialog) {
      return;
    }

    // 先检查全局持久化标记，已弹出过则不再弹
    try {
      if (this.kvStore) {
        const record = await this.kvStore.get('rateDialogShown');
        if (record && record.value === true) {
          this.hasShownRateDialog = true;
          return;
        }
      }
    } catch (error) {
      console.error('check rateDialogShown flag failed: ' + (error as BusinessError)?.message);
    }

    this.hasShownRateDialog = true;
    try {
      const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
      await commentManager.showCommentDialog(ctx);
      // 调用成功后，写入全局标记，后续不再弹出
      if (this.kvStore) {
        await this.kvStore.put('rateDialogShown', true);
      }
    } catch (error) {
      console.error('showCommentDialog failed: ' + (error as BusinessError)?.message);
    }
  }

  backDialogController: CustomDialogController = new CustomDialogController({
    builder: () => {
      this.backDialog();
    },
    alignment: DialogAlignment.Center,
  });

  @Builder
  backDialog() {
    Column({ space: 18 }) {
      Text('确认返回')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'));

      Column() {
        Text('当前笔记或画布内容尚未保存，立刻返回则')
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'));

        Text('无法保存，是否确定返回？')
          .fontSize(14)
          .fontColor($r('sys.color.font_primary'));
      };

      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Row() {
          Text('取消')
            .fontColor($r('sys.color.icon_emphasize'))
            .fontSize(16);
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
        .onClick(() => {
          this.backDialogController.close();
        });

        Row() {
          Text('确定')
            .fontColor($r('sys.color.icon_emphasize'))
            .fontSize(16);
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
        .onClick(async () => {
          this.backDialogController.close();
          await this.saveNote();
          this.appPathStack.pop();
        });
      }
      .padding({
        top: 10,
      });
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.themeController.dialogBgWhite)
    .borderRadius(32)
    .height(158)
    .width('92%');
  }

  build() {
    NavDestination() {
      Column() {
        RichEditorArea({
          noteTitle: this.currentNote.title,
          noteContent: this.currentNote.styledString,
          snapShotController: this.snapShotController,
          noteId: this.currentNote.id,
          handwriteController: this.handwriteController,
          titleChange: (title: string) => {
            this.noteTitle = title;
          },
        });
      }
      .height('100%')
      .width('100%');
    }
    .onShown(() => {
      // 激活接续能力
      if (this.isEditNote) {
        const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
        ContinueUtils.enableContinue(context);
      }
      // 每次页面显示时刷新隔空传送的当前笔记与同步 getter（返回缓存）
      this.gesturesShareService.setCurrentNote(this.currentNote.id, this.currentNote.title);
      this.gesturesShareService.setNotePayloadGetter(() => this.noteSharePayloadCache);
    })
    .menus(this.toolBar())
    .onReady((cxt: NavDestinationContext) => {
      let params = cxt.pathInfo.param as Record<string, Object>;
      let noteId = params.noteId as string;

      // 优先使用接续的笔记ID
      if (ContinueUtils.isContinueScene()) {
        const continueNoteId = ContinueUtils.getContinueNoteId();
        if (continueNoteId && continueNoteId !== '') {
          noteId = continueNoteId;
          hilog.info(0x0000, 'EditNotes', `使用接续的笔记ID: ${noteId}`);
        }
      }

      if (noteId === '') {
        this.isEditNote = false;
        this.currentNote = new Note(new MutableStyledString(''));
        this.noteTitle = '';
        const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
        ContinueUtils.disableContinue(context);
      } else {
        this.isEditNote = true;

        let note = this.noteService.getNoteById(noteId);
        if (note) {
          this.currentNote = note;
        }
      }

      // 供隔空传送使用：当前笔记 id/title + 同步返回缓存的 getter
      this.gesturesShareService.setCurrentNote(this.currentNote.id, this.currentNote.title);
      this.gesturesShareService.setNotePayloadGetter(() => this.noteSharePayloadCache);

      this.richEditorController.currentIndex = 0;
      this.richEditorController.historyRecordArray.push(new ChangeRecord(this.currentNote.styledString));
      this.currentNote.categoryId = (params.currentCategory as Category).id;

      // 打开编辑页面后更新接续数据，保证源端有“当前打开的笔记”
      if (this.isEditNote && this.currentNote.id) {
        ContinueUtils.updateContinueData(this.currentNote.id, this.currentNote.title);
      }
    })
    .onBackPressed(() => {
      // 三个点（更多）状态下：如果画布有改动，仍需弹窗确认并保存
      if (this.richEditorController.showMoreFunction) {
        if (this.isCurrentHandwriteDirty()) {
          this.backDialogController.open();
        } else {
          this.appPathStack.pop();
        }
        return true;
      }

      // 编辑态：按返回键弹出弹窗
      this.backDialogController.open();
      return true;
    });
  }
}
