/*
 *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  Licensed under the Apache License, Version 2.0 (the 'License');
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an 'AS IS' BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

import { display, window } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import {
  BaseDanmaku,
  BaseDanmakuParser,
  DanmakuContext,
  DanmakuTimer,
  DanmakuViewV2,
  DANMAKU_STYLE_STROKEN,
  JSONSource,
  SpannedCacheStuffer,
  Callback,
  IDanmakuView,
  IDanmakus,
  OnDanmakuClickListener,
  Proxy
} from '@ohos/danmakuflamemaster';
import { GlobalContext as GlobalContextDanmaku } from '@ohos/danmakuflamemaster';
import { BottomComponent } from '../components/BottomComponent';
import { MoreSetControl } from '../components/MoreSetControl';
import { TopComponent } from '../components/TopComponent';
import { BaseChatMessage } from '../models/BaseChatMesage';
import { PipManager } from '../tools/PipManager';
import { normalChatViewBuilder } from '../view/NormalChatView';
import { ChatViewVM } from '../viewModels/ChatViewVM';
import { LiveStreamingVM } from '../viewModels/LiveStreamingVM';
import { sourceData } from '../models/DanmakuData';
import { DanmakuParser } from '../models/DanmakuParser';

let changeWidth: number = 0;
let changeHeight: number = 0;

@ComponentV2
export struct LiveStreaming {
  @Param fullScreen: (isFullScreen: boolean) => void = () => {
  };
  @Param onSubmit: (content: string) => void = () => {
  };
  // 点击输入文本事件
  @Param inputEvent: () => void = () => {
  };
  // 下载事件
  @Param downEvent: () => void = () => {
  };
  // 分享事件
  @Param shareEvent: () => void = () => {
  };
  @Local vm: ChatViewVM = ChatViewVM.instance;
  @Local liveVM: LiveStreamingVM = LiveStreamingVM.instance;
  @Local model: DanmakuViewV2.Model = new DanmakuViewV2.Model();
  @Local isFullScreen: boolean = false;
  @Local isShowMore: boolean = false;
  @Local isLock: boolean = false;
  // 清屏
  @Local isCleanScreen: boolean = false;
  @Local currentTime: string = '';
  @Local windowStatusType: number = 0;
  // 控制面板
  @Local isShowControl: boolean = true;
  @Local componentHeight: string = '100%';
  @Local componentWidth: string = '100%';
  private mContext: DanmakuContext | ESObject;
  private mParser: BaseDanmakuParser | ESObject;
  private mCacheStufferAdapter: Proxy = new Pro();
  private pageSize: window.Size = {
    width: display.getDefaultDisplaySync().width,
    height: display.getDefaultDisplaySync().height
  };
  private scroller: Scroller = new Scroller();
  private timer: number = -1;
  private liveTimer: number = -1;
  private showControlTimer: number = -1;
  private surfaceId: string = '';
  private keyboardHeight: number = 0;
  curFoldStatus: display.FoldStatus = display.FoldStatus.FOLD_STATUS_UNKNOWN;

  @Builder
  xComponentView() {
    Column() {
      XComponent({
        type: XComponentType.SURFACE,
        controller: PipManager.getInstance().getXComponentController()
      })
        .id('XComponent001')
        .layoutWeight(1)
        .onLoad(() => {
          this.surfaceId = PipManager.getInstance().getXComponentController().getXComponentSurfaceId();
          // 将surfaceId设置给媒体源
          PipManager.getInstance().getXComponentController().onSurfaceCreated(this.surfaceId);
          PipManager.getInstance().player.init(this.liveVM.streamUrl);
        });
    }
    .alignSelf(ItemAlign.Center)
    .align(Alignment.Center)
    .width(this.componentWidth)
    .height(this.componentHeight);
  }

  @Builder
  playerBuilder() {
    Row() {
      Stack({ alignContent: Alignment.Center }) {
        this.xComponentView();
        Column() {
          DanmakuViewV2({ model: this.model!! }).backgroundColor(Color.Transparent)
            .padding({ top: 10 });
        }
        .width('100%')
        .height('100%');

        if (this.isShowControl) {
          this.screenControl();
        }
        if (this.isFullScreen) {
          this.streamControl();
          if (this.isShowMore) {
            MoreSetControl({
              resolutionEvent: (resolution: string) => {
                this.liveVM.resolution = resolution;
                this.getUIContext().getPromptAction().showToast({ message: `已切换${resolution}` });
              },
              reportEvent: (reasons: string[], reason: string) => {
                this.isShowMore = false;
                this.getUIContext().getPromptAction().showToast({ message: '举报成功' });
              },
              pipWindowEvent: () => {
                this.isShowMore = false;
                this.setFullScreen(false);
                PipManager.getInstance().startPip();
              },
              shareEvent: () => {
                this.isShowMore = false;
                this.setFullScreen(false);
                this.shareEvent();
              }
            });
          }
        }
      }
      .width('100%')
      .height('100%')
      .onAreaChange((oldValue: Area, newValue: Area) => {
        if (newValue.width !== oldValue.width || newValue.height !== oldValue.height) {
          changeWidth = newValue.width as number;
          changeHeight = newValue.height as number;
          this.model.setWidth(this.getUIContext().vp2px(changeWidth));
          this.model.setHeight(this.getUIContext().vp2px(changeHeight));
          this.model.show();
        }
      })
      .onClick(() => {
        this.isShowMore = false;
        this.isShowControl = true;
        this.resetControlTimer();
      });
    }
    .width('100%')
    .height(this.componentHeight);
  }

  @Builder
  streamControl() {
    Column() {
      TopComponent({
        isLock: this.isLock,
        currentTime: this.currentTime,
        backClick: () => {
          this.isLock = false;
          this.setFullScreen(false);
        }
      })
        .width('100%')
        .height(56);
      Image(this.isLock ? $r('app.media.icon_lock_close_fill') :
        $r('app.media.icon_lock_open_fill'))
        .id('isPlaying')
        .width(40)
        .height(40)
        .margin(24)
        .onClick(() => {
          this.isLock = !this.isLock;
        });
      BottomComponent({
        isLock: this.isLock,
        isCleanScreen: this.isCleanScreen,
        backClick: () => {
          this.setFullScreen(false);
        },
        commentEvent: () => {
          this.isCleanScreen = !this.isCleanScreen;
          if (this.isCleanScreen) {
            this.model.pause();
            this.model.hide();
          } else {
            this.model.resume();
            this.model.show();
          }
        },
        moreEvent: () => {
          this.isShowMore = true;
        },
        onSubmit: (content: string) => {
          this.vm.onSubmit(content);
        }
      })
        .width('100%')
        .height(56);
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(HorizontalAlign.End)
    .visibility((this.isShowControl) ? Visibility.Visible : Visibility.None);
  }

  @Builder
  screenControl() {
    Column() {
      Image($r('app.media.icon_screen'))
        .interpolation(ImageInterpolation.High)
        .width(40)
        .height(40)
        .margin({ right: 10, bottom: 10 })
        .onClick(() => {
          this.setFullScreen(true);
        });
    }
    .visibility((this.isFullScreen || this.windowStatusType === 5) ? Visibility.None :
      Visibility.Visible)
    .justifyContent(FlexAlign.End)
    .alignItems(HorizontalAlign.End)
    .width('100%')
    .height('100%');
  }

  @Builder
  bottomBuilder() {
    Row() {
      Row() {
        Image(this.liveVM.avatar).width(32).height(32).borderRadius(16)
          .margin({ left: 4, right: 4 });

        Text('聊一聊吧').fontSize($r('sys.float.Subtitle_S')).fontColor($r('sys.color.font_on_primary'))
          .layoutWeight(1)
          .onClick(() => {
            this.inputEvent();
          });
      }
      .alignItems(VerticalAlign.Center)
      .backgroundColor('rgba(46,48,51,1)')
      .borderRadius(28)
      .layoutWeight(1)
      .height(40);

      Row() {
        Image($r('app.media.ic_live_down'))
          .width(25)
          .height(25);
      }
      .width(40)
      .height(40)
      .borderRadius(20)
      .backgroundColor('rgba(46,48,51,1)')
      .margin({ left: 8 })
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.downEvent();
      });
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .height(56)
    .borderRadius(28)
    .padding({ left: 12, right: 12 })
    .visibility(this.isFullScreen ? Visibility.None : Visibility.Visible);
  }

  aboutToDisappear(): void {
    this.vm.dataSource.clear();
    clearInterval(this.timer);
    clearInterval(this.liveTimer);
    clearTimeout(this.showControlTimer);
    this.setFullScreen(false);
    PipManager.getInstance().player.isCreate = true;
    PipManager.getInstance().player.release();
    emitter.off('livePlayer');
    emitter.off('keyboardHeight');
  }

  aboutToAppear(): void {
    PipManager.getInstance().init(getContext(this), this.liveVM.navId);
    this.pushData();
    this.vm.onSubmit = (content: string) => {
      this.vm.dataSource.pushData(new BaseChatMessage(this.liveVM.name, content));
      setTimeout(() => {
        this.scroller.scrollEdge(Edge.Bottom);
      }, 300);
      this.onSubmit(content);
    };
    // 弹幕设置相关回调
    this.vm.onCleanScreen = () => {
      this.isCleanScreen = true;
      this.model.pause();
      this.model.hide();
    };
    this.vm.setRowsNum = (set: number) => {
      let maxLinesPair: Map<number, number> = new Map();
      // 设置最大显示行
      maxLinesPair.set(BaseDanmaku.TYPE_SCROLL_RL, set);
      this.mContext.setMaximumLines(maxLinesPair);
      this.startTime();
    };
    this.vm.setNotOpacity = (set: number) => {
      this.mContext.setDanmakuTransparency(set);
    };
    this.vm.setDanMuSpeed = (set: string) => {
      if (set === '适中') {
        this.mContext.setScrollSpeedFactor(3);
      } else if (set === '慢') {
        this.mContext.setScrollSpeedFactor(4);
      } else {
        this.mContext.setScrollSpeedFactor(2);
      }
    };
    this.vm.setDanMuSize = (set: string) => {
      if (set === '适中') {
        this.mContext.setScaleTextSize(1);
      } else if (set === '小') {
        this.mContext.setScaleTextSize(0.8);
      } else {
        this.mContext.setScaleTextSize(2);
      }
    };
    // 直播功能相关设置
    this.liveTimer = setInterval(() => {
      this.getCurrentTime();
    }, 20000);
    this.currentTime = this.getCurrentTime();
    setTimeout(() => {
      this.initData();
    }, 0);
    // 控制层
    this.resetControlTimer();
    this.pageSize = {
      width: display.getDefaultDisplaySync().width,
      height: display.getDefaultDisplaySync().height
    };
    this.windowListener();
  }

  build() {
    Column() {
      Scroll(this.scroller) {
        Column() {
          this.playerBuilder();
          List({ space: 12, scroller: this.scroller }) {
            LazyForEach(this.vm.dataSource, (item: BaseChatMessage) => {
              ListItem() {
                normalChatViewBuilder(item);
              };
            }, (item: BaseChatMessage, index?: number) => JSON.stringify(item) + index);
          }
          .layoutWeight(1)
          .padding({ left: 12, right: 12, top: 6 })
          .edgeEffect(EdgeEffect.Spring)
          .scrollBar(BarState.Off)
          .nestedScroll({
            scrollForward: NestedScrollMode.SELF_FIRST,
            scrollBackward: NestedScrollMode.SELF_FIRST
          })
          .onAppear(() => {
            this.scroller.scrollEdge(Edge.Bottom);
          })
          .visibility((this.isCleanScreen || this.isFullScreen) ? Visibility.None : Visibility.Visible);

          Blank()
            .layoutWeight(1)
            .visibility((this.isCleanScreen && !this.isFullScreen) ? Visibility.Visible : Visibility.None);
          Row() {
            Text('退出清屏')
              .fontSize($r('sys.float.Body_L'))
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .padding(10)
              .backgroundColor('rgba(0, 0, 0, 0.4)')
              .borderRadius(20)
              .margin(10)
              .onClick(() => {
                this.isCleanScreen = false;
                this.model.resume();
                this.model.show();
              });
          }
          .width('100%')
          .visibility((this.isCleanScreen && !this.isFullScreen) ? Visibility.Visible : Visibility.None)
          .justifyContent(FlexAlign.End)
          .alignItems(VerticalAlign.Bottom);
        }
        .width('100%');
      }
      .align(Alignment.Center)
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(this.isFullScreen ? EdgeEffect.None : EdgeEffect.Spring)
      .layoutWeight(1);

      this.bottomBuilder();
    }
    .layoutWeight(1);
  }

  // 窗口相关监听事件
  windowListener() {
    window.getLastWindow(getContext(this)).then((currentWindow: window.Window) => {
      // 获取窗口属性
      let properties = currentWindow.getWindowProperties();
      let rect = properties.windowRect;
      if (this.getUIContext().px2vp(rect.height) <= 680) {
        this.windowStatusType = 5;
        this.setFullScreen(false);
      }
      currentWindow.on('windowStatusChange', (windowStatusType) => {
        this.windowStatusType = windowStatusType;
        if (windowStatusType === 5) {
          this.setFullScreen(false);
        }
      });
    });
    emitter.on('livePlayer', (event: emitter.EventData) => {
      let isPlaying = event.data!.isPlaying as boolean;
      if (isPlaying) {
        PipManager.getInstance().player.getPlay();
      } else {
        PipManager.getInstance().player.getPause();
      }
    });
    emitter.on('keyboardHeight', (event: emitter.EventData) => {
      let keyboardHeight = event.data!.keyboardHeight as number;
      this.keyboardHeight = keyboardHeight;
      this.resetControlTimer();
    });
    if (display.isFoldable()) {
      display.on('foldStatusChange', async (curFoldStatus: display.FoldStatus) => {
        // 同一个状态重复触发不做处理
        if (this.curFoldStatus === curFoldStatus) {
          return;
        }
        this.curFoldStatus = curFoldStatus;
        this.setComponentHeight();
      });
    }
    this.curFoldStatus = display.getFoldStatus();
    this.setComponentHeight();
  }

  // 全屏/非全屏
  setFullScreen(isFullScreen: boolean) {
    this.isFullScreen = isFullScreen;
    this.setR(this.isFullScreen ? 2 : 1);
    this.fullScreen(this.isFullScreen);
    window.getLastWindow(getContext(this)).then((win: window.Window) => {
      win.setWindowLayoutFullScreen(isFullScreen).then(() => {
        this.setComponentHeight();
      }).catch(() => {
      });
    }).catch(() => {
    });
  }

  // 设置窗口方向
  setR(orientation: number) {
    window.getLastWindow(getContext(this)).then((win) => {
      win.setPreferredOrientation(orientation).then(() => {
      }).catch(() => {
      });
    }).catch(() => {
    });
  }

  initData() {
    GlobalContextDanmaku.getContext().setValue('path', getContext().filesDir);
    let maxLinesPair: Map<number, number> = new Map();
    // 设置最大显示行
    maxLinesPair.set(BaseDanmaku.TYPE_SCROLL_RL, this.vm.rowsNum);

    // 设置是否禁止重叠
    let overlappingEnablePair: Map<number, boolean> = new Map();
    overlappingEnablePair.set(BaseDanmaku.TYPE_SCROLL_RL, true);
    overlappingEnablePair.set(BaseDanmaku.TYPE_FIX_TOP, true);
    this.mContext = DanmakuContext.create();
    this.mContext.setDanmakuStyle(DANMAKU_STYLE_STROKEN, 3)
      .setDuplicateMergingEnabled(false) // 是否启用合并重复弹幕
      .setCacheStuffer(new SpannedCacheStuffer(), this.mCacheStufferAdapter) // 图文混排使用SpannedCacheStuffer
      .setMaximumLines(maxLinesPair)
      .setSpecialDanmakuVisibility(false);
    this.mContext.setOverlapping(overlappingEnablePair);
    // 透明度
    this.mContext.setDanmakuTransparency(this.vm.notOpacity);
    // 速率
    if (this.vm.danMuSpeed === '适中') {
      this.mContext.setScrollSpeedFactor(3);
    } else if (this.vm.danMuSpeed === '慢') {
      this.mContext.setScrollSpeedFactor(5);
    } else {
      this.mContext.setScrollSpeedFactor(2);
    }
    // 字体
    if (this.vm.danMuSize === '适中') {
      this.mContext.setScaleTextSize(1);
    } else if (this.vm.danMuSize === '小') {
      this.mContext.setScaleTextSize(0.8);
    } else {
      this.mContext.setScaleTextSize(2);
    }
    let that = this;
    if (this.model !== null) {
      this.mParser = this.createParser();
      this.model.setCallback(new Call(that));
      this.model.setOnDanmakuClickListener(new OnDanMu(that));
      this.model.prepare(this.mParser, this.mContext);
      this.model.showFPS(false);
    }
    setTimeout(() => {
      this.startTime();
    }, 15000);
  }

  pushData() {
    this.vm.dataSource.pushData(new BaseChatMessage('大蓝', '厉害了，都给我上，赶紧进攻~'));
    this.vm.dataSource.pushData(new BaseChatMessage('大司马', '你咋总是藏着呢，十年磨剑，一剑封喉的节奏'));
    this.vm.dataSource.pushData(new BaseChatMessage('艾力', '牛啊，厉害了我的哥'));
    this.vm.dataSource.pushData(new BaseChatMessage('蓝', '不错啊，值得信赖'));
    this.vm.dataSource.pushData(new BaseChatMessage('剑圣', '完美的一次体验，不错不错下次还来'));
    this.vm.dataSource.pushData(new BaseChatMessage('操作者', '这就是所谓的大乱斗啊,这也太精彩了啊~'));
  }

  startTime() {
    if (this.timer === -1) {
      this.timer = setInterval(() => {
        this.addDanmaku();
      }, 500);
    }
  }

  createParser(): BaseDanmakuParser {
    let parser: BaseDanmakuParser = new DanmakuParser();
    let jsonSource = new JSONSource(sourceData);
    parser.load(jsonSource);
    return parser;
  }

  addDanmaku() {
    let danmaku: BaseDanmaku = this.mContext.mDanmakuFactory.createDanmaku(BaseDanmaku.TYPE_SCROLL_RL);
    danmaku.text = '弹幕大军已进入战场';
    danmaku.textColor = 0xffff0000;
    danmaku.setTime(this.model.getCurrentTime());
    this.model.addDanmaku(danmaku);
  }

  getCurrentTime(): string {
    let timestamp = Date.now();
    let date = new Date(timestamp);
    const hour = ('0' + date.getHours()).slice(-2);
    const min = ('0' + date.getMinutes()).slice(-2);
    return `${hour}:${min}`;
  }

  resetControlTimer() {
    clearTimeout(this.showControlTimer);
    this.showControlTimer = setTimeout(() => {
      if (this.keyboardHeight === 0) {
        this.isShowControl = false;
      }
    }, 5000);
  }

  setComponentHeight() {
    setTimeout(() => {
      let screenWidth = display.getDefaultDisplaySync().width;
      let screenHeight = display.getDefaultDisplaySync().height;
      console.info('screenWidth', screenWidth.toString());
      if (this.curFoldStatus === display.FoldStatus.FOLD_STATUS_FOLDED ||
        this.curFoldStatus === display.FoldStatus.FOLD_STATUS_UNKNOWN) {
        if (this.isFullScreen) {
          let width = (this.getUIContext().px2vp(screenHeight)) * 16 / 9;
          this.componentWidth = width.toString() + 'vp';
          this.componentHeight = '100%';
        } else {
          let height = (this.getUIContext().px2vp(screenWidth)) * 9 / 16;
          this.componentHeight = height.toString() + 'vp';
          this.componentWidth = '100%';
        }
      } else {
        if (this.isFullScreen) {
          let height = (this.getUIContext().px2vp(screenWidth)) * 9 / 16;
          this.componentHeight = height.toString() + 'vp';
          this.componentWidth = '100%';
        } else {
          let height = (this.getUIContext().px2vp(screenWidth)) * 9 / 16;
          this.componentHeight = height.toString() + 'vp';
          this.componentWidth = '100%';
        }
      }
    }, 100);
  }
}

class Call implements Callback {
  private that: ESObject;

  constructor(that: ESObject) {
    this.that = that;
  }

  public updateTimer(timer: DanmakuTimer): void {
  }

  public drawingFinished(): void {
  }

  public danmakuShown(danmaku: BaseDanmaku): void {
  }

  public prepared(): void {
    this.that.model.start();
  }
}

class OnDanMu implements OnDanmakuClickListener {
  private that: ESObject;

  constructor(that: ESObject) {
    this.that = that;
  }

  onDanmakuClick(danmakus: IDanmakus): boolean {
    console.log('DFM onDanmakuClick: danmakus size:' + danmakus.size());
    let latest: BaseDanmaku = danmakus.last();
    if (null !== latest) {
      console.log('DFM onDanmakuClick: text of latest danmaku:' + latest.text);
      return true;
    }
    return false;
  };

  onDanmakuLongClick(danmakus: IDanmakus): boolean {
    return false;
  };

  onViewClick(view: IDanmakuView): boolean {
    return false;
  };
}

class Pro extends Proxy {
  public prepareDrawing(danmaku: BaseDanmaku, fromWorkerThread: boolean): void {
  }

  public releaseResource(danmaku: BaseDanmaku): void {
    // TODO 重要:清理含有ImageSpan的text中的一些占用内存的资源 例如drawable
  }
}
