import { promptAction } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'
import { PreferenceUtils, RouterMap, RouterUtils } from 'lib_common'
import { DrinkWarnParam } from '../models/DrinkModel'
import { TargetReminderAgentHelper } from '../util/TargetReminderAgentHelper'

@ObservedV2
export class DrinkWarnViewModel {
  private static instance: DrinkWarnViewModel;
  @Trace warnTime: DrinkWarnParam[] = []
  @Trace params: DrinkWarnParam = { id: 0, time: '', isOpen: false };
  @Trace promptTime: string = '' // 提醒时间
  @Trace prompt: string = '' // 提醒内容
  private store: PreferenceUtils =
    PreferenceUtils.getInstance(getContext() as common.UIAbilityContext, 'drink_warn_storage')

  public static getInstance(): DrinkWarnViewModel {
    if (!DrinkWarnViewModel.instance) {
      DrinkWarnViewModel.instance = new DrinkWarnViewModel();
    }
    return DrinkWarnViewModel.instance;
  }

  public setWarnTimes() {
    this.store.put('drink_warn_data', this.warnTime)
  }

  public getWarnTimes() {
    this.warnTime = this.store.get('drink_warn_data', []) as DrinkWarnParam[]
    return this.warnTime
  }

  public deleteWarnTime(id: number) {
    this.warnTime = this.warnTime.filter((item: DrinkWarnParam) => item.id !== id)
    this.setWarnTimes()
  }

  public init() {
    this.warnTime = [];
    this.params = { id: 0, time: '', isOpen: false };
    this.promptTime = ''
    this.prompt = ''
  }

  public async sysWarnTimes(): Promise<boolean> {

    if (this.params?.time) {
      if (this.promptTime) {
        const setNewTime = this.warnTime.some((item: DrinkWarnParam) => {
          return item.time === this.promptTime
        })
        this.warnTime.forEach((item: DrinkWarnParam) => {
          if (item.time === this.params.time && !setNewTime) {
            item.time = this.promptTime
            item.prompt = this.prompt ? this.prompt : this.params.prompt
          }
        })
      } else if (this.prompt) {
        this.warnTime.forEach((item: DrinkWarnParam) => {
          if (item.time === this.params.time) {
            item.prompt = this.prompt
          }
        })
      }
      this.setWarnTimes();
      RouterUtils.replacePathByName(RouterMap.DRINK_WARN_PAGE)
      return true
    }

    if (!this.promptTime) {
      promptAction.showToast({ message: '请选择提醒时间' })
      return false
    }
    if (!this.prompt) {
      promptAction.showToast({ message: '请选择提醒内容' })
      return false
    }

    const setNewTime = this.warnTime.some((item: DrinkWarnParam) => {
      return item.time === this.promptTime
    })

    if (!setNewTime) {
      const newItem: DrinkWarnParam = {
        id: Date.now(),
        time: this.promptTime,
        isOpen: true,
        prompt: this.prompt
      };

      await TargetReminderAgentHelper.getInstance().addPushTask(newItem).then((result) => {
        if (result) {
          this.warnTime.push(newItem)
          this.setWarnTimes()
          RouterUtils.replacePathByName(RouterMap.DRINK_WARN_PAGE)
        } else {
          promptAction.showToast({ message: '添加喝水提醒失败' })
        }
      })

    } else {
      RouterUtils.pushPathByName(RouterMap.SET_NEW_TIME_DIALOG)
    }

    this.params = { id: 0, time: '', isOpen: false }
    this.promptTime = ''
    this.prompt = ''
    return true
  }

  public updateByIsOpen(item: DrinkWarnParam) {

    if (item.isOpen) {
      TargetReminderAgentHelper.getInstance().addPushTask(item).then((result) => {
        if (result) {
          this.setWarnTimes()
        } else {
          item.isOpen = !item.isOpen
          this.warnTime = [...this.warnTime]
          promptAction.showToast({ message: '开启喝水提醒失败' })
        }
      })
    } else {
      TargetReminderAgentHelper.getInstance().cancelPushTask(item).then((result) => {
        if (result) {
          this.setWarnTimes()
        } else {
          item.isOpen = !item.isOpen
          this.warnTime = [...this.warnTime]
          promptAction.showToast({ message: '关闭喝水提醒失败' })
        }
      })
    }
  }
}