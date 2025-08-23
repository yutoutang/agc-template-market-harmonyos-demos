import { container } from '@agctemplate/utils';
import { RequestAPI } from '@agctemplate/server';
import { DramaCoverVM } from '../viewmodels/DramaCoverVM';

export async function getBannerList(): Promise<Array<DramaCoverVM>> {
  let list = await container.resolve(RequestAPI).getBannerList()
  const result = list.getBody().data
    .map(cover => {
      const item = new DramaCoverVM()
      item.dramaId = cover.id
      item.imagePath = cover.coverUrl
      item.title = cover.name
      item.content = cover.description
      item.episodes = cover.totalCount
      item.latestUpdate = cover.latestUpdate
      item.rankId = parseInt(cover.id)
      item.tags = cover.category
      item.description = cover.description
      item.isVip = cover.isVip
      return item
    })
  return Promise.resolve(result)
}

export async function getVipBannerList(): Promise<Array<DramaCoverVM>> {
  let list = await container.resolve(RequestAPI).getVipBannerList()
  const result = list.getBody().data
    .map(cover => {
      const item = new DramaCoverVM()
      item.dramaId = cover.id
      item.imagePath = cover.coverUrl
      item.title = cover.name
      item.content = cover.description
      item.episodes = cover.totalCount
      item.latestUpdate = cover.latestUpdate
      item.rankId = parseInt(cover.id)
      item.tags = cover.category
      item.description = cover.description
      item.isVip = cover.isVip
      return item
    })
  return Promise.resolve(result)
}