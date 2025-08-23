import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { logger } from '../utils/logger'
import { seminarContactsGet, loginByAuthCode } from '../api/serviceLogin'
import { UserInfoDetail } from '../viewModel/UserModel';
import { sendUserInfo } from '../utils/SendQrcode';
import { initCardData, sendCardData, setToken } from '../utils/cardData';
import { ComponentContent } from '@kit.ArkUI';
import { PromptActionClass } from '../utils/PromptActionClass';

@Builder
function buildLoading() {
  Column() {
    LoadingProgress().width(70).color($r('sys.color.icon_on_primary'))
    Text('加载中...').fontSize(14).fontColor('#ffffff').margin({ top: 5 })
  }
  .backgroundColor('#99000000')
  .width(130)
  .height(130)
  .borderRadius(20)
  .justifyContent(FlexAlign.Center)
}


@Component
export struct Phone {
  @Consume('pageStack') pageStack: NavPathStack;
  @StorageLink('token') token: string = '';
  @StorageLink('sid') sid: string = '';
  @StorageLink('mobile') mobile: string = '';
  @StorageLink('userInfo') userInfo: UserInfoDetail = new UserInfoDetail()
  @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm'
  @Prop cWidth: number | string
  @Prop cHeight: number | string
  private ctx: UIContext = this.getUIContext();
  private contentNode: ComponentContent<Object> =
    new ComponentContent(this.ctx, wrapBuilder(buildLoading));
  callback: () => void = () => {
  }

  aboutToAppear(): void {
    PromptActionClass.setContext(this.ctx);
    PromptActionClass.setContentNode(this.contentNode);
  }

  getContactInfo() {
    if (this.token) {
      seminarContactsGet({
        token: this.token,
      }).then((res) => {
        this.userInfo = res.data as UserInfoDetail;
        if (this.userInfo.ticketId) {
          try {
            sendUserInfo(this.userInfo.ticketId || '')
          } catch (e) {
            console.log('e', JSON.stringify(e))
          }
        }
      })
    }
  }

  async updateCardData() {
    await initCardData(this.getUIContext().getHostContext()!, () => {
      sendCardData()
    })

  }

  login(authorizationCode: string) {
    // 通过手机授权码去后台获取手机号或者token
    // 以下是模拟数据，请根据实际情况调用接口
    loginByAuthCode({
      code: authorizationCode
    }).then(res => {
      if (res && res.data) {
        let token = res.data.token || ''
        let mobile = res.data.mobile || ''
        this.token = token
        this.mobile = mobile
        try {
          setToken(token)
          this.getContactInfo()
        } catch (e) {
          console.log('e')
        }
      }
      this.callback()
      this.updateCardData()
    }).catch(() => {
      console.log('catch callbacked')
    })
  }

  build() {
    Column() {
      FunctionalButton({
        params: {
          openType: functionalButtonComponentManager.OpenType.GET_PHONE_NUMBER,
          label: '',
          styleOption: {
            styleConfig: new functionalButtonComponentManager.ButtonConfig()
              .height(this.cHeight)
              .width(this.cWidth)
              .backgroundColor('#00000000'),
          },
        },
        controller: new functionalButtonComponentManager.FunctionalButtonController()
          .onGetPhoneNumber((error, data) => {
            if (error) {
              logger.error('0x0000', 'testTag', 'error： %{public}d %{public}s', error.code.toString(), error.message);
              this.getUIContext().getPromptAction().showToast({
                message: '未申请phone权限，开始mock'
              })
              PromptActionClass.closeDialog();
              // 此为模拟数据，实际用data.code去获取认证token或者手机号
              let authorizationCode = '12345678'
              this.login(authorizationCode);
              authorizationCode = '12345678';
              return;
            }
            PromptActionClass.closeDialog();
            // 此为模拟数据，实际用data.code去获取认证token或者手机号
            let authorizationCode = '12345678'
            this.login(authorizationCode);
            authorizationCode = data.code!;
          })
      })
    }.onClick(() => {
      PromptActionClass.openDialog();
      PromptActionClass.updateDialog({
        alignment: DialogAlignment.Center,
        offset: { dx: 0, dy: this.currentBreakpoint === 'sm' ? 120 : 0 }
      });
    })
  }
}
