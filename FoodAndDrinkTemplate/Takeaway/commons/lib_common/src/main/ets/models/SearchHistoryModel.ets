import { RandomUtils } from '../utils/RandomUtils';

@ObservedV2
export class SearchHistory {
  @Trace historyList: string[] = [];
  @Trace hotSearchList: string[] = [
    '麻辣烫',
    '螺蛳粉',
    '黄焖鸡米饭',
    '小龙虾',
    '烧烤外卖',
    '炸鸡',
    '披萨',
    '日式拉面',
    '轻食沙拉',
    '奶茶',
    '咖啡外卖',
    '寿司',
    '牛肉饭',
    '水饺',
    '汉堡',
    '工作餐',
    '一人食',
    '家庭套餐',
    '深夜食堂',
    '早餐外卖',
    '下午茶',
    '健身餐',
    '低脂餐',
    '素食',
    '高蛋白',
    '儿童餐',
    '免配送费',
    '新店开业',
    '满减优惠',
    '折扣菜品',
    '爆款特价',
    '限时秒杀',
    '赠送饮料',
    '今日特惠',
    '川湘菜',
    '港式茶餐厅',
    '东北菜',
    '新疆大盘鸡',
    '粤式烧腊',
    '韩国炸酱面'
  ];
  @Trace hotSearchListLimit: string[] = this.getRandomSixSimple();

  getRandomSixSimple(): string[] {
    const array = [...this.hotSearchList];
    const result: string[] = [];

    if (array.length === 0) {
      return [];
    }

    const count = Math.min(6, array.length);

    for (let i = 0; i < count; i++) {
      const randomIndex = Math.floor(RandomUtils.random(1) * array.length);
      result.push(array[randomIndex]);
      // 移除已选中的元素，避免重复
      array.splice(randomIndex, 1);
    }
    this.hotSearchListLimit = result;
    return result;
  }
}