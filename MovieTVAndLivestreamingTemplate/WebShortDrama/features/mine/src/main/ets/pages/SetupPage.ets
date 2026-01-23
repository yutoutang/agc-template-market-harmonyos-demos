import { AppStorageV2, promptAction } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { Header } from '../component/Header';
import { UserInfoRow } from '../component/UserInfoRow';
import { getString, NAV_PAGE_NAME } from '@agctemplate/resources';
import { AppStorageKeys, AssociateUtil, ListItemModel, MinePageVM, StatusBarHeight } from '@agctemplate/widgets';
import { appRouter, PreferConstant, PreferenceUtil, SafeJson } from '@agctemplate/utils';
import { TipsDialog } from '@kit.ArkUI';

@ComponentV2
export struct SetUpPage {
  @Local statusBarHeight: StatusBarHeight = AppStorageV2.connect(StatusBarHeight, AppStorageKeys.STATUS_BAR_HEIGHT,
    () => new StatusBarHeight())!;
  @Local vm: MinePageVM = MinePageVM.instance
  @Local isBackgroundPlay: boolean = false
  @Local isShowSpeedSheet: boolean = false
  @Local currentSpeed: string = '1.0x'
  @Local userAvatar: ListItemModel = new ListItemModel(getString('app.string.avatar'))
  @Local userName: ListItemModel = new ListItemModel(getString('app.string.nick_name'))
  @Local userPhone: ListItemModel = new ListItemModel(getString('app.string.phone_number'))
  @Local textValue: string = '';
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: TipsDialog({
      content: '是否退出登录',
      primaryButton: {
        value: '取消',
        action: () => {
          console.info('Callback when the first button is clicked')
        },
      },
      secondaryButton: {
        value: '确定',
        role: ButtonRole.ERROR,
        action: () => {
          console.info('Callback when the second button is clicked')
          this.onAccept()
        }
      }
    })
  });

  async onAccept() {
    console.info('Callback when the second button is clicked');
    await AssociateUtil.disassociateAccount(this.getUIContext().getHostContext()!)
    appRouter.back()

  }

  aboutToDisappear() {
    this.dialogController = null; // 将dialogController置空
  }

  aboutToAppear(): void {
    this.currentSpeed =
      PreferenceUtil.getInstance(this.getUIContext().getHostContext())
        .get(PreferConstant.PLAY_SPEED_SETTINGS, '1.0x') as string
  }

  @Builder
  line() {
    Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider')).padding({ left: 12, right: 12 })
  }

  @Builder
  speedSheet(currentSpeed: string) {
    Column() {
      Speed({ currentSpeed: currentSpeed })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  build() {
    NavDestination() {
      Column() {
        Header({ title: '设置' })
        Column() {
          Column() {
            GenericCard() {
              UserInfoRow({
                leftTitle: getString('app.string.personal_info'), rightOnClick: () => {
                  appRouter.push({
                    builderName: NAV_PAGE_NAME.PersonalInfoPage.name, params: {
                      userAvatar: [
                        this.userAvatar.setContentImage(this.vm.localInfo.avatar ? this.vm.localInfo.avatar :
                          this.vm.userInfo.avatar)
                          .setHandle(() => {
                            appRouter.push({
                              builderName: NAV_PAGE_NAME.ChangePage.name
                            })
                          })],
                      userDetail: [this.userName.setContentText(this.vm.localInfo.nickname ?
                        this.vm.localInfo.nickname :
                        this.vm.userInfo.nickname)
                        .setHandle(() => {
                          appRouter.push({
                            builderName: NAV_PAGE_NAME.ChangePage.name
                          })
                        }),
                        this.userPhone.setContentText(this.vm.userInfo.cellphone).setHandle(() => {
                          this.getUIContext().getPromptAction().showToast({
                            message: getString('app.string.phone_tip'),
                            alignment: Alignment.Center
                          });
                        })]
                    }
                  })
                }
              })
              this.line()
              UserInfoRow({
                leftTitle: getString('app.string.privacy_policy'), rightOnClick: () => {
                  appRouter.push({ builderName: NAV_PAGE_NAME.PrivacyStatementPage.name })
                }
              })
            }

            GenericCard() {
              UserInfoRow({
                leftTitle: getString('app.string.preferences'), rightContent: '', rightOnClick: () => {
                  appRouter.push({ builderName: NAV_PAGE_NAME.MyPreferencesPage.name })
                }
              })
              this.line()
              UserInfoRow({
                leftTitle: getString('app.string.play_speed_settings'),
                rightContent: this.currentSpeed,
                rightOnClick: () => {
                  this.isShowSpeedSheet = !this.isShowSpeedSheet
                }
              })
                .bindSheet($$this.isShowSpeedSheet, this.speedSheet(this.currentSpeed), {
                  height: 400,
                  preferType: SheetType.BOTTOM,
                  title: titleBuilder(getString('app.string.play_speed_settings')),
                  onWillAppear: () => {
                    try {
                      emitter.on('SpeedSelected', (event: emitter.EventData) => {
                        this.currentSpeed = event.data!.speed
                      })
                    }catch (error) {
                      console.error('Failed. Cause:' + SafeJson.ohAegJsonStringify(error));
                    }
                  },
                  onWillDisappear: () => {
                    PreferenceUtil.getInstance(this.getUIContext().getHostContext())
                      .put(PreferConstant.PLAY_SPEED_SETTINGS, this.currentSpeed)
                  }
                })
              this.line()
              UserInfoRow({
                leftTitle: getString('app.string.background_mini_window_playback'),
                isSwitch: true,
                switchButton: (isOn) => {
                  this.isBackgroundPlay = isOn
                  PreferenceUtil.getInstance(this.getUIContext().getHostContext())
                    .put(PreferConstant.BACKGROUND_MINI_WINDOW_PLAYBACK, this.isBackgroundPlay)
                  let event: emitter.InnerEvent = {
                    eventId: 4,
                  }
                  let eventData: emitter.EventData = {
                    data: {
                      content: 'changeBack',
                      id: 4
                    }
                  };
                  try {
                    emitter.emit(event, eventData);
                  }catch (error) {
                    console.error('Failed. Cause:' + SafeJson.ohAegJsonStringify(error));
                  }
                }
              })

            }

            GenericCard() {
              UserInfoRow({
                leftTitle: '关于我们', rightOnClick: () => {
                  appRouter.push({ builderName: NAV_PAGE_NAME.AboutPage.name })
                }
              })
            }
          }
          .width('100%')

          Button('退出登录')
            .borderRadius(20)
            .fontColor($r('sys.color.font_primary'))
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(500)
            .width('100%')
            .constraintSize({
              maxWidth: 448
            })
            .height(40)
            .onClick(() => {
              if (this.dialogController != null) {
                this.dialogController.open();
              }
            })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .layoutWeight(1)
        .width('100%')
        .constraintSize({
          maxWidth: 837
        })
        .padding({
          left: 16,
          right: 16,
        })
        .backgroundColor($r('sys.color.comp_background_gray'))
      }
      .width('100%')
      .height('100%')
    }
    .backgroundColor($r('sys.color.comp_background_gray'))
    .padding({ top: `${this.getUIContext().px2vp(this.statusBarHeight.value)}vp`, bottom: 36 })
    .hideTitleBar(true)
  }
}

@Builder
export function SetUpPageBuilder() {
  SetUpPage()
}

@ComponentV2
export struct GenericCard {
  @BuilderParam content: () => void

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .borderRadius(16)
    .margin({ top: 8, bottom: 4 })
    .padding({ top: 4, bottom: 4 })
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
  }
}

@ComponentV2
struct Speed {
  @Param currentSpeed: string = '1.0x'
  speedList: string[] = ['2.0x', '1.5x', '1.25x', '1.0x', '0.5x']
  @Local index: number = this.speedList.indexOf(this.currentSpeed)

  build() {
    Column() {
      ForEach(this.speedList, (item: string, index: number) => {
        Column() {
          Row() {
            Text(item)
              .fontSize(16)
              .fontWeight(500)
              .fontColor(this.index === index ? '#EE5D1A' : '#e6000000')
          }
          .width('100%')
          .height(48)
          .onClick(() => {
            this.index = index
            this.onSpeedSelected(item)
          })

          Divider()
            .strokeWidth('1px')
            .color($r('sys.color.mask_fourth'))
            .margin({ bottom: 16 })
        }
      }, (item: string) => item)
    }
  }

  onSpeedSelected(speed: string) {
    let eventData: emitter.EventData = {
      data: { speed: speed }
    }
    emitter.emit('SpeedSelected', eventData)
  }
}

@Builder
export function titleBuilder(title: ResourceStr) {
  Row() {
    Text(title)
      .width(256)
      .height(27)
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .fontColor('#e6000000')
      .textAlign(TextAlign.Start)
  }
  .height(56)
  .width(328)
}