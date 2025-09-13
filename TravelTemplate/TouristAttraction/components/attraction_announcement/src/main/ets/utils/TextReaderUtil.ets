import { ReadStateCode, TextReader } from '@kit.SpeechKit';
import { UIContext } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { PlayInfo } from 'module_base';

const TAG = 'TEXT_READER';

@ObservedV2
export class TextReaderUtil {
  private static _instance: TextReaderUtil;
  readInfo: TextReader.ReadInfo = {
    id: '',
    title: {
      text: '',
      isClickable: true,
    },
  };
  private context?: Context;
  @Trace readState: ReadStateCode = ReadStateCode.WAITING;

  public static get instance() {
    if (!TextReaderUtil._instance) {
      TextReaderUtil._instance = new TextReaderUtil();
    }
    return TextReaderUtil._instance;
  }

  async init(playInfo: PlayInfo, uiContext: UIContext) {
    this.readInfo = {
      id: playInfo.playId,
      title: {
        text: playInfo.title,
        isClickable: true,
      },
      imageUrl: playInfo.imageUrl,
      bodyInfo: playInfo.introduction,
    };

    const readerParam: TextReader.ReaderParam = {
      isVoiceBrandVisible: true,
      businessBrandInfo: {
        panelName: playInfo.panelName,
        panelIcon: playInfo.panelIcon,
      },
      reportProgressPeriod: 1,
    };

    this.context = uiContext.getHostContext();
    if (this.context) {
      try {
        await TextReader.init(this.context, readerParam);
        await this.start();
      } catch (err) {
        hilog.error(0x0001, TAG, 'init error: %{public}s', JSON.stringify(err));
        if (err.code === 1010600011) {
          TextReader.stop().then(async () => {
            TextReader.release();
            if (this.context) {
              await TextReader.init(this.context, readerParam);
              await this.start();
            }
          });
        }
      }
    }
  }

  async start() {
    if (this.readState === ReadStateCode.PLAYING) {
      TextReader.showPanel();
      return;
    }
    try {
      this.setActionListener();
      this.setEventListener();
      await TextReader.start([this.readInfo], this.readInfo?.id);
    } catch (err) {
      hilog.error(0x0001, TAG, 'init message: %{public}s', JSON.stringify(err));
    }
  }

  setActionListener() {
    TextReader.on('clickNotification', (id: string) => {
      hilog.info(0x0001, TAG, `onClickNotification ${id}`);
    });
    TextReader.on('showPanel', () => {
      hilog.info(0x0001, TAG, `onShowPanel`);
    });
    TextReader.on('hidePanel', () => {
      hilog.info(0x0001, TAG, `onHidePanel`);
    });
    TextReader.on('stop', () => {
      hilog.info(0x0001, TAG, `onStop`);
    });
    TextReader.on('release', () => {
      hilog.info(0x0001, TAG, `onRelease`);
    });
    TextReader.on('stateChange', (state: TextReader.ReadState) => {
      hilog.info(0x1, TAG, `ReadState: %{public}s`, JSON.stringify(state));
      this.onStateChanged(state);
    });
    TextReader.on('readProgress', (readProgress: TextReader.ReadProgress) => {
      hilog.info(0x0001, TAG, `Succeeded in setting readProgressListener: ${JSON.stringify(readProgress)}`);
    });
    TextReader.on('requestMore', () => this.onStateChanged);
  }

  onStateChanged = (state: TextReader.ReadState) => {
    hilog.info(0x1, TAG, `selectedReadInfo.id: %{public}s`, this.readInfo?.id);
    hilog.warn(0x1, TAG, `match, changeState to %{public}s`, JSON.stringify(state));
    this.readState = state.state;
  };

  setEventListener() {
    TextReader.on('eventNotification', (event: TextReader.NotificationEvent) => {
      hilog.info(0x0001, TAG, `Notification event: ${JSON.stringify(event)}`);
    });
    TextReader.on('eventPanel', (event: TextReader.PanelEvent) => {
      hilog.info(0x0001, TAG, `Panel event: ${JSON.stringify(event)}`);
    });
    TextReader.on('eventReadList', (event: Array<TextReader.ListEventState>) => {
      hilog.info(0x0001, TAG, `ReadList event: ${JSON.stringify(event)}`);
      TextReader.loadMore([], true);
    });
    TextReader.on('readProgress', (readProgress: TextReader.ReadProgress) => {
      hilog.info(0x0001, TAG, `Succeeded in setting readProgressListener: ${JSON.stringify(readProgress)}`);
    });
  }
}