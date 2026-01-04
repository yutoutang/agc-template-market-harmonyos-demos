import { IMenu, menuList, MenuType } from '../common/Constant';
import { FloatText } from '../models/FloatText';
import { SoundPoolUtil } from '../util/SoundPoolUtil';


@ObservedV2
export class DecompressionToolPageVM {
  @Trace context: Context | undefined
  @Trace floatTexts: FloatText[] = []
  @Trace totalNumber: number = 0
  @Trace translateOptions: TranslateOptions = { y: 0 }
  @Trace iconScaleOptions: ScaleOptions = { x: 1, y: 1 }
  @Trace timers: number[] = []
  @Trace autoTimer: number = 0
  @Trace isShowMenu: boolean = false
  @Trace isShowNumber: boolean = true
  @Trace isAuto: boolean = false
  @Trace statusBarContentColor: string = ''
  private soundPoolUtil: SoundPoolUtil = SoundPoolUtil.getInstance()
  private static _instance: DecompressionToolPageVM;

  public static get instance() {
    if (!DecompressionToolPageVM._instance) {
      DecompressionToolPageVM._instance = new DecompressionToolPageVM();
    }
    return DecompressionToolPageVM._instance;
  }

  async init() {
    await this.soundPoolUtil.init()
  }

  clear() {
    clearInterval(this.autoTimer)
    this.clearAllTimeouts(this.timers)
    menuList[0].label = '自动'
    menuList[1].label = '隐藏次数'
    menuList[2].label = '次数清零'
    this.floatTexts = []
    this.totalNumber = 0
    this.isShowNumber = true
    this.isAuto = false
    this.translateOptions = { y: 0 }
    this.iconScaleOptions = { x: 1, y: 1 }
  }

  clearAllTimeouts(timers: number[]) {
    timers?.forEach(timeoutId => {
      clearTimeout(timeoutId) // 按照定时器ID循环清除定时器
    });
    this.timers = []; // 初始化数组
  }

  async playSound() {
    const audio = 'muyu_audio.mp3'
    const audioUri = this.context?.resourceDir + '/' + audio
    SoundPoolUtil.playSound(audioUri, 1.0, this.soundPoolUtil)
  }

  knock() {
    this.createFloatingText()
    this.totalNumber++;
    this.iconScaleOptions = { x: 0.9, y: 0.9 }
    this.translateOptions = { y: 5 }
    const timer = setTimeout(() => {
      this.iconScaleOptions = { x: 1, y: 1 }
      this.translateOptions = { y: 0 }
    }, 50);

    this.timers.push(timer)
  }

  // 创建浮动文字
  createFloatingText() {
    this.floatTexts.push(new FloatText())
    const index = this.floatTexts.length - 1

    const timer1 = setTimeout(() => {
      if (this.floatTexts.length > 0) {
        this.floatTexts[index].translateOptions = { y: -50, x: -22 }
        this.floatTexts[index].fontSize = 18
        this.floatTexts[index].fontColor = $r('sys.color.font_on_secondary')
      }
    }, 50);

    const timer2 = setTimeout(() => {
      if (this.floatTexts.length > 0) {
        this.floatTexts[index].translateOptions = { y: -50, x: 0 }
        this.floatTexts[index].fontSize = 14
        this.floatTexts[index].fontColor = $r('sys.color.font_on_tertiary')
      }
    }, 250);

    const timer3 = setTimeout(() => {
      if (this.floatTexts.length > 0) {
        this.floatTexts[index].opacity = 0
        this.floatTexts[index].isShow = false
      }
      clearTimeout(timer1)
      clearTimeout(timer2)
    }, 1000)
    this.timers.push(timer3)
  }

  change(value: IMenu) {
    switch (value.type) {
      case MenuType.AUTOMATIC:
        if (this.isAuto) {
          value.label = '自动'
        } else {
          value.label = '手动'
        }
        this.isAuto = !this.isAuto
        if (this.isAuto) {
          this.autoTimer = setInterval(() => {
            this.knock()
          }, 1000)
        } else {
          clearInterval(this.autoTimer)
        }
        break
      case MenuType.HIDE:
        if (this.isShowNumber) {
          value.label = '显示次数'
        } else {
          value.label = '隐藏次数'
        }
        this.isShowNumber = !this.isShowNumber
        break
      case MenuType.CLEAR:
        this.totalNumber = 0
        break
    }
    this.isShowMenu = false
  }
}
