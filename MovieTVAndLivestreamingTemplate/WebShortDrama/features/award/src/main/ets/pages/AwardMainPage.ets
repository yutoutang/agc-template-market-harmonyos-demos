import { TYCard } from '../common/TYCard'
import { SevenDaySignIn } from '../components/SevenDaySignIn'
import { LookAD } from '../components/LookAD'
import { Wheel } from '../components/Wheel'
import { TaskCard } from '../common/TaskCard'
import { OnlineCheckIn } from '../components/OnlineCheckIn'
import { getColor, getMedia, getString } from '@agctemplate/resources'
import StrConstants from '../constants/StrConstants'
import { AppStorageKeys, StatusBarHeight, UserInfoModel } from '@agctemplate/widgets'
import { AppStorageV2 } from '@kit.ArkUI'

@ComponentV2
export struct AwardMainPage {
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!
  @Provider('balance') bonus: number = 0
  @Provider('leftCount') leftCount: number = 0
  @Provider('rightCount') rightCount: number = 0
  @Consumer('curTabIndex') currentIndex: number = 0
  @Local isUpdating: boolean = false;

  @Monitor('bonus')
  bonusChange(monitor: IMonitor) {
    const bonusNow = monitor.value(monitor.dirty[0])?.now as number
    const bonusBefore = monitor.value(monitor.dirty[0])?.before as number
    if (bonusNow !== bonusBefore && !this.isUpdating) {
      this.isUpdating = true
      this.userInfo.bonus = bonusNow
      this.isUpdating = false
    }
  }

  @Monitor('userInfo.bonus')
  userInfoBonusChange(monitor: IMonitor) {
    const userInfoBonusNow = monitor.value(monitor.dirty[0])?.now as number;
    const userInfoBonusBefore = monitor.value(monitor.dirty[0])?.before as number;
    if (userInfoBonusNow !== userInfoBonusBefore && !this.isUpdating) {
      this.isUpdating = true
      this.bonus = userInfoBonusNow
      this.isUpdating = false
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Image(getMedia('app.media.award_hb_bg'))
          .width('100%')
          .height(325)

        Column() {
          Row() {
            Text(getString('app.string.reward_center'))
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_on_primary'))
          }
          .width('100%')
          .height(35)
          .margin({ top: 36, bottom: 29 })

          Scroll() {
            Column() {
              Row() {
                Image(getMedia('app.media.award_coin'))
                  .width(16)
                  .aspectRatio(1)

                Text(getString('app.string.point_balance'))
                  .margin({ left: 4 })
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_on_primary'))

                Text(this.bonus + '')
                  .margin({ left: 4, bottom: 4 })
                  .fontSize(24)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_on_primary'))
              }
              .width('100%')
              .height(32)
              .margin({ bottom: 4 })

              Text(getString('app.string.daily_points_limit'))
                .fontColor($r('sys.color.font_on_primary'))
                .fontWeight(FontWeight.Regular)
                .margin({ top: 4 })
                .fontSize(12)

              TYCard({
                isRightCounting: true
              }) {
                SevenDaySignIn()
              }

              TYCard({ isLeftCounting: true, rightTitle: '' }) {
                LookAD()
              }

              TYCard({
                liftTitle: getString('app.string.reward_wheel'),
                rightTitle: getString('app.string.max_points_winnable'),
                bottomPadding: 20,
              }) {
                Wheel()
              }

              TYCard({
                liftTitle: getString('app.string.daily_tasks'),
                rightTitle: getString('app.string.daily_task_update'),
                topPadding: 18,
                bottomPadding: 20,
                bottomMargin: 23
              }) {
                TaskCard({
                  coinIcon: 'app.media.award_coin888',
                  isWatchShows: true,
                  topMargin: 33,
                  bottomMargin: 0
                })
                OnlineCheckIn()
                TaskCard({
                  leftIcon: 'app.media.award_lottery_event',
                  title: StrConstants.LOTTERY_EVENT,
                  topMargin: 24,
                  bottomMargin: 0
                })
                TaskCard({
                  leftIcon: 'app.media.award_treasure_box',
                  title: StrConstants.TREASURE_BOX,
                  topMargin: 32,
                  bottomMargin: 0
                })
                TaskCard({
                  leftIcon: 'app.media.award_share_short_dramas',
                  title: StrConstants.SHARE_SHOW,
                  topMargin: 32,
                  bottomMargin: 0
                })
              }
            }
            .alignItems(HorizontalAlign.Start)
          }
          .edgeEffect(EdgeEffect.Spring)
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
        .width('100%')
        .padding({ right: 16, left: 16 })
      }
      .width('100%')
      .backgroundColor('#F1F3F5')
    }
    .hideTitleBar(true)
    .backgroundColor(getColor('app.color.common_background_color'))
  }

  @Builder
  titleBuilder() {
    Text(getColor('app.string.reward_center'))
      .height('100%')
      .margin({
        left: 16
      })
      .fontSize(24)
      .fontWeight(FontWeight.Bold)
      .fontColor(getColor('app.color.bold_font_color'))
  }
}

@Builder
export function AwardMainPageBuilder(index: number) {
  AwardMainPage()
}