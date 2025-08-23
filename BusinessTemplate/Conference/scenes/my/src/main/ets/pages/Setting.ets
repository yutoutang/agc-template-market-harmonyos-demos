import {
  AvoidRepeatClick,
  BreakpointType,
  cancelAuthorization,
  clearToken,
  FormDataModel,
  logOutCleartokenion,
  MyConfig,
  PreferencesUtil,
  UserInfoDetail,
  WebViewParams,
} from 'commons';
import { formBindingData, formProvider } from '@kit.FormKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';

const domainId: number = 0x0000;
const logTag: string = 'Phone';

@Builder
export function SettingBuilder() {
  Setting();
}

@Component
struct Setting {
  @Consume('pageStack') pageStack: NavPathStack;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm'
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageLink('token') token: string = '';
  @StorageProp('deviceId') deviceId: string = '';
  @StorageLink('isRecommendation') isRecommendation: boolean = true;
  @StorageLink('mobile') mobile: string = '';
  @StorageLink('userInfo') userInfo: UserInfoDetail = new UserInfoDetail();
  @State isNickSheetShow: boolean = false;
  @State nickName: string = '';

  aboutToAppear(): void {
    if (this.userInfo.mobile) {
      this.userInfo.mobile = this.maskPhoneNumber(this.userInfo.mobile as string);
    }
  }

  maskPhoneNumber(phoneNumber: string): string {
    if (phoneNumber.length !== 11) {
      throw new Error('手机号格式不正确');
    }
    return phoneNumber.slice(0, 3) + '****' + phoneNumber.slice(7);
  }

  // Sign out.
  logout() {
    logOutCleartokenion({
      token: this.token,
    }).then(async (res) =>
    {
      try {
        await cancelAuthorization();
      } catch (error) {
        hilog.error(domainId, logTag,
          `Failed to cacelAuthorize. errCode: ${error.code}, errMessage: ${error.message}`);
      }
      try {
        this.token = '';
        this.mobile = '';
        AppStorage.set('mobile', '');
        AppStorage.set('token', '');
        AppStorage.set('userInfo', new UserInfoDetail());
        this.userInfo = new UserInfoDetail();
        clearToken();
        let util = PreferencesUtil.getInstance();
        let preferences = util.getPreferences(this.getUIContext().getHostContext()!);
        util.preferencesPut(preferences, 'qrCode', '');
        let idArr = PreferencesUtil.getInstance().getFormIds(preferences);
        if (idArr.length > 0) {
          idArr.forEach((formId: string) => {
            if (preferences.getSync(`${formId}_ticket`, '') as string === 'ticket') {
              let formData = new FormDataModel(formId);
              formData.qrcode = '';
              let formMsg: formBindingData.FormBindingData = formBindingData.createFormBindingData(formData);
              formProvider.updateForm(formId, formMsg);
            }
          });
        }
      } catch (e) {
        console.log(e);
      }
      setTimeout(() => {
        this.pageStack.pop();
      }, 200);
    })
      .catch(() => {
        let a = 0;
      })
  }

  @Builder
  nickNameBuilder() {
    Column() {
      TextInput({
        text: this.userInfo.name?.toString(),
        placeholder: '请输入昵称',
      })
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .maxLength(10)
        .cancelButton({
          style: CancelButtonStyle.CONSTANT,
          icon: { size: 16, color: '#000000' }
        })
        .onChange((value: string) => {
          if (value.length <= 10) {
            this.nickName = value;
          }
        });

      Button('确定')
        .fontColor($r('sys.color.font_on_primary'))
        .backgroundColor($r('sys.color.warning'))
        .width('100%')
        .margin({ left: 28, right: 28 })
        .enabled(!!this.userInfo.name?.toString().trim())
        .onClick(() => {
          const trimmedName = this.nickName.toString().trim();
          if (!trimmedName) {
            this.getUIContext().getPromptAction().showToast({
              message: '昵称不能为空或空格',
              alignment: Alignment.Bottom
            })
            return;
          }
          this.userInfo.name = trimmedName;
          this.isNickSheetShow = false;
        });
    }
    .padding(16)
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    NavDestination() {
      Scroll(){
        Row() {
          Column() {
            Column() {
              if (this.token) {
                Column(){
                  Row(){
                    Text('头像').fontSize(16).fontColor('#111').lineHeight(24);
                    Blank()
                    FunctionalButton({
                      params: {
                        openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
                        label: '',
                        styleOption: {
                          styleConfig: new functionalButtonComponentManager.ButtonConfig()
                            .type(ButtonType.Circle)
                            .backgroundImage(this.userInfo.userAvatar ===
                              'my2%2Fmy_useravatar.png?token=ae7805b6-8997-43a5-a6f8-7ffe8abdf9f0' ?
                              MyConfig.URL + this.userInfo.userAvatar: this.userInfo.userAvatar)
                            .backgroundImageSize(ImageSize.Cover)
                            .width(40)
                            .height(40)
                        },
                      },
                      controller: new functionalButtonComponentManager.FunctionalButtonController()
                        .onChooseAvatar((error, data) => {
                          if (error) {
                            return;
                          }
                          this.userInfo.userAvatar = data.avatarUri ? data.avatarUri : this.userInfo.userAvatar;
                        }),
                    })
                      .margin({
                        right: 10,
                      });

                    SymbolGlyph($r('sys.symbol.chevron_right'))
                      .fontColor([$r('sys.color.ohos_id_color_foreground')])
                      .opacity(0.3)
                      .fontSize('24vp')
                  }
                  .width('100%')
                  Column().width('100%').height(1).backgroundColor('#E4E4E4').margin({ top: 22, bottom: 22 });
                }
                .width('100%')

                Column(){
                  Row(){
                    Text('昵称').fontSize(16).fontColor('#111').lineHeight(24);
                    Blank()

                    Row() {
                      Text(this.userInfo.name?.toString()).fontSize(14).opacity(0.6)
                        .margin({
                          right: 6,
                        });
                      Image($r('app.media.ic_public_brush'))
                        .fillColor($r('sys.color.font_secondary'))
                        .size({ height: 24, width: 24 })
                    }
                  }
                  .onClick(() => {
                    this.isNickSheetShow = true;
                  })
                  .width('100%')
                  .bindSheet($$this.isNickSheetShow, this.nickNameBuilder(), {
                    height: 420, title: { title: '设置昵称' },
                  });
                  Column().width('100%').height(1).backgroundColor('#E4E4E4').margin({ top: 22, bottom: 22 });
                }
                .width('100%')


                Column() {
                  Text('手机号码').fontSize(16).fontColor('#111').lineHeight(24);
                  Text(this.userInfo.mobile?.toString() || this.mobile).fontSize(14).fontColor('#99111111').lineHeight(20);
                  Column().width('100%').height(1).backgroundColor('#E4E4E4').margin({ top: 22, bottom: 22 });
                }.width('100%').alignItems(HorizontalAlign.Start);

                Column() {
                  Row() {
                    Column() {
                      Text('个性化推荐').fontSize(16).fontColor('#111').lineHeight(24);
                      if (this.isRecommendation) {
                        Text('向我推荐可能感兴趣的大会议程')
                          .fontSize(14)
                          .fontColor(Color.Black)
                          .lineHeight(20);
                      } else {
                        Text('关闭后，首页将不会展示行程和议程')
                          .fontSize(14)
                          .fontColor(Color.Red)
                          .lineHeight(20);
                      }
                    }.alignItems(HorizontalAlign.Start);

                    Toggle({ type: ToggleType.Switch, isOn: this.isRecommendation })
                      .selectedColor($r('sys.color.comp_background_emphasize'))
                      .switchPointColor($r('sys.color.comp_background_primary_contrary'))
                      .onChange((isOn: boolean) => {
                        this.isRecommendation = isOn;
                      });


                  }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                  Column().width('100%').height(1).backgroundColor('#E4E4E4').margin({ top: 22, bottom: 22 });
                }.width('100%').alignItems(HorizontalAlign.Start);
              }

              Column() {
                Row() {
                  Text('隐私政策').fontSize(16).fontColor('#111').lineHeight(24);
                }.justifyContent(FlexAlign.SpaceBetween).width('100%');

                Column().width('100%').height(1).backgroundColor('#E4E4E4').margin({ top: 22, bottom: 22 });
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .onClick(() => {
                let url = this.getUIContext().getHostContext()!.resourceManager.getStringByNameSync('PRIVACY_URL');
                this.pageStack.pushPath({
                  name: 'MyWebView',
                  param: new WebViewParams(url),
                });
              });

              Column() {
                Text('备案号').fontSize(16).fontColor('#111').lineHeight(24);
                Text('xxx')
                  .fontSize(14)
                  .fontColor('#1752D7')
                  .lineHeight(20)
                  .padding({
                    top: 2,
                    bottom: 4,
                    right: 6,
                  })
                  .onClick(() => {
                    let url = this.getUIContext().getHostContext()!.resourceManager.getStringByNameSync('FILING_NUMBER_URL');
                    this.pageStack.pushPath({
                      name: 'MyWebView',
                      param: new WebViewParams(url),
                    });
                  });
                Column().width('100%').height(1).backgroundColor('#E4E4E4').margin({ top: 22 });
              }.width('100%').alignItems(HorizontalAlign.Start);
            }
            .width('100%')
            .padding(new BreakpointType<Padding>({
              sm: {
                top: 25,
                left: $r('sys.float.padding_level8'),
                right: $r('sys.float.padding_level8'),
              },
              md: {
                top: 25,
                left: $r('sys.float.padding_level12'),
                right: $r('sys.float.padding_level12'),
              },
              lg: {
                top: 25,
                left: $r('sys.float.padding_level16'),
                right: $r('sys.float.padding_level16'),
              },
            }).getValue(this.currentBreakpoint));


            if (this.token) {
              Column() {
                Button('解除关联手机号')
                  .margin({ bottom: 14 })
                  .width('100%')
                  .backgroundColor('#ECECEE')
                  .fontColor($r('sys.color.font_emphasize'))
                  .fontSize($r('sys.float.Body_L'))
                  .fontWeight(FontWeight.Bold)
                  .height(40);
              }
              .padding(new BreakpointType<Padding>({
                sm: {
                  left: $r('sys.float.padding_level8'),
                  right: $r('sys.float.padding_level8'),
                },
                md: {
                  left: $r('sys.float.padding_level12'),
                  right: $r('sys.float.padding_level12'),
                },
                lg: {
                  left: $r('sys.float.padding_level16'),
                  right: $r('sys.float.padding_level16'),
                },
              }).getValue(this.currentBreakpoint))
              .margin({ top: 68 })
              .onClick(() => {
                AvoidRepeatClick.avoidRepeatClick(() => {
                  this.logout();
                });
              });
            }
          }
          .width('100%');
        }
        .width('100%')
        .justifyContent(FlexAlign.Center);
      }
    }
    .title('设置')
    .padding({ top: px2vp(this.topRectHeight) });
  }
}