import { BreakPointSystem, MyTalkingData, UserInfoDetail } from 'commons';
import { JumpUtil } from '../utils/jump'
import { AgendaDetailParam } from 'agenda';

class FromParams {
  from: string

  constructor(from: string) {
    this.from = from
  }
}

const storage: LocalStorage = LocalStorage.getShared();

@Entry(storage)
@Component
struct Index {
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack()
  @StorageProp('token') token: string = '';
  @StorageLink('deviceId') deviceId: string = '';
  @StorageLink('userInfo') userInfo: UserInfoDetail = new UserInfoDetail()
  @StorageLink('isToCountdown') isToCountdown: boolean = false; // 我的倒计时
  @StorageLink('isToTicket') isToTicket: boolean = false; //我的门票
  @StorageLink('isToTraffic') isToTraffic: boolean = false; // 大会交通
  @StorageLink('isToAgenda') isToAgenda: boolean = false; // 全部议程
  @StorageLink('isToAgendaDetail') isToAgendaDetail: boolean = false; // 议程详情
  @StorageLink('agendaDetailId') agendaDetailId: string = ''; // 议程详情id卡片来的
  @StorageLink('isToWater') isToWater: boolean = false; // 水印相机
  @StorageLink('isToHome') isToHome: boolean = false; // 元服务首页
  @StorageLink('isToMyAgenda') isToMyAgenda: boolean = false; // 我的收藏
  @StorageLink('nfcT') @Watch('nfcWatch') nfcT: string = '';
  @StorageLink('nfcP') nfcP: string = '';
  @State isCardFrom: string = ''
  @State isFirstLoad: boolean = true // 新增标志位
  @StorageLink('result') result: Record<string, string> = {};
  private breakPointSystem = new BreakPointSystem()
  @StorageLink('mainTabIndex') currentTabIndex: number = 0;

  aboutToAppear() {
    this.breakPointSystem.register()
    if (!this.deviceId) {
      this.deviceId = MyTalkingData.generateUUID36()
    }
  }

  nfcWatch() {
    setTimeout(() => {
      if (this.nfcT) {
        this.onPageShow()
      }
    }, 500)
  }

  aboutToDisappear(): void {
    this.isFirstLoad = true
  }

  onPageShow(): void {
    // 处理卡片跳转，dp链接跳转
    if (this.isToCountdown) {
      this.isCardFrom = 'isToCountdown'
      this.isToCountdown = false
    } else if (this.isToTicket) {
      this.isCardFrom = 'isToTicket'
      this.isToTicket = false
    } else if (this.isToTraffic) {
      this.isCardFrom = 'isToTraffic'
      this.isToTraffic = false
    } else if (this.isToAgenda) {
      this.isCardFrom = 'isToAgenda'
      this.isToAgenda = false
    } else if (this.isToWater) {
      this.isCardFrom = 'isToWater'
      this.isToWater = false
    } else if (this.isToHome) {
      this.isCardFrom = 'isToHome'
      this.isToHome = false
    } else if (this.isToMyAgenda) {
      this.isCardFrom = 'isToMyAgenda'
      this.isToMyAgenda = false
    } else if (this.isToAgendaDetail) {
      this.isCardFrom = 'isToAgendaDetail'
      this.isToAgendaDetail = false
    }
    // 处理nfc 参数跳转
    if (this.nfcT === 'ticket') {
      // 这里是nfc识别参数为门票 借用门票卡片的逻辑
      this.isCardFrom = 'isToTicket'
      this.nfcT = ''
    }

    // 处理小艺建议卡片调跳转
    if (this.result) {
      try {
        let data = this.result.result
        let resultObj = JSON.parse(data) as Record<string, string>
        let entityId = resultObj.entityId
        switch (entityId) {
          case 'hdc2025countdown':
            this.isCardFrom = 'isToCountdown'
            break;
          case 'hdc2025shuttlebus':
            this.isCardFrom = 'isToTraffic'
            break;
          case 'hdc2025qrcode':
            this.isCardFrom = 'isToTicket'
            break;
          case 'hdc2025agenda':
            this.isCardFrom = 'isToAgenda'
            break;
        }
      } catch (e) {
        console.log('resultObj parse error')
      }
    }

    if (!this.isFirstLoad) { // 只在非首次时执行
      if (this.isCardFrom === 'isToAgendaDetail' && this.agendaDetailId) {
        let stackIndexArray = this.pageStack.getIndexByName('AgendaDetail');
        if (stackIndexArray.length > 0) {
          this.pageStack.replacePath({
            name: 'AgendaDetail',
            param: new AgendaDetailParam(this.agendaDetailId)
          })
        } else {
          this.pageStack.pushPath({
            name: 'AgendaDetail',
            param: new AgendaDetailParam(this.agendaDetailId)
          })
        }
        this.isCardFrom = ''
        return
      }
      let ju = new JumpUtil(this.token, this.userInfo, this.pageStack)
      ju.handleJump(this.isCardFrom)
      this.isCardFrom = ''
    }
  }

  build() {
    Navigation(this.pageStack) {
    }
    .onAppear(async () => {
      if (this.isFirstLoad) {
        // 首次加载逻辑
        this.isFirstLoad = false
      }
      this.pageStack.pushPath({
        name: 'PrepareIndex',
        param: new FromParams(this.isCardFrom)
      })
      this.isCardFrom = ''
    })
    .titleMode(NavigationTitleMode.Full)
    .hideNavBar(true)
    .mode(NavigationMode.Stack)
  }
}