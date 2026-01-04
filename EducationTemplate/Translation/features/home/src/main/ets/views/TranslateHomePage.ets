// 翻译首页
import { LanguageType } from 'choose_language';
import { TranslateHomeViewModel } from '../viewmodel/TranslateHomeViewModel';
import { phoneRouterControl } from 'oh_router';
import { BarVM, BreakpointModel, RouterMap, UserInfo } from 'common';
import { TranslateDialogPageBuilder } from './TranslateDialogPage';
import { CameraTranslatePageBuilder } from './CameraTranslatePage';
import { DocumentTranslatePageBuilder } from './DocumentTranslatePage';
import { TranslateHomeFunctionCards } from '../comp/TranslateHomeFunctionCards';
import { CameraTranslateSourceSheet } from '../comp/CameraTranslateSourceSheet';
import { TranslateLanguagePickerSheet } from '../comp/TranslateLanguagePickerSheet';
import { VoiceTranslateSheet } from '../comp/VoiceTranslateSheet';
import { AppStorageV2, PersistenceV2 } from '@kit.ArkUI';
import { TranslateDetailPageBuilder } from './TranslateDetailPage';
import { VoiceTranslateHelper } from '../model/VoiceTranslateHelper';


@Builder
export function TranslateHomePageBuilder() {
  TranslateHomePage()
}


@ComponentV2
export struct TranslateHomePage {
  vm: TranslateHomeViewModel = TranslateHomeViewModel.instance;
  @Local showCameraSheet: boolean = false;
  @Local showVoiceSheet: boolean = false;
  @Local breakpointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  // 监听VIP状态变化
  @Monitor('userInfo.isVip')
  onVipStatusChange(): void {
    this.vm.languageViewModel.setVipStatus(this.userInfo.isVip);
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      // 渐变背景 - 从淡蓝紫色渐变融入白色背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [
            ['#E6EEFF', 0.0],
            ['#EDE8FA', 0.15],
            ['#FFFFFF', 0.4]
          ]
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])

      // Banner图
      Image($r('app.media.banner'))
        .width('100%')
        .height(280)
        .objectFit(ImageFit.Contain)
        .margin({ top: BarVM.instance.staBarH })

      // 翻译输入容器
      Column() {
        // 语言选择区域
        Row({ space: 2 }) {
          // 源语言
          Text(this.vm.languageViewModel.sourceLanguageDisplay.name)
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)

          // 分隔符
          Text('/')
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))

          // 目标语言
          Text(this.vm.languageViewModel.targetLanguage.name)
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)

          // 下拉按钮
          Image($r('app.media.select'))
            .width(25)
            .height(25)
            .objectFit(ImageFit.Contain)
            .fillColor($r('sys.color.font_tertiary'))
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .clickEffect({ level: ClickEffectLevel.LIGHT })
        .onClick(() => {
          this.vm.openLanguagePicker(LanguageType.TARGET);
        })

        // 跳转按钮区域
        Row() {
          Text('输入要翻译的单词/句子')
            .fontSize(14)
            .fontColor($r('sys.color.font_tertiary'))
            .textAlign(TextAlign.Start)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .layoutWeight(1)
        .clickEffect({ level: ClickEffectLevel.LIGHT })
        .onClick(() => {
          // 点击跳转到翻译对话页面
          phoneRouterControl.jumpPage({
            pageName: RouterMap.TRANSLATE_DIALOG_PAGE,
            builder: wrapBuilder(TranslateDialogPageBuilder)
          });
        })
      }
      .height(95)
      .padding({
        left: 16,
        right: 16,
        top: 16,
        bottom: 16
      })
      .margin({
        left: this.breakpointModel.pagePadding,
        right: this.breakpointModel.pagePadding,
        top: 250 + BarVM.instance.staBarH
      })
      .borderRadius(20)
      .border({
        width: 2,
        color: '#000000'
      })
      .backgroundColor(Color.White)

      Column() {
        // 功能卡片
        TranslateHomeFunctionCards({
          isFoldScreen: this.vm.isFoldScreen,
          breakpointModel: this.breakpointModel,
          onVoiceInputClick: () => {
            this.showVoiceSheet = true;
          },
          onDocumentClick: () => {
            // 跳转到文档翻译页面
            phoneRouterControl.jumpPage({
              pageName: RouterMap.DOCUMENT_TRANSLATE_PAGE,
              builder: wrapBuilder(DocumentTranslatePageBuilder)
            });
          },
          onCameraClick: () => {
            this.showCameraSheet = true;
          }
        })

        Blank()
      }
      .width('100%')
      .margin({ top: 345 + BarVM.instance.staBarH })
      .bindSheet($$this.showVoiceSheet, this.buildVoiceSheet(), {
        height: 350,
        showClose: false,
        dragBar: true,
        blurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
        onDisappear: () => {
          this.showVoiceSheet = false;
        }
      })

      TranslateLanguagePickerSheet({ vm: this.vm })

    }
    .width('100%')
    .height('100%')
    .bindSheet($$this.showCameraSheet, this.buildCameraSheet(), {
      height: 220,
      showClose: false,
      dragBar: true,
      blurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
      onDisappear: () => {
        this.showCameraSheet = false;
      }
    })
    .onAppear(() => {
      // 如果未登录，确保VIP状态为false
      if (!this.userInfo.isLogin && this.userInfo.isVip) {
        this.userInfo.isVip = false;
      }
      this.vm.syncVipStatus();
    })
  }

  @Builder
  buildCameraSheet() {
    CameraTranslateSourceSheet({
      callbacks: {
        onImageSelected: (imageUri: string, source: 'camera' | 'album') => {
          this.showCameraSheet = false;
          const params: Record<string, Object> = {
            'imageUri': imageUri,
            'imageSource': source
          };
          phoneRouterControl.jumpPage({
            pageName: RouterMap.CAMERA_TRANSLATE_PAGE,
            builder: wrapBuilder(CameraTranslatePageBuilder),
            param: params
          });
        },
        onDismiss: () => {
          this.showCameraSheet = false;
        }
      }
    })
  }

  @Builder
  buildVoiceSheet() {
    VoiceTranslateSheet({
      callbacks: {
        onComplete: (text: string, targetLanguageCode: string) => {
          this.showVoiceSheet = false;
          this.handleVoiceInputFinish(text, targetLanguageCode);
        },
        onDismiss: () => {
          this.showVoiceSheet = false;
        }
      }
    })
  }

  private async handleVoiceInputFinish(text: string, targetLangCode: string): Promise<void> {
    const success = await VoiceTranslateHelper.handleVoiceTranslate(text, targetLangCode);
    if (success) {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.TRANSLATE_DETAIL_PAGE,
        builder: wrapBuilder(TranslateDetailPageBuilder)
      });
    }
  }
}
