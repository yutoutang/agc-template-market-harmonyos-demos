import { EditPersonalInfo } from '../components/EditPersonalEntry'
import { PersonalInfo } from '../types/PersonalInfo'

@Entry
@ComponentV2
struct Sample1 {
  @Local showSheet: boolean = false;

  build() {
    NavDestination() {
      Column() {
        Button('编辑个人信息')
          .onClick(() => {
            this.showSheet = true;
          })
          .bindSheet($$this.showSheet, this.fillInfoSheet(), {
            showClose: false,
            backgroundColor: $r('sys.color.background_secondary'),
            height: 560,
          })
      }
    }
    .hideTitleBar(true)
    .padding(16)
  }

  @Builder
  fillInfoSheet() {
    Column() {
      EditPersonalInfo({
        btnLabel: '确定',
        themeColor: $r('sys.color.brand'),
        confirm: (value: PersonalInfo) => {
          this.getUIContext().getPromptAction().showToast({ message: '提交成功' });
          this.showSheet = false;
        },
        close: () => {
          this.showSheet = false;
        },
      })
    }
  }
}