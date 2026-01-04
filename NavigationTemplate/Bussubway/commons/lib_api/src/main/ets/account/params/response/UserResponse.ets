/**
 * 用户-云侧接口响应模型
 */
export interface UserResponse {
  // 用户id
  userId: string
  //用户昵称
  userNickName: string
  // 用户icon
  userIcon: string
  //用户简介
  userDesc: string
  // 用户ip
  userIp: string
  // 手机号
  userPhone?: string
}