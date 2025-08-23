import { UserInfoDetail } from 'commons'

class FromParams {
  from: string

  constructor(from: string) {
    this.from = from
  }
}

export class JumpUtil {
  token: string
  userInfo: UserInfoDetail
  pageStack: NavPathStack

  constructor(token: string, userInfo: UserInfoDetail, pageStack: NavPathStack) {
    this.token = token
    this.pageStack = pageStack
    this.userInfo = userInfo
  }

  handleJump(data: string) {
    if (data === 'isToTicket') {
      if (this.jumpLogin('ticket')) {
        return
      }
      if (this.jumpSign()) {
        return
      }
      this.jumpPage('Ticket')
    }
    if (data === 'isToTraffic') {
      this.jumpPage('Traffic')
    }
    if (data === 'isToAgenda') {
      this.pageStack.popToName('PrepareIndex', true)
      AppStorage.setOrCreate('mainTabIndex', 1);
    }
    if (data === 'isToCountdown') {
      this.pageStack.popToName('PrepareIndex', true)
      AppStorage.setOrCreate('mainTabIndex', 0);
    }
    if (data === 'isToHome') {
      this.pageStack.popToName('PrepareIndex', true)
      AppStorage.setOrCreate('mainTabIndex', 0);
    }
    if (data === 'isToMyAgenda') {
      if (!this.token) {
        this.pageStack.popToName('PrepareIndex', true)
        AppStorage.setOrCreate('mainTabIndex', 3);
        return
      }
      this.jumpPage('AgendaCollectionList')
    }
  }

  jumpLogin(page: string) {
    if (!this.token) {
      let stackIndexArray = this.pageStack.getIndexByName('Login');
      if (stackIndexArray.length > 0) {
        this.pageStack.replacePath({
          name: 'Login',
          param: new FromParams(page)
        })
      } else {
        this.pageStack.pushPath({
          name: 'Login',
          param: new FromParams(page)
        })
      }
      return true
    }
    return false
  }

  jumpSign() {
    if (this.token === '') {
      this.pageStack.pushPath({
        name: 'SignupModal2',
      })
      return true
    }
    return false
  }

  jumpPage(page: string) {
    let stackIndexArray = this.pageStack.getIndexByName(page);
    if (stackIndexArray.length > 0) {
      this.pageStack.replacePath({
        name: page,
      })
    } else {
      this.pageStack.pushPath({
        name: page,
      })
    }
  }
}