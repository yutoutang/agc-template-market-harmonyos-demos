import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { CollectionLineTagModel, RouterMap, RouterUtils, SettingModel, StopModel, UserInfoModel } from 'lib_common';
import { SearchServiceApi, TagServiceApi } from 'lib_api';
import { StopLineModelConvertUtil } from '../utils/StopLineModelConvertUtil';
import { LoginSheetUtils } from 'lib_account';
import {
  BusSubwaySetting,
  CollectionServiceApi,
  CurrentBusstop,
  CurrentLineDetailModel,
  LineCollectionInnerModel,
  LineCollectionModel,
  LineDetailModel,
  LineDetailView
} from 'module_station_line_detail';

@Builder
export function LineDetailPageBuilder() {
  LineDetailPage()
}

@ComponentV2
struct LineDetailPage {
  @Local lineDetailModel: LineDetailModel = new LineDetailModel()
  @Local setting: BusSubwaySetting = new BusSubwaySetting();
  @Local userInfoModel: UserInfoModel = PersistenceV2.connect(UserInfoModel, () => new UserInfoModel())!;
  @Provider() isLineDetailSheetShow: boolean = true
  private pathStack: NavPathStack = new NavPathStack();
  private collectionLineTagModel: CollectionLineTagModel =
    AppStorageV2.connect(CollectionLineTagModel, () => TagServiceApi.getCollectionLineTags())!;
  private lineCollectionModel: LineCollectionModel =
    AppStorageV2.connect(LineCollectionModel, () => CollectionServiceApi.getLineCollectionList())!;
  private currentLineDetailModel: CurrentLineDetailModel =
    AppStorageV2.connect(CurrentLineDetailModel, () => new CurrentLineDetailModel())!;
  @Local settingInfo: SettingModel = PersistenceV2.connect(SettingModel, () => new SettingModel())!;

  @Monitor('settingInfo.isArrivalReminder','settingInfo.warnType', 'settingInfo.warnValue', 'settingInfo.speedType')
  onChangeSettingInfo() {
    this.setting.warnType = this.settingInfo.warnType
    this.setting.warnValue = this.settingInfo.warnValue
    this.setting.speedType = this.settingInfo.speedType
    this.setting.isArrivalReminder = this.settingInfo.isArrivalReminder
  }

  build() {
    NavDestination() {
      LineDetailView({
        lineDetailModel: this.lineDetailModel,
        setting: this.setting,
        collectionLineTags: this.collectionLineTagModel.tagNames,
        onBack: () => {
          this.pathStack.pop()
        },
        onInterceptLogin: (loginInterceptCb: (isLogin: boolean) => void) => {
          if (!this.userInfoModel.isLogin) {
            LoginSheetUtils.open()
            return
          }
          loginInterceptCb(this.userInfoModel.isLogin)
        },
        addCollectionLineTag: (tagName: string) => {
          this.collectionLineTagModel.tagNames.push(tagName)
        },
        collectLine: (tag: string) => {
          let lineCollectionInnerModel: LineCollectionInnerModel | undefined
          this.lineCollectionModel.lineCollectionInnerModels.forEach(innerModel => {
            if (innerModel.tag === tag) {
              lineCollectionInnerModel = innerModel
              return
            }
          })
          if (lineCollectionInnerModel) {
            lineCollectionInnerModel.lineDetailList.push(this.lineDetailModel)
          } else {
            lineCollectionInnerModel = new LineCollectionInnerModel()
            lineCollectionInnerModel.tag = tag
            lineCollectionInnerModel.lineDetailList.push(this.lineDetailModel)
            this.lineCollectionModel.lineCollectionInnerModels.push(lineCollectionInnerModel)
          }
        },
        opeArrivalReminder: (isArrivalReminder: boolean) => {
          this.settingInfo.isArrivalReminder = isArrivalReminder
          this.setting.isArrivalReminder = isArrivalReminder
        },
        routeSameStop: async (id: string) => {
          const stopModel: StopModel = await SearchServiceApi.searchBusstopById(id)
          if (stopModel) {
            const stopDetailModel = await StopLineModelConvertUtil.genStopDetailModel(stopModel);
            RouterUtils.pushPathByName(RouterMap.STOPDETAIL_PAGE, stopDetailModel);
          }
        },
        routeSettingPage: () => {
          RouterUtils.pushPathByName(RouterMap.SETTING_PAGE)
        },
        switchDirec: async () => {
          {
            const direcLineDetailModel: LineDetailModel = new LineDetailModel();
            if (this.lineDetailModel.direc) {
              const lineModel = await SearchServiceApi.searchBuslineById(this.lineDetailModel.direc)
              if (lineModel) {
                StopLineModelConvertUtil.convertToLineDetailModel(direcLineDetailModel, lineModel);
                if (this.lineDetailModel.currentStop) {
                  const currentStop: CurrentBusstop = new CurrentBusstop()
                  currentStop.id = this.lineDetailModel.currentStop.id
                  currentStop.name = this.lineDetailModel.currentStop.name
                  currentStop.location = this.lineDetailModel.currentStop.location
                  StopLineModelConvertUtil.getBusCarState(direcLineDetailModel, currentStop);
                  direcLineDetailModel.currentStop = currentStop
                  // 计算最近公交离始发站多少站
                  direcLineDetailModel.busstops!.forEach((busstops, index) => {
                    const id = busstops.id
                    if (id === direcLineDetailModel.currentStop!.id!) {
                      direcLineDetailModel.currentStop!.stopOffsetIndex = index
                    }
                  })
                } else {
                  await StopLineModelConvertUtil.calRecentStop(direcLineDetailModel)
                }
              }
            }
            this.lineDetailModel = direcLineDetailModel
          }
        },
      })
    }
    .onReady((context) => {
      this.pathStack = context.pathStack
      this.lineDetailModel = context.pathInfo.param as LineDetailModel
      // 设置
      this.setting.warnType = this.settingInfo.warnType
      this.setting.warnValue = this.settingInfo.warnValue
      this.setting.speedType = this.settingInfo.speedType
      this.setting.isArrivalReminder = this.settingInfo.isArrivalReminder
    })
    .onWillShow(() => {
      this.isLineDetailSheetShow = true
    })
    .onWillHide(() => {
      if (this.currentLineDetailModel.lineDetailList.length > 0) {
        this.currentLineDetailModel.lineDetailList.pop()
      }
      this.isLineDetailSheetShow = false
    })
    .hideTitleBar(true)
  }
}