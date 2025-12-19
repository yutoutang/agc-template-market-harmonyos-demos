import { CommonUtil } from '@ohos_agcit/postpartum_care_center_utils';
import { promptAction } from '@kit.ArkUI';
import { MainEntryVM } from '@ohos_agcit/postpartum_care_center_uicomponents';

@Builder
export function FeedbackPageBuilder() {
  FeedbackPage();
}

@ComponentV2
export struct FeedbackPage {
  vm: MainEntryVM = MainEntryVM.instance;
  uiContext: UIContext = this.getUIContext() as UIContext;
  @Local feedbackContent: string = '';
  @Local phone: string = '';

  build() {
    NavDestination() {
      Column() {
        Column() {
          Row() {
            Text($r('app.string.booking_must'))
              .fontSize($r('app.string.font_size_12'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Regular)
              .fontColor('rgba(219,107,66,1.00)')
              .height(22)
              .width(6);
            Text($r('app.string.feedback_content_desc'))
              .fontSize($r('app.string.font_size_12'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Regular)
              .fontColor('rgba(0,0,0,0.60)');
          }
          .width('100%')
          .margin({ bottom: $r('app.string.margin_xs') });

          TextArea({
            placeholder: $r('app.string.feedback_content_guide'),
          })
            .fontSize($r('app.string.font_size_14'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .fontColor('rgba(0,0,0,0.90)')
            .placeholderColor($r('sys.color.font_secondary'))
            .placeholderFont({
              size: $r('app.string.font_size_14'),
              family: 'HarmonyHeiTi',
              weight: FontWeight.Regular,
            })
            .backgroundColor('rgba(0,0,0,0.05)')
            .padding($r('app.string.padding_12'))
            .onChange((value: string) => {
              this.feedbackContent = value;
            })
            .height(168)
            .margin({ bottom: $r('app.string.margin_ms') });

          Row() {
            Text()
              .height(22)
              .width(6);
            Text($r('app.string.booking_telephone'))
              .fontSize($r('app.string.font_size_12'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Regular)
              .fontColor('rgba(0,0,0,0.60)');
          }
          .width('100%');

          TextInput({
            placeholder: '请输入（选填）',
          })
            .fontSize($r('sys.float.Body_L'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .fontColor('rgba(0,0,0,0.90)')
            .placeholderColor($r('sys.color.font_secondary'))
            .placeholderFont({
              size: $r('sys.float.Body_L'),
              family: 'HarmonyHeiTi',
              weight: FontWeight.Regular,
            })
            .backgroundColor('#F1F3F5')
            .padding({
              left: $r('app.string.padding_6'),
              top: $r('app.string.padding_14'),
              bottom: $r('app.string.padding_13'),
            })
            .onChange((value: string) => {
              this.phone = value;
            });

          Divider()
            .padding({ left: $r('app.string.padding_6'), right: $r('app.string.padding_6') })
            .color($r('sys.color.comp_divider'))
            .strokeWidth('1px');
        }
        .padding($r('app.string.padding_3'));

        Button({ type: ButtonType.Normal, stateEffect: true }) {
          Text($r('app.string.submit_immediately'))
            .fontSize($r('sys.float.Body_L'))// 设置字号为16
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF');
        }
        .backgroundColor('#333333')
        .padding({
          top: $r('app.string.padding_10'),
          bottom: $r('app.string.padding_9'),
        }) // 设置文字内边距
        .borderRadius($r('sys.float.corner_radius_level10'))
        .width('100%')
        .margin({ top: $r('app.string.margin_xl') })
        .onClick(() => {
          if (!CommonUtil.isStringValid(this.feedbackContent)) {
            this.uiContext.getPromptAction().showToast({ message: '请输入反馈内容', alignment: Alignment.Center });
            return;
          }
          this.vm.navStack.pushPathByName('SubmitSuccessPage', null);
          // 意见反馈处理逻辑请您完善
          // promptAction.showToast({ message: '感谢您的反馈', alignment: Alignment.Center  });
        });
      }
      .height('100%')
      .padding({
        top: $r('app.string.padding_8'),
        bottom: $r('app.string.padding_8'),
        right: $r('app.string.padding_16'),
        left: $r('app.string.padding_16'),
      })
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .title('意见反馈')
    .backgroundColor('#F1F3F5');
  }
}