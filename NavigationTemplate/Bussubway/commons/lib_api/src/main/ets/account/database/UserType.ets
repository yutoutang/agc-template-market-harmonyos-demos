/**
 * 用户数据库字段
 */
export interface BaseUser {
  // 用户id
  userId: string
  // 用户昵称
  userNickName: string
  // 用户icon
  userIcon: string
  // 用户简介
  userDesc: string
  // 用户手机号
  userPhone?: string
  // 用户ip
  userIp: string
}