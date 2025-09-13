import { HelpMsgResp, RechargeRecord, UserInfoResp } from '../../types/User'
import { Decimal } from '@kit.ArkTS'
import { rechargeTierList } from './Store'

const userInfo: UserInfoResp = {
  id: '1',
  name: '华为用户',
  img: '',
  openId: '',
  unionId: '',
  storeId: '',
  totalScore: 88,
  wallet: 200,
  userTel: '',
}

const rechargeRecordList: RechargeRecord[] = []

export const getUserInfoResp = (): UserInfoResp => {
  return userInfo
}

export const getOpenLogin = (): UserInfoResp => {
  userInfo.userTel = '10000002222'
  return userInfo
}

export const getCloseLogin = (): UserInfoResp => {
  userInfo.userTel = ''
  return userInfo
}

export const rechargeMoney = (rechargeTierId: string): number => {
  let rechargeTier = rechargeTierList.find(item => item.id === rechargeTierId)
  if (rechargeTier) {
    userInfo.wallet = new Decimal(userInfo.wallet).add(rechargeTier.realMoney).toNumber()
    insertRechargeRecord(rechargeTier.realMoney)
    return 1
  }
  return 2
}

export const consumeMoney = (money: number): number => {
  userInfo.wallet = userInfo.wallet > money ? new Decimal(userInfo.wallet).sub(money).toNumber() : 0;
  return 1
}

const insertRechargeRecord = (rechargeMoney: number) => {
  let rechargeRecord: RechargeRecord = {
    id: `${rechargeRecordList.length + 1}`,
    rechargeMoney,
    balance: userInfo.wallet,
    time: new Date().getTime(),
    statue: 0,
  }
  return rechargeRecordList.push(rechargeRecord)
}

export const getRechargeRecord = (): RechargeRecord[] => {
  return rechargeRecordList
}

export const getHelp = (): Array<HelpMsgResp> => {
  const helpJson: string =
    '[{"id": "1","question": "我们如何收集和使用您的个人信息","answer": "欢迎您使用我们的餐饮模板，您的信任对我们很重要，我们将严格遵守法律法规要求的安全保护措施，保护您的个人信息安全可控。"}]'
  return JSON.parse(helpJson);
}
