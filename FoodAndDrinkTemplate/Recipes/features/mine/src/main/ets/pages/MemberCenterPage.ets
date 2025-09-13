import { AccountUtil, CommonConstants, RouterModule } from 'commonlib';
import { MemberCenterPageVM } from '../viewModels/MemberCenterPageVM';
import { MemberPackage } from 'network';
import { AggregatedPaymentPicker, ChannelType } from 'aggregated_payment';
import { promptAction } from '@kit.ArkUI';
import { MockApi } from '../util/MockApi';

@Builder
export function MemberCenterPageBuilder() {
  MemberCenterPage();
}

@Preview
@ComponentV2
struct MemberCenterPage {
  vm: MemberCenterPageVM = new MemberCenterPageVM();

  aboutToAppear(): void {
    this.vm.getMemberPackages()
  }

  build() {
    NavDestination() {
      Stack() {
        Image($r('app.media.bg_member_center'))
          .width(CommonConstants.FULL_WIDTH)
          .height(180)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
        Column({ space: 16 }) {
          Column() {
            Row() {
              Image($r('app.media.ic_back')).width(40).height(40).onClick(() => {
                RouterModule.pop()
              })
              Text('会员中心')
                .fontSize(24)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .margin({ left: 8 })
            }
            .height(56)
            .width('100%')

            Column({ space: 8 }) {
              Text('会员套餐').fontSize(18).fontWeight(FontWeight.Bold).fontColor($r('sys.color.font_primary'))
              List({ space: 8 }) {
                ForEach(this.vm.memberPackages, (item: MemberPackage) => {
                  ListItem() {
                    Column() {
                      Column() {
                        Text(item.title)
                          .fontSize(14)
                          .fontWeight(FontWeight.Medium)
                          .fontColor($r('sys.color.font_primary'))
                        Text() {
                          Span('￥').fontSize(8)
                          Span(item.price.toString()).fontWeight(FontWeight.Bold)
                        }
                        .fontSize(14)

                        .fontColor(this.vm.selectId === item.id ? '#562E15' : $r('sys.color.font_primary'))
                        .margin({ top: 8 })
                      }
                      .backgroundColor(this.vm.selectId === item.id ? '#FFFCF2' : $r('sys.color.background_primary'))
                      .padding({ top: 14, bottom: 19 })
                      .width(100)

                      Text(item.description)
                        .fontSize(12)
                        .fontColor(this.vm.selectId === item.id ? '#562E15' : $r('sys.color.font_primary'))
                        .width(100)
                        .height(24)
                        .backgroundColor(this.vm.selectId === item.id ? '#F8E6CE' : '#0D000000')
                        .textAlign(TextAlign.Center)
                    }
                    .clip(true)
                    .border({
                      width: this.vm.selectId === item.id ? 2 : 1,
                      color: this.vm.selectId === item.id ? '#F8E6CE' : '#0D000000',
                      radius: 8,
                    })
                    .onClick(() => {
                      this.vm.selectId = item.id
                    })
                  }
                }, (item: MemberPackage) => item.id.toString())
              }.listDirection(Axis.Horizontal).height(124)
            }.width('100%').alignItems(HorizontalAlign.Start).margin({ top: 32 })

            Column({ space: 16 }) {
              Text('会员权益').fontSize(18).fontWeight(FontWeight.Bold).fontColor($r('sys.color.font_primary'))
              Column({ space: 16 }) {
                Row() {
                  Image($r('app.media.ic_no_ad')).width(40).height(40).borderRadius(20)
                  Column() {
                    Text('免广告').fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
                    Text('所有去除所有菜谱页面广告')
                      .fontSize(12)
                      .fontColor($r('sys.color.font_secondary'))
                      .margin({ top: 4 })
                  }.alignItems(HorizontalAlign.Start).margin({ left: 8 })
                }

                Row() {
                  Image($r('app.media.ic_consultation')).width(40).height(40).borderRadius(20)
                  Column() {
                    Text('提高咨询').fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
                    Text('开通私信功能').fontSize(12).fontColor($r('sys.color.font_secondary')).margin({ top: 4 })
                  }.alignItems(HorizontalAlign.Start).margin({ left: 8 })
                }

                Row() {
                  Image($r('app.media.ic_customer_service')).width(40).height(40).borderRadius(20)
                  Column() {
                    Text('专属客服').fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
                    Text('专属于您的私人客服').fontSize(12).fontColor($r('sys.color.font_secondary')).margin({ top: 4 })
                  }.alignItems(HorizontalAlign.Start).margin({ left: 8 })
                }
              }
              .width('100%')
              .padding(12)
              .border({ width: 1, color: '#E39331', radius: 16 })
              .alignItems(HorizontalAlign.Start)
            }.alignItems(HorizontalAlign.Start)
          }

          Column({ space: 12 }) {
            Row({ space: 8 }) {
              Checkbox({ name: `1`, group: `membershipPrivacy` })
                .select($$this.vm.selectCheckbox)
                .height(24)
                .width(24)
                .selectedColor('#E39331')
                .shape(CheckBoxShape.CIRCLE)
              Text() {
                Span('开通前请阅读并同意')
                Span('《会员服务协议》')
              }.fontSize(12).fontColor($r('sys.color.font_secondary'))
            }

            Button('立即开通')
              .fontColor($r('sys.color.font_on_primary'))
              .backgroundColor('#E39331')
              .width(CommonConstants.FULL_WIDTH)
              .bindSheet($$this.vm.isShow, this.paymentChannelSheet(),
                { showClose: false, height: 250 })
              .onClick(() => {
                if (!this.vm.selectCheckbox) {
                  promptAction.showToast({ message: '请勾选会员服务协议' });
                  return
                }
                // todo 替换后台接口生成支付字符串
                this.vm.wxOrderReq = MockApi.getWxPreOrderInfo();
                this.vm.hwOrderStr = MockApi.getHuaweiOrderInfo();
                MockApi.getAliPreOrderInfo().then((res) => {
                  this.vm.aliOrderStr = res;
                  this.vm.isShow = true;
                });
              })
          }.padding({ top: 8, bottom: 8 })
        }.padding({ left: 16, right: 16 }).justifyContent(FlexAlign.SpaceBetween).height(CommonConstants.FULL_HEIGHT)
      }.alignContent(Alignment.Top).expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
    }.hideTitleBar(true)

  }

  @Builder
  paymentChannelSheet() {
    AggregatedPaymentPicker({
      channelInfo: [{
        channelType: ChannelType.HUAWEI_PAY,
        name: '华为支付',
        icon: $r('app.media.hwpay'),
        preOrderInfo: this.vm.hwOrderStr,
      }, {
        channelType: ChannelType.WECHAT_PAY,
        preOrderInfo: this.vm.wxOrderReq,
        appId: MockApi.WX_APP_ID,
        icon: $r('app.media.wechat'),
        name: '微信支付',
        event: () => {
          this.vm.isShow = false;
        },
      }, {
        channelType: ChannelType.ALI_PAY,
        name: '支付宝支付',
        icon: $r('app.media.alipay'),
        preOrderInfo: this.vm.aliOrderStr,
      }],
      paySuccessEvent: (type: ChannelType) => {
        promptAction.showToast({
          message: '支付成功~',
          duration: 2000,
        });
        AccountUtil.updateMembership()
        RouterModule.pop();
        this.vm.isShow = false;
      },
    });
  }
}

