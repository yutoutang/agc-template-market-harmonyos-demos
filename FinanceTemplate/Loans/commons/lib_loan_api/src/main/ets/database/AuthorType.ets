/**
 * 用户数据库字段
 */
export interface BaseAuthor {
  // 用户id
  authorId: string
  //用户昵称
  authorNickName: string
  // 用户icon
  authorIcon: string
  //用户简介
  authorDesc: string
  // 手机号
  authorPhone?: string
  // 用户ip
  authorIp: string
  // 关注的人
  watchers: string[]
  // 粉丝
  followers: string[]
  // 获赞数量
  likeNum: number
}

/**
 * 本人数据库字段
 */
export interface MyAuthor extends BaseAuthor {
  // 我的点赞
  myLikes: string[]
  // 我的收藏
  myMarks: string[]
  // 我的评论
  myComments: string[]
  // 阅读历史
  myHistory: string[]
}