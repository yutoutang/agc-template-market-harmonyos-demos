import { CardRegister } from 'module_flexlayout'
import { FeedDetailsCard } from '../components/FeedDetailsCard'
import { VerticalBigImageCard } from '../components/VerticalBigImageCard'
import { TopTextBottomBigImageCard } from '../components/TopTextBottomBigImageCard'
import { LeftTextRightImageCard } from '../components/LeftTextRightImageCard'
import { TopTextBottomImageCard } from '../components/TopTextBottomImageCard'
import { HotNewsServiceCard } from '../components/HotNewsServiceCard'
import { HotListServiceSwitchCard } from '../components/HotListServiceSwitchCard'
import { TopTextBottomVideoCard } from '../components/TopTextBottomVideoCard'
import { AdvertisementCard } from '../components/AdvertisementCard'

/*
 * native卡片
 * FeedDetailsCard 动态卡片
 * VerticalBigImageCard 视频大图
 * TopTextBottomBigImageCard 下文下大图
 * LeftTextRightImageCard 左文右图
 * TopTextBottomImageCard 下文下图
 * HotNewsServiceCard 热门卡片
 * HotListServiceSwitchCard 热门切换卡片
 * TopTextBottomVideoCard 上文下视频
 * AdvertisementCard 广告卡片
 * */
export class CardRegisterEngine {
  public static CardRegister() {
    let nodeBuilderConfigVm = CardRegister.instance
    nodeBuilderConfigVm.registerCard('FeedDetailsCard', wrapBuilder(FeedDetailsCard))
    nodeBuilderConfigVm.registerCard('VerticalBigImageCard', wrapBuilder(VerticalBigImageCard))
    nodeBuilderConfigVm.registerCard('TopTextBottomBigImageCard', wrapBuilder(TopTextBottomBigImageCard))
    nodeBuilderConfigVm.registerCard('LeftTextRightImageCard', wrapBuilder(LeftTextRightImageCard))
    nodeBuilderConfigVm.registerCard('TopTextBottomImageCard', wrapBuilder(TopTextBottomImageCard))
    nodeBuilderConfigVm.registerCard('HotNewsServiceCard', wrapBuilder(HotNewsServiceCard))
    nodeBuilderConfigVm.registerCard('HotListServiceSwitchCard', wrapBuilder(HotListServiceSwitchCard))
    nodeBuilderConfigVm.registerCard('TopTextBottomVideoCard', wrapBuilder(TopTextBottomVideoCard))
    nodeBuilderConfigVm.registerCard('AdvertisementCard',wrapBuilder(AdvertisementCard))
  }
}
