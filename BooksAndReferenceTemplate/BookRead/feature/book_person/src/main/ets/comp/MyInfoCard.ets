import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { Constants, TCRouter, UserInfoModel, UserInfoUtil } from 'common';
import { UserInfo } from 'base_common';
import { AvatarIcon, SelectAvatarCard } from './SelectAvatarCard';

@ComponentV2
export struct MyInfoCard {
  @Local userName: string = ''
  @Local userTel: string = ''
  @Local isLogin: boolean = false
  @Local avatarIcon: AvatarIcon = new AvatarIcon('');
  @Local isMembership: boolean = false
  @Local level: number = 1
  @Local levelString: string = 'LV0'
  @Local userInfoModel: UserInfoModel = UserInfoUtil.getUserInfoModel();

  aboutToAppear(): void {
    // 初始化用户信息
    UserInfoUtil.init();
    this.loadUserInfo();
    try {
      emitter.on(Constants.LOGIN_CHANGE, () => {
        this.loadUserInfo();
      });
    } catch (e) {
      console.error('Failed to emitter on login change. Cause: ' + JSON.stringify(e));
    }

  }

  onPageShow(): void {
    // 页面显示时刷新用户信息，确保从会员中心返回时状态是最新的
    UserInfoUtil.loadUserInfo();
    this.loadUserInfo();
  }

  loadUserInfo() {
    const userInfoFromStorage: UserInfo = AppStorage.get('userInfo') as UserInfo;
    if (userInfoFromStorage) {
      this.userInfoModel.updateFromUserInfo(userInfoFromStorage);
      console.log('userInfo' + JSON.stringify(this.userInfoModel))
      this.isLogin = true;
      this.userName = this.userInfoModel.nickName || '';
      this.userTel = this.userInfoModel.telephone || '';
      this.avatarIcon.avatarUrl = this.userInfoModel.avatarUrl || '';
      this.isMembership = this.userInfoModel.isMembership || false;
      this.level = userInfoFromStorage.level || 1;
      this.levelString = 'LV' + this.level;
      if (this.userTel) {
        this.userTel =
          `${this.userTel.substring(0, this.userTel.length - 8)}****${this.userTel.substring(this.userTel.length - 4)}`;
      }
    } else {
      this.isLogin = false;
      this.userName = '';
      this.userTel = '';
      this.avatarIcon.avatarUrl = '';
      this.isMembership = false;
      this.level = 1;
      this.levelString = 'LV0';
    }
  }

  showLoginPrompt() {
    const promptAction = this.getUIContext().getPromptAction();

    promptAction.showDialog({
      title: '提示',
      message: '需要先登录才能使用此功能',
      buttons: [
        {
          text: '取消',
          color: '#999999'
        },
        {
          text: '去登录',
          color: '#E3922F'
        }
      ]
    }).then((result) => {
      if (result.index === 1) {
        // 用户点击了'去登录'
        TCRouter.push(Constants.LOGIN_ROUTE);
      }
      // 用户点击了'取消'，不做任何操作
    }).catch(() => {
      // 异常处理
    });
  }

  @Builder
  membershipBuilder() {
    Stack() {
      Row() {
        Row({ space: 4 }) {
          Text('超10万+精品图书畅读').fontSize(14)
          Image($r('app.media.arrow_right')).width(12)
        }
        .alignItems(VerticalAlign.Top)

        Button($r('app.string.member_center'), { controlSize: ControlSize.SMALL })
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor('#E84026')
          .onClick(() => {
            if (!this.isLogin) {
              this.showLoginPrompt();
            } else {
              TCRouter.push(Constants.MEMBER_CENTER_ROUTE);
            }
          })
      }
      .width(Constants.FULL_SIZE)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .height(50)
    .width(Constants.FULL_SIZE)
    .borderRadius(12)
    .padding({
      left: 12,
      right: 12
    })
  }

  change() {
    if (this.userTel) {
      this.userTel =
        `${this.userTel.substring(0, this.userTel.length - 8)}****${this.userTel.substring(this.userTel.length - 4)}`
    }
    this.isLogin = !!this.userTel
  }

  build() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        if (this.isLogin) {
          SelectAvatarCard({ avatarIcon: this.avatarIcon, isLogin: this.isLogin })
        } else {
          Image($r('app.media.ic_default_hd'))
            .width(64)
            .height(64)
            .borderRadius(50)
            .onClick(() => {
              TCRouter.push(Constants.LOGIN_ROUTE);
            })
        }
        if (this.isLogin) {
          Column() {
            Row({ space: 4 }) {
              Text(this.userName)
                .fontSize(24)
                .fontWeight(500)
                .height(32)
                .textAlign(TextAlign.Start)
            }
            .height(32)
            .width(Constants.FULL_SIZE)

            Row({ space: 8 }) {
              Image($r('app.media.ic_public_mobile_phone'))
                .height(16)
              Text(this.userTel)
                .fontSize(12)
            }
            .height(32)
            .width(Constants.FULL_SIZE)
          }
          .height(64)
          .layoutWeight(1)
          .justifyContent(FlexAlign.SpaceBetween)

        } else {
          Row() {
            Text('去登录')
              .fontSize(24)
              .fontWeight(500)
              .height(32)
              .width(Constants.FULL_SIZE)
              .textAlign(TextAlign.Start)
              .align(Alignment.Center)
          }
          .height(64)
          .width(230)
          .onClick(() => {
            TCRouter.push(Constants.LOGIN_ROUTE);
          })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      this.membershipBuilder()
    }
    .height(150)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .padding({
      left: 12,
      right: 12,
      top: 12,
      bottom: 12,
    })
  }

  // 错误处理
  dealAllError(error: BusinessError<Object>): void {
    hilog.error(0x0000, 'testTag',
      `Failed to login, errorCode is ${error.code}, errorMessage is ${error.message}`);
    const uiContext = this.getUIContext?.();
    if (uiContext) {
      const promptAction = uiContext.getPromptAction();
      promptAction.showToast({ message: '账号关联失败' });
    }
  }
}
