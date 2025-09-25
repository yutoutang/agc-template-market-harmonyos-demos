import { unifiedDataChannel } from '@kit.ArkData';
import { pasteboard } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { PersistenceV2 } from '@kit.ArkUI';
import dayjs from 'dayjs';
import { RichEditorController } from '../controller/RichEditorController'
import { SnapShotController } from '../controller/SnapShotController';
import { SNAPSHOT_ID, TEXT_PICKER_DATA } from '../commons/Constant';
import { ChangeDiaryRecord } from '../models/ChangeRecord';
import { Diary, DiaryExtraInfo } from '../models/Diary';
import { DiaryUtil } from '../utils/DiaryUtil';
import { PopViewUtils } from '../utils/PopViewUtils';
import { PageMode, TEXT_PICKER_LABEL } from '../commons/Enum';
import { textPickerBuilder, TextPickerBuilderParams } from '../components/CommonTextPicker';
import { dateTimePickerBuilderParams, DateTimePickerResult, IconTextItem, MoreFunction } from '../commons/Interface';
import { dateTimePickerBuilder, DateTimePickerBuilderParams } from '../components/DateTimePickerSheet';
import { DateUtil } from '../utils/DateUtil';
import { baseTimePickerBuilder } from '../components/BaseTimePicker';
import { baseDatePickerBuilder } from '../components/BaseDatePicker';
import { DiaryDB } from '../database/DiaryDB';
import { ImageUtils } from '../utils/ImageUtils';
import { handleTaskPoolDelete } from '../utils/TaskPoolHandle';


@ObservedV2
export class DiaryEditorPageVM {
  richEditorController: RichEditorController = new RichEditorController();
  diaryUtil: DiaryUtil = DiaryUtil.instance;
  snapShotController: SnapShotController = new SnapShotController(SNAPSHOT_ID, new Scroller());
  @Trace diaryExtraInfo: DiaryExtraInfo = PersistenceV2.connect(DiaryExtraInfo, () => new DiaryExtraInfo())!;

  @Trace currentDiary: Diary = new Diary();
  @Trace isEdit: boolean = false;
  @Trace date: string = dayjs().format();
  @Trace dateTime: string = dayjs().format('HH:mm');
  @Trace pageMode: PageMode = PageMode.CREATE
  @Trace timer: number | null = null;
  @Trace isLoading: boolean = true;
  @Trace weatherText: string = '';
  @Trace weatherIcon: string = 'sys.symbol.cloud_and_sun_filled';
  @Trace moodText: string = '';
  @Trace moodIcon: string = 'sys.symbol.face_smiling';
  @Trace createDiaryId: number = -1;
  @Trace moreMenuList: MoreFunction[] = [
    {
      name: '设为私密',
      onClick: () => {
        this.handleDiaryPrivacy()
      }
    },
    {
      name: '编辑',
      onClick: () => {
        this.pushToEditPage()
      }
    },
    {
      name: '分享',
      onClick: () => {
        this.snapShotController.onceSnapshot()
      }
    },
  ]

  uiContext?: UIContext;
  pathStack: NavPathStack = new NavPathStack();

  constructor(uiContext: UIContext) {
    this.uiContext = uiContext
  }

  @Computed
  get dateLabel() {
    return dayjs(this.date).format('YYYY年MM月DD日');
  }

  async initData(params: Record<string, Object>) {
    this.isLoading = true;
    this.pageMode = params.pageMode as PageMode;
    let id = params.diaryId as string;
    if (id) {
      await this.getDiary(id)
    }
    this.isLoading = false;
    // 处理天气和心情
    this.handleMoodAndWeather()
    // 设置自动保存
    this.setAutoSaveDiary();
    this.richEditorController.currentIndex = 0;
    this.richEditorController.historyRecordArray.push(new ChangeDiaryRecord(this.currentDiary.styledString));
    this.moreMenuList[0].name = this.currentDiary.isPrivacy ? '取消私密' : '设为私密';
  }

  async getDiary(id: string) {
    let data = await DiaryDB.queryDiaryById(id);
    if (data) {
      let diary = new Diary(data);
      let styledString = await StyledString.fromHtml(data.htmlContent);
      diary.styledString = styledString as MutableStyledString;
      this.currentDiary = diary;
      this.richEditorController.richTextContent = diary.textContent;
    }
  }

  handleMoodAndWeather() {
    this.weatherText = this.currentDiary.weatherText;
    this.weatherIcon = this.currentDiary.weatherIcon;
    this.moodText = this.currentDiary.moodText;
    this.moodIcon = this.currentDiary.moodIcon;
  }

  setAutoSaveDiary() {
    let showAutoSaveTip: boolean = this.diaryExtraInfo.showAutoSaveTip;
    let time: number = this.diaryExtraInfo.autoSaveTime;
    // 编辑页，且开启自动保存
    if (this.pageMode !== PageMode.VIEW) {
      this.timer = setTimeout(async () => {
        if (this.checkSaveDiary()) {
          // 处理日记数据
          this.handleSaveDiary();
          if (this.pageMode === PageMode.EDIT) {
            await DiaryDB.updateDiary(this.currentDiary);
          } else {
            // 新建日记，首次自动保存时，插入一条数据。再次保存时会更新
            if (this.createDiaryId === -1) {
              this.createDiaryId = await DiaryDB.insertDiary(this.currentDiary);
            } else {
              this.currentDiary.id = this.createDiaryId.toString();
              await DiaryDB.updateDiary(this.currentDiary);
            }
          }
          if (showAutoSaveTip) {
            this.showToast('已自动保存');
          }
        }
        this.setAutoSaveDiary();
      }, time * 1000)
    }
  }

  stopAutoSave() {
    if (this.timer !== null) {
      clearTimeout(this.timer);
      this.timer = null;
    }
    this.richEditorController.isSave = false;
  }

  // 跳转到编辑页
  pushToEditPage() {
    const params: Record<string, Object> = {
      'diaryId': this.currentDiary.id,
      'pageMode': PageMode.EDIT,
    };
    this.pathStack.pushPathByName('DiaryEditorPage', params, async () => {
      // 从编辑页返回详情页，刷新页面
      this.isLoading = true
      await this.getDiary(this.currentDiary.id);
      this.isLoading = false;
      const styledString = await StyledString.fromHtml(this.currentDiary.htmlContent);
      this.richEditorController.controller.setStyledString(styledString);
    });
  }

  // 返回事件
  onBack() {
    // 按返回键弹出弹窗
    this.showConfirmDialog()
    return true;
  }

  // 页面销毁事件
  handleDisappear() {
    this.richEditorController.currentIndex = -1;
    // 操作记录
    this.richEditorController.historyRecordArray = [];
    this.richEditorController.initState();
  }

  showConfirmDialog() {
    this.uiContext?.getPromptAction().showDialog({
      title: '退出编辑',
      message: '确认要退出日记编写并丢弃当前内容吗？',
      alignment: 	DialogAlignment.Center,
      buttons: [
        {
          text: '取消',
          color: $r('sys.color.icon_emphasize')
        },
        {
          text: '确定',
          color: $r('sys.color.icon_emphasize')
        }
      ]
    }, (err, data) => {
      if (err) {
        return;
      }
      if (data.index === 1) {
        if (this.pageMode === PageMode.EDIT) {
          this.pathStack.pop(this.pageMode);
        } else {
          this.pathStack.pop();
        }
        this.stopAutoSave()
      }
    });
  }

  // 处理隐私开关
  handleDiaryPrivacy() {
    let pwd = this.diaryExtraInfo.password;
    let isOn = !this.currentDiary.isPrivacy;
    // 打开开关
    if (isOn) {
      // 已经设置隐私密码
      if (pwd) {
        // 需要输入隐私密码
        this.diaryUtil.openPrivacyPwdInputDialog(async () => {
          this.currentDiary.isPrivacy = isOn;
          await DiaryDB.updateDiary(this.currentDiary);
          this.moreMenuList[0].name = isOn ? '取消私密' : '设为私密';
        })
      } else {
        // 需要设置隐私密码
        this.diaryUtil.openPrivacyPasswordDialog(async (password: string) => {
          this.currentDiary.isPrivacy = isOn;
          this.diaryExtraInfo.password = password;
          await DiaryDB.updateDiary(this.currentDiary);
          this.moreMenuList[0].name = '取消私密';
        })
      }
    } else {
      // 需要输入隐私密码
      this.diaryUtil.openPrivacyPwdInputDialog(async () => {
        this.currentDiary.isPrivacy = isOn;
        await DiaryDB.updateDiary(this.currentDiary);
        this.moreMenuList[0].name = isOn ? '取消私密' : '设为私密';
      })
    }
  }

  // 日期选择
  handleDatePicker() {
    this.openDateTimePickerSheet(this.date, '选择日期', wrapBuilder(baseDatePickerBuilder),
      (value: DateTimePickerResult) => {
        this.date = value as string;
      }
    )
  }

  // 时间选择
  handleTimePicker() {
    let dateTime = dayjs(this.date).format('YYYY-MM-DD') + 'T' + this.dateTime;
    this.openDateTimePickerSheet(dateTime, '选择时间', wrapBuilder(baseTimePickerBuilder),
      (value: DateTimePickerResult) => {
        if (value) {
          let time = value as TimePickerResult
          if (time.hour >= 0) {
            this.dateTime = DateUtil.dateTimeFormat(time)
          }
        }
      }
    )
  }

  // 日期、时间选择弹框
  openDateTimePickerSheet(
    date: string,
    title: string,
    contentBuilder: WrappedBuilder<[dateTimePickerBuilderParams]>,
    callback: (value: DateTimePickerResult) => void
  ) {
    let builderParams: DateTimePickerBuilderParams = {
      date: date,
      title: title,
      contentBuilder: contentBuilder,
      confirm: (value: DateTimePickerResult) => {
        callback?.(value)
        PopViewUtils.closeSheet()
      },
      cancel: () => {
        PopViewUtils.closeSheet()
      }
    }
    PopViewUtils.showSheet(wrapBuilder(dateTimePickerBuilder), {
      height: 400,
      preferType: SheetType.BOTTOM,
      showClose: false,
    }, builderParams);
  }

  // 天气、心情选择弹框
  openTextPickerSheet(type: string) {
    let textList: IconTextItem[] = TEXT_PICKER_DATA[type];
    let builderParams: TextPickerBuilderParams = {
      textList: textList,
      type: type,
      confirm: (data: IconTextItem) => {
        if (type === 'weather'){
          this.weatherText = data.text;
          this.weatherIcon = data.icon;
        } else if (type === 'mood') {
          this.moodText = data.text;
          this.moodIcon = data.icon;
        }
        PopViewUtils.closeSheet()
      },
    }
    PopViewUtils.showSheet(wrapBuilder(textPickerBuilder), {
      height: 360,
      preferType: SheetType.BOTTOM,
      title: { title: TEXT_PICKER_LABEL[type] },
    }, builderParams);
  }

  // 保存日记
 async save() {
    if (!this.checkSaveDiary()) {
      return
    }
    // 处理日记数据
    this.handleSaveDiary();
    if (this.pageMode === PageMode.EDIT) {
      await DiaryDB.updateDiary(this.currentDiary);
    } else {
      // 新建日记，如果已经自动保存过，在点击保存按钮时，更新数据
      if (this.createDiaryId === -1) {
        this.createDiaryId = await DiaryDB.insertDiary(this.currentDiary);
      } else {
        this.currentDiary.id = this.createDiaryId.toString();
        await DiaryDB.updateDiary(this.currentDiary);
      }
    }
    // 点击保存后退出选中状态
    this.richEditorController.controller.setSelection(0, 0);
    // 退出编辑状态
    this.richEditorController.textInputController.stopEditing();
    this.richEditorController.controller.stopEditing();
    this.stopAutoSave();
    if (this.pageMode === PageMode.EDIT) {
      this.pathStack.pop(this.pageMode);
    } else {
      this.pathStack.pop();
    }
  }

  handleSaveDiary() {
    const styledString = this.richEditorController.controller.getStyledString();
    let dateTimeStr = dayjs(this.date).format('YYYY-MM-DD') + 'T' + this.dateTime;
    let timeStr = new Date(dateTimeStr).getTime().toString();
    this.currentDiary.styledString = styledString;
    this.currentDiary.textContent = styledString.getString();
    this.currentDiary.weatherText = this.weatherText;
    this.currentDiary.weatherIcon = this.weatherIcon;
    this.currentDiary.moodText = this.moodText;
    this.currentDiary.moodIcon = this.moodIcon;
    if (this.pageMode === PageMode.CREATE) {
      this.currentDiary.createTime = timeStr;
    }
    this.currentDiary.updateTime = timeStr;
    this.richEditorController.isSave = true;
    // 处理富文本内容
    this.handleRichEditorContent();
  }

  handleRichEditorContent() {
    const styledString = this.richEditorController.controller.getStyledString();
    const htmlStr = StyledString.toHtml(styledString);

    const context = this.uiContext!.getHostContext() as common.UIAbilityContext
    // 找出富文本中的图片
    const imgSrcList: string[] = ImageUtils.findImgSrcList(htmlStr);
    const newImgSrcList: string[] = imgSrcList.filter((src: string) => {
      return src.includes('/temp/htmlconvert/');
    }).map((src: string) => {
      const imgName = src.split('/temp/htmlconvert/')[1];
      const newPath = ImageUtils.saveToCache(context, src, imgName);
      return newPath
    });
    const firstImg = newImgSrcList[0];
    // 保存第一张图片
    this.currentDiary.firstImage = firstImg ?? '';
    // 替换html中的所有img的src
    const newHtmlStr = this.replaceImgSrc(htmlStr, newImgSrcList);
    if (this.pageMode === PageMode.EDIT) {
      // 需要将富文本中更新的图片从沙箱中删除
      const oldImgSrcList: string[] = ImageUtils.findImgSrcList(this.currentDiary.htmlContent);
      handleTaskPoolDelete(oldImgSrcList, newImgSrcList)
    }
    this.currentDiary.htmlContent = newHtmlStr;
  }

  checkSaveDiary(): boolean {
    const styledString = this.richEditorController.controller.getStyledString();
    const length = styledString?.length;
    return length > 0;
  }

  // 替换html中img的地址
  replaceImgSrc(html: string, newSrcList: string[]): string {
    let index = 0;
    return html.replace(/(<img[^>]+src=["'])([^"']+)(["'])/g, (match, p1: string, oldSrc: string, p3: string) => {
      const newSrc: string = newSrcList[index++] || oldSrc;
      return `${p1}${newSrc}${p3}`;
    });
  }

  // 复制操作
  copyNoteText() {
    if (this.currentDiary?.textContent === '') {
      this.showToast('请输入内容后复制！')
      return;
    }
    let copyText = this.currentDiary?.textContent || '';
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

    this.showToast('复制成功')
  }

  showToast(message: string) {
    this.uiContext?.getPromptAction().showToast({
      message: message,
      alignment: Alignment.Center,
      duration: 1500
    })
  }
}