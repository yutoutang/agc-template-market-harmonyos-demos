import { BaseUser } from '../../database/UserType';

/**
 * User Mock数据
 */
export class MockUser {
  // 所有用户
  static userList: BaseUser[] = [
    {
      userId: '002',
      userNickName: '华为用户',
      userIcon: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_1.jpg',
      userDesc: '',
      userPhone: '177******98',
      userIp: '北京'
    },
    {
      userId: '003',
      userNickName: '华为用户',
      userIcon: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_2.jpg',
      userDesc: '',
      userPhone: '177******99',
      userIp: '南京'
    }
  ]
  // 本人模型
  static myself: BaseUser = {
    userId: '001',
    userNickName: '华为用户',
    userIcon: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_12.jpg',
    userDesc: '在自己的小世界里，做一个快乐的普通人，把节奏放慢，享受生活！十六岁的青春张扬 十八岁的未来可期，携零零碎碎的美好奔赴未知的将来！',
    userPhone: '177******96',
    userIp: '南京'
  }
}