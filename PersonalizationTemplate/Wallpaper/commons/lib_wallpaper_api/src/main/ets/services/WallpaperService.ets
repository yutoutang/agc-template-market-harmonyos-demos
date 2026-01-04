import { AddMyComponentInfo, Card, CardItem } from '../database/WallpaperType';
import { WallpaperCard } from '../params/response/WallpaperResponse';
import { MockWallpaper } from './mockdata/MockWallpaper';

export class WallpaperService {
  getDesktopComponents(tabName: string, pageNum: number, pageSize: number): WallpaperCard {
    let list: CardItem[] = []
    switch (tabName) {
      case 'recommended':
        list = MockWallpaper.recommendedCard
        break;
      case 'weather':
        list = MockWallpaper.weatherCard
        break;
      case 'woodenFish':
        list = MockWallpaper.woodenFishCard
        break;
      case 'other':
        list = MockWallpaper.otherCard
        break;
    }
    const total = list.length
    const result = list.slice((pageNum - 1) * pageSize, (pageNum - 1) * pageSize + pageSize)
    const finalResult = {
      total: total,
      cardItem: result
    } as WallpaperCard
    return finalResult;
  }

  getMyComponentSmallCard(): Card[] {
    return MockWallpaper.myComponentSmallCard
  }

  getMyComponentMediumCard(): Card[] {
    return MockWallpaper.myComponentMediumCard
  }

  getMyComponentLargeCard(): Card[] {
    return MockWallpaper.myComponentLargeCard
  }

  delSmallMyComponent(id: number): Card[] {
    const index = MockWallpaper.myComponentSmallCard.findIndex(item => item.id === id);
    if (index !== -1) {
      MockWallpaper.myComponentSmallCard.splice(index, 1);
    }
    return MockWallpaper.myComponentSmallCard;
  }

  delMediumMyComponent(id: number): Card[] {
    const index = MockWallpaper.myComponentMediumCard.findIndex(item => item.id === id);
    if (index !== -1) {
      MockWallpaper.myComponentMediumCard.splice(index, 1);
    }
    return MockWallpaper.myComponentMediumCard;
  }

  delLargeMyComponent(id: number): Card[] {
    const index = MockWallpaper.myComponentLargeCard.findIndex(item => item.id === id);
    if (index !== -1) {
      MockWallpaper.myComponentLargeCard.splice(index, 1);
    }
    return MockWallpaper.myComponentLargeCard;
  }

  addSmallMyComponent(newItem: AddMyComponentInfo): Card[] {
    if (!Array.isArray(MockWallpaper.myComponentSmallCard)) {
      return [];
    }
    let maxId = 0;
    if (MockWallpaper.myComponentSmallCard.length > 0) {
      maxId = Math.max(...MockWallpaper.myComponentSmallCard.map(item => item.id));
    }
    const newId = maxId + 1;

    const newElement: Card = {
      id: newId,
      type: newItem.type,
      cardSize: newItem.cardSize,
      data: newItem.data,
    };
    MockWallpaper.myComponentSmallCard.unshift(newElement);
    return MockWallpaper.myComponentSmallCard;
  }

  queryComponent(cardSize: string, id: number | string): Card[] {
    let targetArray: Card[];
    switch (cardSize) {
      case 'small':
        targetArray = MockWallpaper.myComponentSmallCard;
        break;
      case 'medium':
        targetArray = MockWallpaper.myComponentMediumCard;
        break;
      case 'large':
        targetArray = MockWallpaper.myComponentLargeCard;
        break;
      default:
        return MockWallpaper.myComponentSmallCard;
    }

    return targetArray.filter(item => item.id === id);
  }

  addMediumMyComponent(newItem: AddMyComponentInfo): Card[] {
    if (!Array.isArray(MockWallpaper.myComponentMediumCard)) {
      return [];
    }
    let maxId = 0;
    if (MockWallpaper.myComponentMediumCard.length > 0) {
      maxId = Math.max(...MockWallpaper.myComponentMediumCard.map(item => item.id));
    }
    const newId = maxId + 1;

    const newElement: Card = {
      id: newId,
      type: newItem.type,
      cardSize: newItem.cardSize,
      data: newItem.data,
    };
    MockWallpaper.myComponentMediumCard.unshift(newElement);
    return MockWallpaper.myComponentMediumCard;
  }

  addLargeMyComponent(newItem: AddMyComponentInfo): Card[] {
    if (!Array.isArray(MockWallpaper.myComponentLargeCard)) {
      return [];
    }
    let maxId = 0;
    if (MockWallpaper.myComponentLargeCard.length > 0) {
      maxId = Math.max(...MockWallpaper.myComponentLargeCard.map(item => item.id));
    }
    const newId = maxId + 1;

    const newElement: Card = {
      id: newId,
      type: newItem.type,
      cardSize: newItem.cardSize,
      data: newItem.data,
    };
    MockWallpaper.myComponentLargeCard.unshift(newElement);
    return MockWallpaper.myComponentLargeCard;
  }

  updateSmallMyComponent(targetId: number, updateData: ESObject): Card[] {
    if (!Array.isArray(MockWallpaper.myComponentSmallCard)) {
      return [];
    }

    const targetItem = MockWallpaper.myComponentSmallCard.find(item => item.id === targetId);
    if (!targetItem) {
      return MockWallpaper.myComponentSmallCard;
    }
    const updatedItem: Card = {
      id: targetItem.id,
      type: updateData.type,
      cardSize: updateData.cardSize,
      data: updateData.data
    };

    const targetIndex = MockWallpaper.myComponentSmallCard.indexOf(targetItem);
    MockWallpaper.myComponentSmallCard[targetIndex] = updatedItem;
    return MockWallpaper.myComponentSmallCard;
  }

  updateMediumMyComponent(targetId: number, updateData: ESObject): Card[] {
    if (!Array.isArray(MockWallpaper.myComponentMediumCard)) {
      return [];
    }

    const targetItem = MockWallpaper.myComponentMediumCard.find(item => item.id === targetId);
    if (!targetItem) {
      return MockWallpaper.myComponentMediumCard;
    }
    const updatedItem: Card = {
      id: targetItem.id,
      type: updateData.type,
      cardSize: updateData.cardSize,
      data: updateData.data
    };

    const targetIndex = MockWallpaper.myComponentMediumCard.indexOf(targetItem);
    MockWallpaper.myComponentMediumCard[targetIndex] = updatedItem;
    return MockWallpaper.myComponentMediumCard;
  }

  updateLargeMyComponent(targetId: number, updateData: ESObject): Card[] {
    if (!Array.isArray(MockWallpaper.myComponentLargeCard)) {
      return [];
    }

    const targetItem = MockWallpaper.myComponentLargeCard.find(item => item.id === targetId);
    if (!targetItem) {
      return MockWallpaper.myComponentLargeCard;
    }
    const updatedItem: Card = {
      id: targetItem.id,
      type: updateData.type,
      cardSize: updateData.cardSize,
      data: updateData.data
    };

    const targetIndex = MockWallpaper.myComponentLargeCard.indexOf(targetItem);
    MockWallpaper.myComponentLargeCard[targetIndex] = updatedItem;
    return MockWallpaper.myComponentLargeCard;
  }
}


const instance = new WallpaperService();

export { instance as WallpaperServiceApi };