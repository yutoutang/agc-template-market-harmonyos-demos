import { getMedia, NAV_PAGE_NAME } from '@agctemplate/resources';
import { appRouter, Logger, WindowManager } from '@agctemplate/utils';
import { PlayController, PlaySession, ProcessBar } from 'video_swiper';
import { BulletSettingItem } from '../models/BulletSettingData';
import { MyStorage, reverseSpeed, speedArr, speeds } from '../models/SpeedData';
import { BulletVM } from '../viewmodels/BulletVM';
import { ShortDramaDetailItemVM } from '../viewmodels/ShortDramaDetailItemVM';
import { BulletLayer } from './BulletLayer';
import { BulletSetting } from './BulletSetting';
import { PlaySetting } from './PlaySetting';
import { Side } from './Side';
import { VideoDesLayer } from './VideoDesLayer';
import { AppStorageV2, ComponentContent, promptAction } from '@kit.ArkUI';
import { AppStorageKeys, BreakPoint, UserInfoModel } from '@agctemplate/widgets';
import { CastingLayer, CastService, CastPicker } from 'module_cast';
import { Params, PromptActionClass } from './PromptActionClass';
import { ProcessController } from 'video_swiper/src/main/ets/view/ProcessController';
import { lockedBuilder, LockedLayer } from './LockedLayer';
import { ShortDramaDetailListVM } from '../viewmodels/ShortDramaDetailListVM';
import { DetailVideoData } from '../models/DetailVideoData';
import { Preferences } from '../viewdata/Preferences'

const TAG = 'DetailMaskLayer'

interface ParamsModel {
  id: string
  curIndex: number
}

interface AspectRatio {
  width: number;
  height: number;
}

interface VideoType {
  short: AspectRatio;
  long: AspectRatio;
}

const videoRatio: VideoType = {
  short: { width: 9, height: 16 } as AspectRatio,
  long: { width: 16, height: 9 } as AspectRatio,
}

@ComponentV2
export struct DetailMaskLayer {
  breakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint())!;
  @Param @Require videoDetailMaskVM: ShortDramaDetailItemVM;
  @Param @Require playControl: PlayController;
  @Param @Require playerSession: PlaySession;
  @Local storage: MyStorage = MyStorage.instance();
  @Local isShowSetSpeed: boolean = false
  @Local isShowPlaySettingSheet: boolean = false
  @Local showControl: boolean = true;
  @Local bulletVM: BulletVM = new BulletVM()
  @Local rowsNum: number = 2;
  @Local notOpacity: number = 80;
  @Local danMuSpeed: string = '适中';
  @Local danMuSize: string = '适中';
  @Local isShowBulletSettingSheet: boolean = false
  @Local isShowBullet: boolean = true
  @Local bonusAgree: boolean = true
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!
  @Local bonus: number = this.userInfo.bonus
  @Local processController: ProcessController | undefined = undefined
  @Local locked: boolean = true
  onSpeedSet: Function = (speed: number) => {
    this.playControl.setSpeed(speed)
  }
  onBulletSet: Function = (isOn: boolean) => {
    this.isShowBullet = isOn
    Preferences.updateData('isShowBullet', isOn)
  }
  onClear: Function = (isOn: boolean) => {
    this.showControl = !isOn
    Preferences.updateData('showControl', isOn)
  }

  @Monitor('isShowBulletSettingSheet')
  resetBulletSetting() {
    if (this.isShowBulletSettingSheet) {
      this.rowsNum = this.bulletVM.storage.setting.get('setting')?.rowsNum!
      this.notOpacity = this.bulletVM.storage.setting.get('setting')?.notOpacity!
      this.danMuSpeed = this.bulletVM.storage.setting.get('setting')?.danMuSpeed!
      this.danMuSize = this.bulletVM.storage.setting.get('setting')?.danMuSize!
    }
  }

  @Monitor('showControl')
  setScreen() {
    WindowManager.setVideoFullScreen(!this.showControl, videoRatio.short.width, videoRatio.short.height)
  }

  @Monitor('bonus')
  bonusChange() {
    this.userInfo.bonus = this.bonus
  }

  recover() {
    WindowManager.setVideoFullScreen(false, videoRatio.short.width, videoRatio.short.height)
  }

  async aboutToAppear() {
    let avPlayer = this.playerSession.getAVPlayer()
    if (avPlayer) {
      this.processController = new ProcessController(avPlayer)
    }
    if (!this.bulletVM.storage.setting.has('setting')) {
      this.bulletVM.storage.setting.set('setting', new BulletSettingItem())
    }
    this.rowsNum = this.bulletVM.storage.setting.get('setting')?.rowsNum!
    this.notOpacity = this.bulletVM.storage.setting.get('setting')?.notOpacity!
    this.danMuSpeed = this.bulletVM.storage.setting.get('setting')?.danMuSpeed!
    this.danMuSize = this.bulletVM.storage.setting.get('setting')?.danMuSize!
    this.playControl.id = this.videoDetailMaskVM.dramaInfo.id
    this.playControl.isVip = this.userInfo.isVip
    if (this.videoDetailMaskVM.isLocked) {
      if (this.userInfo.isVip) {
        this.locked = false
        this.videoDetailMaskVM.isLocked = false
      }
      // if (this.userInfo.bonus > 100 && this.bonusAgree) {
      //   this.userInfo.bonus = this.userInfo.bonus - 100
      //   this.getUIContext().getPromptAction().showToast({ message: '自动解锁成功' })
      //   this.locked = false
      //   this.videoDetailMaskVM.isLocked = false
      // }
    }
    if (this.locked) {
      this.playControl.pause()
    }
  }

  aboutToDisappear(): void {
    WindowManager.setVideoFullScreen(false, videoRatio.short.width, videoRatio.short.height)
  }

  onBack() {
    PromptActionClass.setParam(new Params('是否退出投屏？', [{
      content: '是', action: () => {
        PromptActionClass.closeDialog()
        CastService.getInstance().endCasting()
      }
    }, {
      content: '否', action: () => {
        PromptActionClass.closeDialog()
      }
    }
    ]));
    PromptActionClass.setOptions({ alignment: DialogAlignment.Center, maskColor: $r('sys.color.mask_fourth') });
    PromptActionClass.openDialog()
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      if (CastService.getInstance().castStatusModel.isCasting) {
        this.castControlBuilder()
      } else {
        Stack({ alignContent: Alignment.TopStart }) {
          if (this.videoDetailMaskVM.isLocked) {
            LockedLayer({
              onUnLocked: () => {
                Logger.info(TAG, `onUnlocked index${this.playControl.curentIndex}`)
                this.playControl.play()
                this.locked = false
                this.videoDetailMaskVM.isLocked = false
              }
            })
              .onAppear(() => {
                this.playControl.pause()
              })
          }
          this.headerBuilder()
        }
        .width('100%')
        .height('100%')

        this.bulletBuilder()

        this.sideBuilder()

        // bottom
        Stack({ alignContent: Alignment.Bottom }) {
          Column() {
            this.introductionBuilder()
            Row() {
              VideoDesLayer({
                dramaInfo: this.videoDetailMaskVM.dramaInfo,
                playController: this.playControl
              })
            }
            .width('100%')
            .height(52)
          }
          .width('100%')

          if (!this.showControl) {
            Stack()
              .width('100%')
              .height('100%')
              .onClick(() => {
                this.showControl = true;
              })
          }

        }
      }
    }
    .width('100%')
    .height('100%')
    .onVisibleAreaChange([0], (isExpanding: boolean, currentRatio: number) => {
      if (isExpanding && this.videoDetailMaskVM.isLocked) {
        this.playControl.pause()
      } else if (isExpanding && !this.videoDetailMaskVM.isLocked) {
        this.playControl.play()
      }
    })
  }

  @Builder
  castControlBuilder() {
    Stack({ alignContent: Alignment.Bottom }) {
      CastingLayer({
        title: `第${this.playControl.curentIndex + 1}集`,
        castService: CastService.getInstance(),
        onPlayNext: () => {
          if (this.playControl.curentIndex > 9) {
            this.getUIContext().showAlertDialog({
              title: '提示',
              message: '当前视频解锁后，可投屏观看？',
              autoCancel: true,
              alignment: DialogAlignment.Center,
              buttons: [{
                value: '知道了',
                action: () => {
                  console.info('Callback when the first button is clicked');
                }
              }]
            })
          } else {
            this.playControl.changeIndex(this.playControl.curentIndex + 1);
          }
        },
        onPlayPre: () => {
          if (this.playControl.curentIndex > 0) {
            this.playControl.changeIndex(this.playControl.curentIndex - 1);
          }
        },
        onBack: () => {
          this.onBack();
        }
      })
        .width('100%')
        .height('100%')
        .zIndex(100)
        .padding({ top: 36 });
      VideoDesLayer({
        dramaInfo: this.videoDetailMaskVM.dramaInfo,
        playController: this.playControl,
        isLocked: (index: number): boolean => {
          return this.isLocked(index);
        }
      })
        .width('100%')
        .height(52)
        .zIndex(100);
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  introductionBuilder() {
    Stack({ alignContent: Alignment.Bottom }) {
      Row() {
        Column() {
          Row() {
            Text(this.videoDetailMaskVM.dramaInfo.name)
              .height(21)
              .fontSize(16)
              .fontWeight(500)
              .fontColor('#fff')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.MARQUEE });
            Column() {
              SymbolGlyph($r('sys.symbol.chevron_right'))
                .fontSize(16)
                .fontColor([$r('sys.color.white')])
            }
            .width(16)
            .height(16)
            .justifyContent(FlexAlign.Center)
          }
          .width(252)
          .height(21)
          .onClick(() => {
            WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' });
            this.playControl.pause();
            appRouter.push({
              builderName: NAV_PAGE_NAME.DramaDetailInfoPage.name, params: {
                dramaInfo: this.videoDetailMaskVM.dramaInfo,
                currentIndex: this.playControl.curentIndex,
                changeIndex: (index: number) => {
                  this.playControl.changeIndex(index);
                }
              }
            });
          })

          Text(`第${this.videoDetailMaskVM.currentSerial}集` + ' ' +
          this.videoDetailMaskVM.dramaInfo.description)
            .width(252)
            .height(16)
            .fontSize(12)
            .fontWeight(400)
            .fontColor('rgba(255, 255, 255, 0.6)')
            .maxLines(1)
            .margin({ top: 2 })
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }
        .width(252)
        .height(39);
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Start)
      .padding({ left: 16, right: 16 })
      .visibility(this.showControl ? Visibility.Visible : Visibility.Hidden)
      .animation({ duration: 300, curve: Curve.Smooth });

      if (this.playerSession.avPlayer?.isReady) {
        ProcessBar({ avPlayer: this.playerSession.avPlayer })
          .hitTestBehavior(HitTestMode.Transparent);
      }
    }
  }

  @Builder
  sideBuilder() {
    Side({
      videoDes: this.videoDetailMaskVM,
      playControl: this.playControl
    })
      .margin({ bottom: 126, right: 8 })
      .visibility(this.showControl ? Visibility.Visible : Visibility.Hidden)
      .animation({ duration: 300, curve: Curve.Smooth })
  }

  @Builder
  bulletBuilder() {
    BulletLayer({ bulletVM: this.bulletVM })
      .position({ top: '15%' })
      .visibility(this.isShowBullet ? Visibility.Visible : Visibility.Hidden)
      .animation({ duration: 300, curve: Curve.Smooth })
      .bindSheet($$this.isShowBulletSettingSheet, this.bulletSettingSheet(), {
        height: 372,
        showClose: false,
        preferType: SheetType.CENTER
      })
  }

  @Builder
  headerBuilder() {
    Row() {
      Row() {
        Image(getMedia('app.media.detail_back'))
          .height(40)
          .width(40)
          .onClick(() => {
            this.recover();
            appRouter.back(true, {
              params: {
                id: this.videoDetailMaskVM.dramaInfo.id,
                curIndex: this.playControl.curentIndex
              } as ParamsModel
            });
            return true;
          });
      }
      .height(56)
      .layoutWeight(1);

      Row({ space: 10 }) {
        Row() {
          Image(getMedia('app.media.speed'))
            .width(22)
            .height(22);
          Text(this.storage.selectSpeed)
            .fontSize(16)
            .fontWeight(500)
            .fontColor('#fff')
            .margin({ left: 5 });
        }
        .width(92)
        .height(40)
        .backgroundColor('rgba(0, 0, 0, 0.05)')
        .borderRadius(20)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.isShowSetSpeed = !this.isShowSetSpeed;
        })
        .bindSheet($$this.isShowSetSpeed, this.setSpeedBuilder(), {
          height: 340,
          showClose: false,
          preferType: SheetType.BOTTOM
        });

        CastPicker({ isLocked: this.videoDetailMaskVM.isLocked });

        Image(getMedia('app.media.four'))
          .width(40)
          .height(40)
          .onClick(() => {
            this.isShowPlaySettingSheet = !this.isShowPlaySettingSheet;
          })
          .bindSheet($$this.isShowPlaySettingSheet, this.playSettingSheetBuilder(), {
            height: 352,
            showClose: false,
            preferType: SheetType.CENTER,
          });
      }
      .height(56);
    }
    .height(56)
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16, top: 64 })
  }

  @Builder
  setSpeedBuilder() {
    Column() {
      Row() {
        Text('倍速设置')
          .height(27)
          .fontSize(20)
          .fontWeight(700)
          .fontColor('#000')
        Image(getMedia('app.media.close_btn'))
          .width(40)
          .height(40)
          .borderRadius(20)
          .onClick(() => {
            this.isShowSetSpeed = !this.isShowSetSpeed
          })
      }
      .width(328)
      .height(56)
      .margin({ top: 16 })
      .justifyContent(FlexAlign.SpaceBetween)

      ForEach(
        reverseSpeed,
        (item: string) => {
          Row() {
            Text(item === '1.0x' ? (item + '（默认）') : item)
              .fontSize(16)
              .fontColor(this.storage.selectSpeed === item ? '#EC6E45' : '#000')
            if (this.storage.selectSpeed === item) {
              Column() {
                Image(getMedia('app.media.speed_select'))
                  .width(19.5)
                  .height(12.5)
              }
              .width(24)
              .height(24)
            }
          }
          .width(328)
          .height(48)
          .justifyContent(this.storage.selectSpeed === item ? FlexAlign.SpaceBetween : FlexAlign.Start)
          .onClick(() => {
            this.storage.selectSpeed = item
            this.onSpeedSet(speedArr[speeds.indexOf(item)])
          })
        },
        (speed: string) => speed
      )
    }
    .height(340)
  }

  @Builder
  playSettingSheetBuilder() {
    Column() {
      Row() {
        Image(getMedia('app.media.handle'))
          .width(48)
          .height(4)
          .margin({ top: 8, left: 24 })
          .onClick(() => {
            this.isShowPlaySettingSheet = !this.isShowPlaySettingSheet
          })
      }
      .width(96)
      .height(16)

      Row() {
        Text('播放设置')
          .width(232)
          .height(27)
          .fontSize(20)
          .fontWeight(700)
          .margin({ left: 8, right: 8 })
        Image(getMedia('app.media.chevron_backward'))
          .width(40)
          .height(40)
          .borderRadius(20)
          .onClick(() => {
            this.isShowPlaySettingSheet = !this.isShowPlaySettingSheet
          })
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 8 })

      PlaySetting({
        isShowBullet: this.isShowBullet,
        onSpeedSet: this.onSpeedSet,
        onBulletSet: this.onBulletSet,
        bulletVM: this.bulletVM,
        openBulletSetting: () => {
          this.isShowBulletSettingSheet = !this.isShowBulletSettingSheet
        },
        onClear: this.onClear
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  @Builder
  bulletSettingSheet() {
    Column() {
      Row() {
        Image(getMedia('app.media.handle'))
          .width(48)
          .height(4)
          .margin({ top: 8, left: 24 })
          .onClick(() => {
            this.isShowBulletSettingSheet = !this.isShowBulletSettingSheet
          })
      }
      .width(96)
      .height(16)

      Row() {
        Image(getMedia('app.media.arrow_back'))
          .width(40)
          .height(40)
          .borderRadius(20)
          .onClick(() => {
            this.isShowBulletSettingSheet = !this.isShowBulletSettingSheet
          })
        Text('弹幕设置')
          .width(232)
          .height(27)
          .fontSize(20)
          .fontWeight(700)
          .margin({ left: 8, right: 8 })
        Blank()
        Image(getMedia('app.media.chevron_backward'))
          .width(40)
          .height(40)
          .borderRadius(20)
          .onClick(() => {
            this.bulletVM.bulletComments = []
            this.bulletVM.xTrans = []
            let bulletSettingItem: BulletSettingItem = new BulletSettingItem()
            bulletSettingItem.rowsNum = this.rowsNum
            bulletSettingItem.notOpacity = this.notOpacity
            bulletSettingItem.danMuSpeed = this.danMuSpeed
            bulletSettingItem.danMuSize = this.danMuSize
            this.bulletVM.storage.setting.set('setting', bulletSettingItem)
            this.isShowBulletSettingSheet = !this.isShowBulletSettingSheet
          })
      }
      .width('100%')
      .height(56)
      .margin({ bottom: 16 })

      BulletSetting({
        rowsNum: this.rowsNum,
        notOpacity: this.notOpacity,
        danMuSpeed: this.danMuSpeed,
        danMuSize: this.danMuSize,
        setRowsNum: (set: number) => {
          this.rowsNum = set
        },
        setNotOpacity: (set: number) => {
          this.notOpacity = set
        },
        setDanMuSpeed: (set: string) => {
          this.danMuSpeed = set
        },
        setDanMuSize: (set: string) => {
          this.danMuSize = set
        }
      })
    }
    .borderRadius({ topLeft: 32, topRight: 32 })
    .backgroundColor('#F1F3F5')
    .padding({ left: 16, right: 16 })
  }

  isLocked(index: number): boolean {
    if (this.userInfo.isVip) {
      return false
    }
    if (!(ShortDramaDetailListVM.instance.data.getData(index) as DetailVideoData).videoMask.isLocked) {
      return false
    }
    return true
  }
}