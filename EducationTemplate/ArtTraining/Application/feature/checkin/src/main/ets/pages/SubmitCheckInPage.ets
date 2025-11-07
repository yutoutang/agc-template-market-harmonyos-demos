import { CommonHeader } from 'componentlib';
import { SubmitCheckInVM } from '../viewmodels/SubmitCheckInVM';
import { CheckInView } from 'module_check_in';

@Builder
export function submitCheckInPageBuilder() {
  SubmitCheckInPage();
}

@ComponentV2
export struct SubmitCheckInPage {
  vm: SubmitCheckInVM = SubmitCheckInVM.instance;

  build() {
    NavDestination() {
      CheckInView({
        handleSubmit: (data) => {
          this.vm.submitRecord(data);
        },
      }) {
        this.taskDetailBuilder();
      };
    }
    .title('提交打卡', { backgroundColor: $r('app.color.system_color_background_white') })
    .onReady(() => {
      this.vm.initRecord();
    })
    .onBackPressed(() => {
      this.vm.clearData();
      return false;
    });
  }

  @Builder
  taskDetailBuilder() {
    if (this.vm.taskItem) {
      Text(this.vm.taskItem.taskName)
        .fontColor($r('app.color.font_color_level1'))
        .fontSize($r('app.string.font_size_12'))
        .margin({ bottom: $r('app.string.margin_xs') })
        .fontWeight(FontWeight.Medium);
      Text(this.vm.taskItem.taskDetail).cardContentStyle();
    }
    if (this.vm.activity) {
      Text(this.vm.activity.summary).cardContentStyle();
      if (this.vm.activity.requirement.textSwitch) {
        Text(`文字要求: 不少于${this.vm.activity.requirement.textMinLimit}字`).cardContentStyle();
      }
      if (this.vm.activity.requirement.pictureSwitch) {
        Text(`图片要求: 不少于${this.vm.activity.requirement.pictureMinLimit}张`).cardContentStyle();
      }
      if (this.vm.activity.requirement.videoSwitch) {
        Text('视频要求: 至少上传1个打卡视频').cardContentStyle();
      }
      if (this.vm.activity.requirement.audioSwitch) {
        Text('音频要求: 至少上传1个打卡音频').cardContentStyle();
      }
    }
  }
}


@Extend(Text)
function cardContentStyle() {
  .fontSize($r('app.string.font_size_12'))
  .margin({ bottom: $r('app.string.margin_xs') })
  .fontColor($r('app.color.font_color_level2'));
}