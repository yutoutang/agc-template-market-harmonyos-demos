import { emitter } from '@kit.BasicServicesKit';
import { CommonConstants, LinearColumnModifier, RouterMap, RouterUtils } from 'lib_common';
import { PreferenceUtil, SportServiceApi } from 'lib_sport_api';
import { NavHeaderBar } from 'lib_widget';
import { WalkType } from '../types/Types';
import { SportViewModel } from '../viewmodels/SportVM';
import { MotionType } from 'module_running';
import { Logger } from 'ui_base';

@Builder
export function ApplyLocationRightsBuilder() {
  ApplyLocationRights()
}

@ComponentV2
export struct ApplyLocationRights {
  @Local modifier: LinearColumnModifier = new LinearColumnModifier($r('app.color.home_linear'));
  @Local mapImage: ResourceStr = $r('app.media.home_map_img')
  @Local showCustom: boolean = false;
  @Param vm: SportViewModel = new SportViewModel()
  @Local currentIndex: number = 1
  @Local currentWalkType: number = 0
  @Local motionType: MotionType = MotionType.target
  params?: ESObject

  aboutToAppear(): void {
    this.params = AppStorage.get('applyLocationRightsParams') as ESObject
    this.currentWalkType = this.params.motionTypeIndex
  }

  build() {
    NavDestination() {
      Column() {
        NavHeaderBar({
          title: $r('app.string.location_rights'),
          bgColor: '#ffffff',
        })

        Column() {

          Row({ space: 2 }) {
            ForEach(this.vm.walkTypeList[this.currentIndex - 1], (walkItem: WalkType, index) => {
              Text(walkItem.name)
                .borderRadius(CommonConstants.RADIUS_XL)
                .padding({
                  left: 16,
                  right: 16,
                  top: 5,
                  bottom: 5
                })
                .fontColor('#333')
                .fontSize(11)
                .lineHeight(13)
                .opacity(walkItem.itemIndex === this.currentWalkType ? 1 : 0.6)
                .backgroundColor(this.currentWalkType === walkItem.itemIndex ? '#fff' : '#7dffffff')
                .onClick(() => {
                  this.currentWalkType = index
                  this.motionType =
                    index === 0 ? MotionType.target : index === 1 ? MotionType.isFreedom : MotionType.walkDog

                })
            }, (item: WalkType, index: number) => item.name)
          }
          .padding(3)
          .backgroundColor('#7dffffff')
          .border({ width: 1, color: '#f4f4f4', radius: 25 })
          .margin({ top: 26, bottom: 188 })

          Column({ space: 8 }) {
            Row() {
              Text($r('app.string.open_location_rights'))
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
              Image($r('app.media.arrow_right_black'))
                .size({ width: 40, height: 40 })
            }.width('100%').justifyContent(FlexAlign.Center)
            .bindSheet($$this.showCustom, this.applyLocationSheet(), {
              height: 476,
              showClose: false,
              dragBar: true,
              preferType: SheetType.CENTER
            })

            Row() {
              Text($r('app.string.visit_your_location_infomation'))
                .fontColor($r('app.color.color_666666'))
                .textAlign(TextAlign.Center)
                .lineHeight(18)
            }.width('86%')
          }
          .radialGradient({
            center: ['50%', '50%'],
            radius: 60,
            repeating: false,
            colors: [['#FFFFFF', 0],
              ['#00ffffff', 1]] // 数组末尾元素占比小于1时满足重复着色效果
          })
          .padding({ top: 82, bottom: 128 })
          .width(CommonConstants.FULL_PERCENT)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.showCustom = true
          })
        }
        .layoutWeight(1)
        .backgroundImage($r('app.media.location_map'))
        .backgroundImageSize({ width: CommonConstants.FULL_PERCENT, height: CommonConstants.FULL_PERCENT })
        .alignItems(HorizontalAlign.Center)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .backgroundColor('#F1F3F5')
      .attributeModifier(this.modifier)
    }
    .onHidden(() => {
      this.showCustom = false
    })
    .onBackPressed(() => {
      try {
        emitter.emit('SportPlateMotionTypeIndexEvent', { data: { 'index': this.currentWalkType } })
      } catch (error) {
        Logger.error('SportPlateMotionTypeIndexEvent error')
      }
      return false;
    })
    .hideTitleBar(true)
  }

  @Builder
  applyLocationSheet() {
    Column() {
      Image($r('app.media.location_logo'))
        .size({ width: 152, height: 152 })
        .margin({ top: 75 })
      Column({ space: 8 }) {
        Text($r('app.string.begin_set'))
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 26 })
        Text($r('app.string.require_open_location_service'))
          .fontSize(18)
          .fontColor($r('app.color.color_999999'))
          .textAlign(TextAlign.Center)
          .lineHeight(20)
      }
      .width(CommonConstants.PERCENT_90)

      Text($r('app.string.open_service'))
        .width(CommonConstants.PERCENT_90)
        .height($r('app.float.vp_40'))
        .textAlign(TextAlign.Center)
        .fontColor(Color.White)
        .borderRadius(CommonConstants.NUMBER_20)
        .backgroundColor($r('app.color.FC7A17'))
        .margin({ top: CommonConstants.MARGIN_XXXXXL })
        .onClick(async () => {
          let checkPermission = await LinearColumnModifier.checkPermissions(LinearColumnModifier.permissions)
          PreferenceUtil.getInstance().put(PreferenceUtil.OPEN_SPORT_PERMISSION, checkPermission)
          try {
            emitter.emit('checkPermissionEvent')
          } catch (e) {
            Logger.error('checkPermissionEvent error')
          }
          if (checkPermission) {
            LinearColumnModifier.toSystemSetting()
          } else {
            if (this.params) {
              if (this.params.type === '1') {
                // 开启权限类型，开启直接返回
                RouterUtils.pop()
              }
              if (this.params.type === '2') {
                // 开始运动类型
                RouterUtils.pushPathByName(RouterMap.REAL_TIME_MOTION_PAGE,
                  {
                    'sportType': this.params.sportType,
                    'target': this.params.target,
                    'params': this.params.params,
                    'motionType': this.params.motionType
                  } as ESObject, (value: PopInfo) => {
                    SportServiceApi.saveTodaySportItem(value.result as ESObject)
                  })
              }
            }
          }
        })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }
}