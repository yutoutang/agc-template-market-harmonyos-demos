import { TextReader, TextReaderIcon, ReadStateCode } from '@kit.SpeechKit';
import { emitter } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';

@ComponentV2
export struct ReadNewsComponent {
  @Param @Require currentId: string
  @Param @Require body: string
  @Param @Require title: string
  @Param @Require author: string
  @Param @Require date: string
  @Param bundleName: string = '小艺朗读'
  @Param coverImage: string = ''
  @Event stateChange: () => void = () => {}
  @Local readInfoList: TextReader.ReadInfo[] = []
  @Local localCoverImage: PixelMap | undefined = undefined

  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  async aboutToAppear() {
    this.readInfoList = [{
      id: this.currentId,
      title: {
        text: this.title,
        isClickable: true,
      },
      author: {
        text: this.author,
        isClickable: true,
      },
      imageUrl:this.coverImage,
      date: {
        text: this.date,
        isClickable: false,
      },
      bodyInfo: this.body,
    }];
    let event: emitter.InnerEvent = {
      eventId: 1,
      priority: emitter.EventPriority.IMMEDIATE,
    };
    emitter.on(event, (data) => {
      console.log(JSON.stringify(data) + '点击事件')
    })
  }

  build() {
    Column() {
      ReadIcon({
        readInfoListString: JSON.stringify(this.readInfoList),
        currentId: this.currentId,
        bundleName:this.bundleName,
        localCoverImage: this.localCoverImage,
      })
    }
    .height('100%')
  }
}

@Component
struct ReadIcon {
  /**
   * 包名
   */
  @Prop bundleName: string = '小艺朗读'
  /**
   * 播放状态
   */
  @State readState: ReadStateCode = ReadStateCode.WAITING;
  /**
   * 用于显示当前页的按钮状态
   */
  @State isInit: boolean = false;
  /**
   * 播放加载数据,传入的格式id,title的text,author的text,date的text,bodyInfo内容,封面的PixelMap
   */
  @State readInfo: TextReader.ReadInfo | undefined = undefined
  /**
   * 用于显示播放的id
   */
  @Prop readInfoListString: string
  @Prop localCoverImage:PixelMap

  @State readInfoList: TextReader.ReadInfo[] | undefined = undefined

  /**
   * 用于显示播放的id
   */
  @Prop currentId: string

  /**
   * 初始化
   */
  async init() {
    const readerParam: TextReader.ReaderParam = {
      isVoiceBrandVisible: true,
      businessBrandInfo: {
        panelName: this.bundleName,
        panelIcon: $r('app.media.startIcon'),
      },
    }
    try {
      let context: Context | undefined = this.getUIContext().getHostContext()
      if (context) {
        await TextReader.init(context, readerParam);
        this.isInit = true;
      }
    } catch (err) {
      console.error(`TextReader failed to init. Code: ${err.code}, message: ${err.message}`);
    }
  }

  async aboutToAppear() {
    this.readInfoList = JSON.parse(this.readInfoListString) as TextReader.ReadInfo[]
    this.readInfoList.forEach((item) => {
      if (item.id === this.currentId) {
        this.readInfo = item
      }
    })
    this.init();
  }

  onStateChanged = (state: TextReader.ReadState) => {
    if (this.readInfo?.id === state.id) {
      this.readState = state.state;
    } else {
      this.readState = ReadStateCode.WAITING;
    }
  }

  // 设置操作监听
  setActionListener() {
    TextReader.on('stateChange', (state: TextReader.ReadState) => {
      this.onStateChanged(state)
    });
    TextReader.on('requestMore', () => this.onStateChanged);
    TextReader.on('eventPanel', (pe: TextReader.PanelEvent) => {
      // 监听点击上一条或者下一条音频
      if (pe.click === 'BPC_03' || pe.click === 'BPC_04') {
        let event: emitter.InnerEvent = {
          eventId: 1,
          priority: emitter.EventPriority.IMMEDIATE,
        };

        let eventData: emitter.EventData = {
          data: {
            state: pe.id,
          },
        };
        // Send an event with eventId 1 and the event content is eventData
        emitter.emit(event, eventData);
      }
    });
  }

  build() {
    Column() {
      TextReaderIcon({ readState: this.readState })
        .margin({ right: 20 })
        .width(32)
        .height(32)
        .onClick(async () => {
          try {
            this.setActionListener();
            if (this.readInfoList !== undefined) {
              await TextReader.start(this.readInfoList, this.readInfo?.id);
            }
          } catch (err) {
            console.error(`TextReader failed to start. Code: ${err.code}, message: ${err.message}`);
          }
        })
    }
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .alignItems(HorizontalAlign.End)
  }
}


