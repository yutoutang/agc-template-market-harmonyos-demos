import { getMedia, getString } from '@agctemplate/resources'
import { SignIn, SignInClass } from '../model/SignInModel'
import { SevenDaySignInViewModel } from '../viewmodel/SevenDaySignInViewModel'


@ComponentV2
export struct SevenDaySignIn {
  @Consumer('balance') balance: number = 0
  @Consumer('rightCount') rightCount: number = 0
  @Local signInList: SignInClass[] = [
    new SignInClass(35),
    new SignInClass(40),
    new SignInClass(45),
    new SignInClass(50),
    new SignInClass(55),
    new SignInClass(60),
    new SignInClass(65)]
  @Local currentDay: number = 0
  viewModel: SevenDaySignInViewModel = new SevenDaySignInViewModel()

  async aboutToAppear() {
    await this.viewModel.initPreferences()
    this.signInList = await this.viewModel.getSignInInfo()
    this.rightCount = this.viewModel.getRightCount(this.signInList)
    this.currentDay = await this.viewModel.getCurrentDay()
  }

  aboutToDisappear(): void {
    this.viewModel.saveSignInList(this.signInList)
  }

  build() {
    Column() {
      Row() {
        ForEach(this.signInList, (item: SignIn, index: number) => {
          Column() {
            Column() {
              Text(item.coinNumber + '')
                .fontSize(12)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_on_primary'))
                .height(16)
                .margin({
                  top: 22,
                  left: 10,
                  right: 9,
                  bottom: 2
                })
            }
            .width(34)
            .height(40)
            .backgroundImage(item.isClaim ? getMedia('app.media.award_red_envelope_1') :
            getMedia('app.media.award_red_envelope'))
            .backgroundImageSize(ImageSize.FILL)
            .opacity(item.isClaim ? 0.5 : 1)

            Text(`第${index + 1}天`)
              .fontWeight(FontWeight.Regular)
              .fontSize(10)
              .fontColor($r('sys.color.font_primary'))
              .margin({ top: 8 })
          }
        }, (item: SignIn) => { return item.coinNumber.toString() + item.isClaim })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Column() {
        Button(this.signInList[this.currentDay].isClaim ? getString('app.string.checked_in') :
        getString('app.string.check_in'))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#EC6E45')
          .enabled(!this.signInList[this.currentDay].isClaim)
          .height(40)
          .width('100%')
          .margin({ top: 16 })
          .onClick(() => {
            this.handleSignIn()
          })
      }
      .padding({ left: 12, right: 12 })
      .width('100%')
    }
    .margin({ top: 16 })
    .width('100%')
  }

  handleSignIn() {
    this.balance += this.signInList[this.currentDay].coinNumber
    this.signInList[this.currentDay].isClaim = true
    this.rightCount = this.signInList.filter(item => item.isClaim === true).length
    this.signInList = [...this.signInList] // 强制数组引用变化来渲染ui,否则签到红包不会改变
  }
}