import { BusinessError } from '@kit.BasicServicesKit';
import {
  BreakpointType,
  Constants,
  isSigned,
  MyConfig,
  Phone,
  seminarContactsGet,
  sendUserInfo,
  UserInfoDetail,
} from 'commons';
import { call } from '@kit.TelephonyKit';

const TAG = '[MinePage]'

@Builder
export function MyBuilder() {
  My();
}

const needPrivacyModal: string[] = [
  'AgendaCollectionList',
  'InterestTags',
];

@Component
export struct My {
  @Consume('pageStack') pageStack: NavPathStack;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('token') token: string = '';
  @StorageProp('deviceId') deviceId: string = '';
  @StorageProp('mobile') mobile: string = '';
  @StorageLink('isAgree') isAgree: boolean = false;
  @StorageLink('userInfo') userInfo: UserInfoDetail = new UserInfoDetail();
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm';
  @StorageLink('mainTabIndex') currentTabIndex: number = 0;
  @State showInterestTag: boolean = false;
  @State totalScore: string = '';
  @State clickEffectName: string = '';
  @State openPhoneSheet: boolean = false;

  @Builder
  contactBuilder() {
    Column({ space: 12 }) {
      Text('xxx000xxxxx')
        .fontWeight(FontWeight.Medium)
        .fontSize(18)
        .fontColor($r('sys.color.font_primary'))
        .padding({
          top: 16,
        });

      Button() {
        Row() {
          Text('一键拨号')
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_on_primary'));
        };
      }
      .backgroundColor('#387BF1')
      .height(40)
      .width('94%')
      .onClick(() => {
        // 如果设备支持呼叫能力，则继续跳转到拨号界面，并显示拨号的号码
        call.makeCall('xxx000xxxxx', (err: BusinessError) => {
          if (!err) {
            console.log('make call success.');
          } else {
            console.log('make call fail, err is:' + JSON.stringify(err));
          }
        });
      });

      Button('取消')
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .height(40)
        .width('94%')
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.openPhoneSheet = false;
        });
    }
    .margin({
      top: 10,
    })
    .height(156)
    .width('92%')
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16);
  }

  @Builder
  MyItem(icon: string, title: string, needPhone2: boolean, effectName: string, callback?: () => void) {
    Stack() {
      Row() {
        Image(icon)
          .width(20)
          .margin({
            right: 16,
          });
        Row() {
          Text(title)
            .fontSize(16)
            .lineHeight(24)
            .fontColor('#111111')
            .layoutWeight(1);
          if (title === '我的码力值') {
            Text(this.totalScore)
              .fontSize(14)
              .lineHeight(20)
              .fontColor('#99111111')
              .visibility(this.token ? Visibility.Visible : Visibility.Hidden)
              .animation({
                duration: 500,
              });
          }
        }
        .height(48)
        .layoutWeight(1)
        .justifyContent(FlexAlign.SpaceBetween)
        .border({
          width: {
            bottom: title === '我的兴趣标签' ? 0 : 1,
          },
          color: '#E4E4E4',
        });
      }
      .onClick(() => {
        callback && callback();
      });

      if (!this.token && needPhone2) {
        Phone({
          cWidth: '100%',
          cHeight: 40,
          callback: () => {
            this.clickEffectName = effectName;
            this.loginSuccess();
          },
        });
      }
    };
  }

  @Builder
  ServiceItem(icon: string, title: string, callback: () => void) {
    Column() {
      Image(icon)
        .width(34)
        .margin({
          bottom: 6,
        });
      Text(title)
        .fontSize(12)
        .lineHeight(14)
        .fontColor('#e6111111');
    }.onClick(() => {
      callback();
    });
  }

  loginSuccess() {
    // 判断有没有签署开发者协议
    if (!this.isAgree && needPrivacyModal.includes(this.clickEffectName)) {
      this.getSign().then((res) => {
        if (!res) {
          this.pageStack.pushPath({
            name: 'PrivacyDialog',
            param: null,
            onPop: (popInfo: PopInfo) => {
              if (popInfo.result === 'success') {
                this.signPrivacySuccess();
              }
            },
          });
        } else {
          this.signPrivacySuccess();
        }
      });
    } else {
      this.signPrivacySuccess();
    }
  }

  signPrivacySuccess() {
    // 判断有没有报名
    seminarContactsGet({
      token: this.token,
    }).then(res => {
      this.userInfo = res.data as UserInfoDetail;
      // 此段业务根据实际情况判断
      if (!this.userInfo.ticketId) {
        // 弹框未购票
        this.pageStack.pushPath({
          name: 'SignupModal2',
        });
      } else {
        if (this.clickEffectName) {
          this.pageStack.pushPath({
            name: this.clickEffectName,
          });
        }
      }
    });
  }

  aboutToAppear() {
    this.getUIContext().getHostContext()!.eventHub.on('onShown', (index: number) => {
      if (index === Constants.PAGE_INDEX_MY) {
        this.getContactInfo();
        console.log('我的');
      }
    });
    this.getUIContext().getHostContext()!.eventHub.on('switchTab', (index: number) => {
      if (index === Constants.PAGE_INDEX_MY) {
        this.getContactInfo();
      }
    });
  }

  getContactInfo() {
    if (this.token) {
      seminarContactsGet({
        token: this.token,
      }).then(res => {
        this.userInfo = res.data as UserInfoDetail;
        if (this.userInfo.ticketId) {
          sendUserInfo(this.userInfo.ticketId || '');
        }
      });
    }
  }

  getSign() {
    return isSigned({
      token: this.token,
    }).then(res => {
      if (res.data.isSign === 1) {
        this.isAgree = true;
      }
      return Promise.resolve(res.data.isSign === 1);
    }).catch(() => {
      return Promise.resolve(false);
    });
  }

  async jumpFunc(page?: string, callback?: () => void) {
    this.clickEffectName = '';
    if (page) {
      this.clickEffectName = page;
    }
    if (!this.isAgree && needPrivacyModal.includes(this.clickEffectName)) {
      await this.getSign();
      if (!this.isAgree) {
        this.pageStack.pushPath({
          name: 'PrivacyDialog',
          param: null,
          onPop: (popInfo: PopInfo) => {
            if (popInfo.result === 'success') {
              this.signPrivacySuccess();
            }
          },
        });
        return;
      }
    }
    if (this.token === '') {
      Phone({
        cWidth: '100%',
        cHeight: 40,
        callback: () => {
          this.clickEffectName = '';
          this.loginSuccess();
        },
      });
      return;
    }
    callback && callback();
  }

  build() {
    Column() {
      /*标题*/
      Column() {
        Text('我的')
          .width('100%')
          .fontSize(24)
          .fontColor('#111111')
          .fontWeight(700);
      }
      .height(56)
      .justifyContent(FlexAlign.Center)
      .padding({ left: 16 });

      Scroll() {
        Column() {
          /*我的 */
          Column() {
            Column() {
              /*我的信息 */
              Row() {
                Column() {
                  Stack() {
                    Image(this.userInfo.userAvatar ===
                      'my2%2Fmy_useravatar.png?token=ae7805b6-8997-43a5-a6f8-7ffe8abdf9f0' ?
                      MyConfig.URL + this.userInfo.userAvatar: this.userInfo.userAvatar)
                      .borderRadius(100)
                      .width('100%')
                      .height('100%')
                      .onClick(() => {
                        this.pageStack.pushPath({
                          name: 'Setting',
                      });
                    });
                    if (!this.token) {
                      Phone({
                        cWidth: 172,
                        cHeight: 60,
                        callback: () => {
                          this.clickEffectName = '';
                          this.loginSuccess();
                        },
                      });
                    }
                  }
                }
                .border({
                  radius: '50%',
                })
                .width(48)
                .height(48)
                .borderRadius('50%')
                .margin({ right: 12,top:12 });

                Stack({
                  alignContent: Alignment.Start,
                }) {
                  if (!this.token) {
                    Text(this.userInfo.name)
                      .fontSize(16)
                      .lineHeight(20)
                      .fontColor(Color.Black)
                      .fontWeight(FontWeight.Bold)
                    Phone({
                      cWidth: 172,
                      cHeight: 60,
                      callback: () => {
                        this.clickEffectName = '';
                        this.loginSuccess();
                      },
                    });
                  } else if (this.userInfo.meetDay && this.token) {
                    Text(this.userInfo.name)
                      .fontSize(16)
                      .lineHeight(20)
                      .fontColor(Color.Black)
                      .fontWeight(FontWeight.Bold)
                      .onClick(() => {
                        this.pageStack.pushPath({
                          name: 'Setting',
                        });
                      });
                  } else if (this.token) {
                    Column() {
                      Text(this.userInfo.name)
                        .fontSize(16)
                        .lineHeight(20)
                        .fontColor(Color.White)
                        .fontWeight(FontWeight.Bold);
                      Text(this.userInfo.enterprise?.toString())
                        .margin({ top: 2 })
                        .fontSize(12)
                        .lineHeight(16)
                        .fontColor(Color.White)
                        .textOverflow({
                          overflow: TextOverflow.Ellipsis,
                        })
                        .maxLines(2);
                    }.alignItems(HorizontalAlign.Start).onClick(() => {
                      this.pageStack.pushPath({
                        name: 'Setting',
                      });
                    });
                  }
                }
                .layoutWeight(1)
                .height('100%');
              }
              .width('100%')
              .height(72)
              .backgroundColor(Color.White)
              .borderRadius(14)
              .padding({
                left: 12,
                right: 12,
              })
              .alignItems(VerticalAlign.Top)
              .padding({
                left: 12,
                right: 12,
              })
              .margin({bottom:12})

              Column() {
                /*我的门票 */
                this.MyItem(`${MyConfig.URL}my_old_icon%2Fmy_ticket_old.png?token=28b0231f-1028-4b49-9be2-1169aa05c82c`, '我的门票',
                  true,
                  'Ticket', () => {
                    this.jumpFunc('Ticket', () => {
                      this.pageStack.pushPath({
                        name: 'Ticket',
                      });
                    });
                  });

                /*我收藏的议题 */
                this.MyItem(`${MyConfig.URL}my2%2Fmy_agenda_collection_icon.png?token=914e1710-acb7-479b-9464-619c6f7b5709`,
                  '我收藏的议程', true, 'AgendaCollectionList',
                  () => {
                    this.jumpFunc('AgendaCollectionList', () => {
                      this.pageStack.pushPath({
                        name: 'AgendaCollectionList',
                      });
                    });
                  });

                /*我的兴趣标签 */
                this.MyItem(`${MyConfig.URL}my_old_icon%2Fmy_favorite_old.png?token=3d420be0-9dbe-4527-b9a7-bc5d505d0bf0`,
                  '我的兴趣标签', true,
                  'InterestTags', () => {
                    this.jumpFunc('InterestTags', () => {
                      this.pageStack.pushPath({
                        name: 'InterestTags',
                      });
                    });
                  });
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
              .backgroundColor(Color.White)
              .borderRadius(14)
              .padding({
                left: 12,
                right: 12,
              });

              // 常用服务
              Column() {
                Text('常用服务')
                  .fontSize(18)
                  .lineHeight(18)
                  .fontWeight(700)
                  .fontColor('#111111')
                  .margin({
                    bottom: 16,
                  });
                Row() {
                  this.ServiceItem(`${MyConfig.URL}my2%2Fservice_maps.png?token=d0dab002-32b3-4dfe-a490-6096a42ce958`,
                    '大会地图',
                    () => {
                      this.pageStack.pushPath({
                        name: 'Maps',
                      });
                    });
                  this.ServiceItem(`${MyConfig.URL}my2%2Fservice_cateing.png?token=0f54dbed-dc7d-4d0b-b923-af0ecbabe798`,
                    '园区餐饮',
                    () => {
                      this.pageStack.pushPath({
                        name: 'Catering',
                      });
                    });
                  this.ServiceItem(`${MyConfig.URL}my2%2Fservice_traffic.png?token=5e61b065-0acb-4c28-89af-9cc40afbed0c`,
                    '交通出行',
                    () => {
                      this.pageStack.pushPath({
                        name: 'Traffic',
                      });
                    });
                  this.ServiceItem(`${MyConfig.URL}my2%2Fservice_qa.png?token=1338efaa-b750-4a48-bda4-8c50899edded`,
                    '常见问题', () => {
                      this.pageStack.pushPath({
                        name: 'Qa',
                      });
                    });
                }
                .padding({
                  left: 8,
                  right: 8,
                })
                .justifyContent(FlexAlign.SpaceBetween).width('100%');
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
              .backgroundColor(Color.White)
              .borderRadius(14)
              .padding({
                left: 12,
                right: 12,
                top: 16,
                bottom: 16,
              })
              .margin({ top: 8 });

              Column() {
                /*设置 */
                this.MyItem(`${MyConfig.URL}my_old_icon%2Fmy_setting_old.png?token=b375d9f9-e14d-4f7b-b4f5-3cf42a15185b`, '设置',
                  false, 'Setting',
                  () => {
                    this.pageStack.pushPath({
                      name: 'Setting',
                    });
                  });

                /*联系我们 */
                Row() {
                  Image($r('app.media.kefu'))
                    .width(20)
                    .margin({
                      right: 16,
                    });
                  Row() {
                    Text('联系客服')
                      .fontSize(16)
                      .fontColor('#111111')
                    Blank()
                    Text('xxx000xxxxx')
                      .fontSize(14)
                      .fontColor('#99111111')
                      .padding(new BreakpointType<Padding>({
                        sm: {
                          right: 36,
                        },
                        md: {
                          right: 44,
                        },
                        lg: {
                          right: 62,
                        },
                      }).getValue(this.currentBreakpoint))
                      .onClick(() => {
                        this.openPhoneSheet = !this.openPhoneSheet;
                      })
                      .bindSheet($$this.openPhoneSheet, this.contactBuilder(), {
                        title: { title: '联系客服' },
                        height: '35%',
                        width: '100%',
                        preferType: SheetType.BOTTOM,
                      });

                  }
                  .width('100%')
                  .height(48)
                }
              }
              .width('100%')
              .backgroundColor(Color.White)
              .borderRadius(14)
              .padding({
                left: 12,
                right: 12,
              })
              .margin({ top: 8 });
            }
            .width('100%')
            .backgroundImageSize(ImageSize.Contain);
          }
          .width('100%')
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
          .margin({ top: 18 });


          // 关联手机号
          if (!this.token) {
            Stack() {
              Button('关联手机号')
                .fontSize($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Bold)
                .fontColor($r('sys.color.font_on_primary'))
                .width('100%')
                .height(40)
                .backgroundImageSize(ImageSize.FILL);
              Phone({
                cWidth: '100%',
                cHeight: 40,
                callback: () => {
                  this.clickEffectName = '';
                  this.loginSuccess();
                },
              });
            }
            .margin({ top: 24 })
            .width('100%')
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
            }).getValue(this.currentBreakpoint));
          }
          Column().layoutWeight(1);
        };
      }
      .width('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .layoutWeight(1);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
    .padding({ top: px2vp(this.topRectHeight) });
  }
}