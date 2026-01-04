import { AppStorageV2, PromptAction } from '@kit.ArkUI';
import { LineCommonConstants } from '../common/LineCommonConstants';
import { LineWindowModel } from '../models/LineWindowModel';
import { LineLogger } from '../common/LineLogger';
import { BusSubwayMap } from '../common/Enums';
import { LineCollectionInnerModel, LineCollectionModel } from '../models/LineCollectionModel';
import { CurrentBusstop, LineDetailModel } from '../models/LineDetailModel';
import { CollectionServiceApi } from '../services/CollectionService';
import { BusSubwaySetting } from '../models/BusSubwaySetting';
import { SettingEnum } from '../common/SettingEnum';
import { CommentEventDispatcher } from '../utils/EventDispatcher';
import { CustomDialogExampleTwo } from './CustomDialog';
import { SingleClickUtil } from '../../utils/SingleClickUtil';

@ComponentV2
export struct BottomTools {
  @Local isShowCollectionSheet: boolean = false
  @Local addTagName: string = ''
  @Local isCollected: boolean = false
  @Param @Require collectionLineTags: string[]
  // 线路ID
  @Param @Require lineId: string
  @Param @Require busSubwayType: string
  @Param setting: BusSubwaySetting = new BusSubwaySetting()
  @Param @Require currentStop: CurrentBusstop
  windowModel: LineWindowModel = AppStorageV2.connect(LineWindowModel, () => new LineWindowModel())!;
  promptAction: PromptAction = this.getUIContext().getPromptAction();
  private addTagDialogComponentId: number = 0;
  private lineCollectionModel: LineCollectionModel =
    AppStorageV2.connect(LineCollectionModel, () => CollectionServiceApi.getLineCollectionList())!;
  // 自定义返回事件
  @Event addCollectionLineTag: (tagName: string) => void = (tagName: string) => {
    LineLogger.info('addCollectionLineTag Event')
  }
  @Event collectLine: (tag: string) => void = (tag: string) => {
    LineLogger.info('collectLine Event')
  }
  @Event opeArrivalReminder: (isArrivalReminder: boolean) => void = (isArrivalReminder: boolean) => {
    LineLogger.info('collectLine Event')
  }
  @Event routeSameStop: (id: string) => void = (id: string) => {
    LineLogger.info('collectLine Event')
  }
  @Event routeSettingPage: () => void = () => {
    LineLogger.info('routeSettingPage Event')
  }
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomDialogExampleTwo({
      dialogTitle: `已设置提前${this.calArrivalReminderDialogTitle()}提醒，是否${this.setting.isArrivalReminder ?
        '关闭' : '开启'}？`,
      routeSettingPage: this.routeSettingPage,
      isArrivalReminder: this.setting.isArrivalReminder,
      opeArrivalReminder: this.opeArrivalReminder,
    })
  })

  aboutToAppear(): void {
    this.isCollected = false
    this.lineCollectionModel.lineCollectionInnerModels.forEach((lineCollectionInnerModel: LineCollectionInnerModel) => {
      lineCollectionInnerModel.lineDetailList.forEach((lineDetailModel: LineDetailModel) => {
        if (lineDetailModel.id === this.lineId) {
          this.isCollected = true;
        }
      })
    })

  }

  @Monitor('lineId')
  lineIdChange(): void {
    this.isCollected = false
    this.lineCollectionModel.lineCollectionInnerModels.forEach((lineCollectionInnerModel: LineCollectionInnerModel) => {
      lineCollectionInnerModel.lineDetailList.forEach((lineDetailModel: LineDetailModel) => {
        if (lineDetailModel.id === this.lineId) {
          this.isCollected = true;
        }
      })
    })

  }

  @Builder
  collectionSheet() {
    Column() {
      ForEach(this.collectionLineTags, (tag: string) => {
        Row() {
          if (tag === '家') {
            Image($r('app.media.collection_home'))
              .width(24)
              .height(24)
          } else if (tag === '公司') {
            Image($r('app.media.collection_company'))
              .width(24)
              .height(24)
          } else {
            Image($r('app.media.collection_other'))
              .width(24)
              .height(24)
          }
          Text(tag).fontColor(16).fontWeight(FontWeight.Medium)
            .margin({ left: 16 })
        }
        .justifyContent(FlexAlign.Start)
        .width(LineCommonConstants.FULL_PERCENT)
        .height(48)
        .onClick(() => {
          // 收藏路线
          this.collectLine(tag)
          this.isShowCollectionSheet = false
          this.isCollected = true
          this.promptAction.showToast({ message: '收藏成功' })
        })
      }, (v: string) => v)

      Row() {
        Image($r('app.media.collection_add'))
          .width(24)
          .height(24)
        Text('添加').fontColor(16).fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
      }
      .justifyContent(FlexAlign.Start)
      .width(LineCommonConstants.FULL_PERCENT)
      .height(48)
      .onClick(() => {
        this.promptAction.openCustomDialog({
          builder: () => {
            this.addTagDialog()
          },
          width: 328,
          height: 192,
          cornerRadius: 32,
          backgroundColor: 'C8FFFFFF'
        }).then((dialogId: number) => {
          this.addTagDialogComponentId = dialogId;
        })
      })
    }
    .padding({ left: 16, right: 16, bottom: this.windowModel.windowBottomPadding })
  }

  @Builder
  addTagDialog() {
    Column() {

      Text('添加标签')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .height(56)
        .lineHeight(24)

      TextInput({ text: $$this.addTagName, placeholder: '请输入标签名称' })
        .margin({ top: 12 })
        .height(48)
        .placeholderColor($r('sys.color.font_secondary'))
        .maxLength(20)
        .backgroundColor($r('sys.color.comp_background_primary'))
        .enterKeyType(EnterKeyType.Done)

      Row() {
        Row() {
          Text('取消')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .opacity(0.6)
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
        .onClick(() => {
          this.addTagName = ''
          this.promptAction.closeCustomDialog(this.addTagDialogComponentId)
        })

        Row() {
          Text('确定')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#0A59F7')
        }
        .justifyContent(FlexAlign.Center)
        .width('50%')
        .onClick(() => {
          if (this.addTagName === '') {
            this.promptAction.showToast({
              message: '请输入标签名称',
              duration: 1000
            })
          } else {
            this.addCollectionLineTag(this.addTagName)
            this.addTagName = ''
            this.promptAction.closeCustomDialog(this.addTagDialogComponentId)
          }
        })
      }
      .width('100%')
      .height(40)
      .margin({ top: 20 })
    }
    .padding({ left: 24, right: 24 })
  }

  build() {
    Row() {
      if (!this.isCollected) {
        Column() {
          Image($r('app.media.collect_star'))
            .width(24)
            .height(24)
          Text('收藏').fontSize(10).margin({ top: 12 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .bindSheet($$this.isShowCollectionSheet, this.collectionSheet(), {
          height: SheetSize.FIT_CONTENT,
          showClose: true,
          title: { title: '收藏线路' },
          preferType: SheetType.CENTER
        })
        .onClick(() => {
          CommentEventDispatcher.dispatchToInterceptLogin((isLogin: boolean) => {
            if (isLogin || isLogin === undefined) {
              this.isShowCollectionSheet = true
            }
          })
        })
      } else {
        Column() {
          Image($r('app.media.collect_star_cancel'))
            .width(24)
            .height(24)
          Text('取消收藏').fontSize(10).margin({ top: 12 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          CommentEventDispatcher.dispatchToInterceptLogin((isLogin: boolean) => {
            if (isLogin || isLogin === undefined) {
              for (let i = this.lineCollectionModel.lineCollectionInnerModels.length - 1; i >= 0; i--) {
                const lineCollectionInnerModel: LineCollectionInnerModel =
                  this.lineCollectionModel.lineCollectionInnerModels[i]

                for (let j = lineCollectionInnerModel.lineDetailList.length - 1; j >= 0; j--) {
                  const lineDetailModel: LineDetailModel = lineCollectionInnerModel.lineDetailList[j]
                  if (lineDetailModel.id === this.lineId) {
                    // 移除这条线路
                    lineCollectionInnerModel.lineDetailList.splice(j, 1)

                    // 无线路，移除标签
                    if (lineCollectionInnerModel.lineDetailList.length === 0) {
                      this.lineCollectionModel.lineCollectionInnerModels.splice(i, 1)
                    }

                    this.isCollected = false
                    this.promptAction.showToast({ message: '取消收藏成功' })

                    // 跳出双层循环
                    i = -1
                    break
                  }
                }
              }
            }
          })
        })
      }

      // 线路站点
      if (this.busSubwayType === BusSubwayMap.BUS_SUBWAY_TYPE_BUS) {
        if (!this.setting.isArrivalReminder) {
          // 显示"到站提醒"（未开启状态，点击可打开）
          Column() {
            Image($r('app.media.arrival_notice_bell'))  // 未开启状态图标
              .width(24)
              .height(24)
            Text('到站提醒').fontSize(10).margin({ top: 12 }) // 未开启文字
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            CommentEventDispatcher.dispatchToInterceptLogin((isLogin: boolean) => {
              if (isLogin || isLogin === undefined) {
                this.dialogController.open()
              }
            })
          })
        } else {
          // 显示"取消到站提醒"（已开启状态，点击可关闭）
          Column() {
            Image($r('app.media.arrival_notice_bell_cancel'))  // 已开启状态图标
              .width(24)
              .height(24)
            Text('取消到站提醒').fontSize(10).margin({ top: 12 }) // 已开启文字
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            CommentEventDispatcher.dispatchToInterceptLogin((isLogin: boolean) => {
              if (isLogin || isLogin === undefined) {
                this.dialogController.open()
              }
            })
          })
        }
      }
      Column() {
        Image($r('app.media.same_stop_line'))
          .width(24)
          .height(24)
        Text('同站线路').fontSize(10).margin({ top: 12 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        SingleClickUtil.throttle(async () => {
          this.routeSameStop(this.currentStop.id!)
        }, 1000, true)

      })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width(LineCommonConstants.FULL_PERCENT)
    .padding({ left: 12, right: 12 })
  }

  private calArrivalReminderDialogTitle(): string {
    // 到站提醒title
    if (this.setting.warnType === SettingEnum.TIME) {
      return this.setting.warnValue + '分钟'
    } else {
      return this.setting.warnValue + '站'
    }
  }
}