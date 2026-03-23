import { UserPointRedemptionSku, UserPointsRecordItem } from '../../types/responses/UserResponse';

export const MOCK_POINTS_RECORD_LIST: UserPointsRecordItem[] = [
  {
    time: Date.now(),
    type: 1,
    label: '积分兑换',
    points: -25,
  },
  {
    time: new Date('2025-10-15').getTime(),
    type: 1,
    label: '积分兑换',
    points: -25,
  },
  {
    time: Date.now() - 60*60*1000*24,
    type: 0,
    label: '签到',
    points: 5,
  },
];

export const MOCK_POINTS_REDEMPTION_LIST: UserPointRedemptionSku[] = [
  {
    skuCode: 'redemption_10001',
    price: 25,
    title: '莫兰迪水杯马克杯可泡茶， 陶瓷磨砂质感',
    banner: $r('app.media.mock_redemption_1'),
  },
  {
    skuCode: 'redemption_10002',
    price: 40,
    title: '玻璃高脚杯红酒水晶材质耐磨光滑',
    banner: $r('app.media.mock_redemption_2'),
  },
  {
    skuCode: 'redemption_10003',
    price: 10,
    title: '吸水能力强可擦车可洗澡加大加厚毛巾',
    banner: $r('app.media.mock_redemption_3'),
  },
  {
    skuCode: 'redemption_10004',
    price: 15,
    title: '简约纯色咖啡杯',
    banner: $r('app.media.mock_redemption_4'),
  },
];