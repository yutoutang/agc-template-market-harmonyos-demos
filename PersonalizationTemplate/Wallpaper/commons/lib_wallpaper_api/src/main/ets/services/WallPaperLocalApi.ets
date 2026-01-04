import { WallpaperCategory } from 'upload_recipe';
import { ImageInfo } from 'module_wallpaper_details';
import { WallpaperSuperTab } from '../database/WallpaperType';
import { MockWallpaperList } from './mockdata/MockWallpaperList';

export class WallPaperLocalApi {
  static getWallPaperTabList2(): WallpaperCategory[] {

    const categories: WallpaperCategory[] = MockWallpaperList.tabs.map((item: WallpaperSuperTab) => ({
      id: item.id,
      name: item.text,
      selected: false
    } as WallpaperCategory));

    return categories
  }

  static getWallPaperTabList(): WallpaperSuperTab[] {
    const result = MockWallpaperList.tabs
    return result;
  }

  static getWallpaperList(id: string, sortBy: string, limit: number, page: number): ImageInfo[] {

    let list: ImageInfo[] = []

    switch (id) {
      case '0':
        list = MockWallpaperList.listByIdIs0
        break;
      case '1':
        list = MockWallpaperList.listByIdIs1
        break;
      case '3':
        list = MockWallpaperList.listByIdIs3
        break;
      case '4':
        list = MockWallpaperList.listByIdIs4
        break;
      case '7':
        list = MockWallpaperList.listByIdIs7
        break;
      case '10':
        list = MockWallpaperList.listByIdIs10
        break;
      case '13':
        list = MockWallpaperList.listByIdIs13
        break;

    }

    const total = limit * page;

    list = list.slice(limit * (page - 1), list.length < total ? list.length : total)

    if (sortBy === 'hot') {
      // 热度降序
      return [...list].sort((a, b) => b.hotValue - a.hotValue);
    } else {
      // 时间降序
      return [...list].sort((a, b) => b.time - a.time);
    }
  }

  static getWallpaperListBySort(sortBy: string, limit: number, page: number): ImageInfo[] {

    let list: ImageInfo[] = MockWallpaperList.listByHotPage1

    const total = limit * page;

    list = list.slice(limit * (page - 1), list.length < total ? list.length : total)

    if (sortBy === 'hot') {
      // 热度降序
      return [...list].sort((a, b) => b.hotValue - a.hotValue);
    } else {
      // 时间降序
      return [...list].sort((a, b) => b.time - a.time);
    }
  }

  static addWallpaperList(imageInfo: ImageInfo) {
    switch (imageInfo.type) {
      case '爱豆':
        MockWallpaperList.listByIdIs1.push(imageInfo)
        break;
      case '动漫':
        MockWallpaperList.listByIdIs3.push(imageInfo)
        break;
      case '动漫':
        MockWallpaperList.listByIdIs4.push(imageInfo)
        break;
      case '动漫':
        MockWallpaperList.listByIdIs5.push(imageInfo)
        break;
      case '萌宠':
        MockWallpaperList.listByIdIs7.push(imageInfo)
        break;
      case '游戏':
        MockWallpaperList.listByIdIs10.push(imageInfo)
        break;
      case '风景':
        MockWallpaperList.listByIdIs13.push(imageInfo)
        break;

    }
  }
}
