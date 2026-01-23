import { OnlineInfo, OnlineInfoClass } from '../model/OnlineInfoModel'
import { common } from '@kit.AbilityKit'
import StrConstants from '../constants/StrConstants'
import PreferencesManager from '../utils/PreferencesManager'
import { window } from '@kit.ArkUI'

export class OnlineCheckInViewModel {
  onlineInfoArr: OnlineInfoClass[] = []
  currentTime: Date = new Date()
  startTime: Date = new Date()
  intervalId: number | null = null
  prefsManager: PreferencesManager
  onlineTimeList: OnlineTime[] = []
  windowStage: window.WindowStage = AppStorage.get('windowStage')!

  constructor() {
    this.prefsManager = PreferencesManager.getInstance(this.windowStage.getMainWindowSync()
      .getUIContext()
      .getHostContext() as common.UIAbilityContext)
  }

  async init(callback?: (progressValue: number) => void) {
    this.onlineInfoArr = this.getOnlineInfo()
    await this.initPreferencesAndStartTime()
    const progressValue = this.updateProgressVal()
    if (callback) {
      callback(progressValue)
    }
  }

  getOnlineInfo(): OnlineInfoClass[] {
    return [
      new OnlineInfoClass('app.media.award_coin50', 50, '10分钟', 1),
      new OnlineInfoClass('app.media.award_coin100', 100, '15分钟', 3),
      new OnlineInfoClass('app.media.award_coin150', 150, '20分钟', 5),
      new OnlineInfoClass('app.media.award_coin300', 300, '25分钟', 7)
    ]
  }

  async initPreferencesAndStartTime(): Promise<void> {
    await this.prefsManager.initPreferences(StrConstants.ONLINE_SETTING)
    const currentDate = new Date().toISOString().split('T')[0]
    const lastDate = await this.prefsManager.getData(StrConstants.LAST_SIGN_IN_DATE, '') as string
    if (lastDate !== currentDate) {
      this.prefsManager.putData(StrConstants.ONLINE_TIME, [])
      this.onlineInfoArr.forEach(item => item.isObtained = false)
    }
    this.onlineTimeList = await this.prefsManager.getData(StrConstants.ONLINE_TIME, [])
    this.startTime = new Date()
  }

  startProgressTimer(callback: (progressValue: number) => void) {
    this.stopProgressTimer()
    let progressValue = 0
    this.intervalId = setInterval(() => {
      progressValue = this.updateProgressVal()
      callback(progressValue)
    }, 60 * 1000)
  }

  stopProgressTimer(): void {
    if (this.intervalId) {
      clearInterval(this.intervalId)
      this.intervalId = null
    }
  }

  calculateCumulativeOnlineTime(): number {
    let totalDuration = 0
    this.onlineTimeList.forEach((item) => {
      totalDuration += ((new Date(item.endTime).getTime() - new Date(item.startTime).getTime()) / (1000 * 60))
    })
    return totalDuration
  }

  updateProgressVal() {
    const timeDiffMinutes = (new Date().getTime() - this.startTime.getTime()) / (1000 * 60) +
    this.calculateCumulativeOnlineTime()
    let progressVal = 0
    if (timeDiffMinutes >= 30) {
      this.stopProgressTimer()
      progressVal = 8
    } else {
      progressVal = Math.min(Math.floor(timeDiffMinutes / 2.5) - 3, 8);
    }
    this.changeCanGet(progressVal)
    return progressVal
  }

  changeCanGet(progressVal: number): void {
    this.onlineInfoArr.forEach((item: OnlineInfo) => {
      item.canGet = item.node <= progressVal
    })
  }

  saveOnlineTime(): void {
    const onlineTime: OnlineTime = { startTime: this.startTime, endTime: new Date() }
    this.onlineTimeList.push(onlineTime)
    this.prefsManager.putData(StrConstants.ONLINE_TIME, this.onlineTimeList)
    this.startTime = new Date()
  }
}

interface OnlineTime {
  startTime: Date
  endTime: Date
}