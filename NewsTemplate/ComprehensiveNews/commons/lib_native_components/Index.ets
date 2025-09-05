import { NodeBuilderConfig } from './src/main/ets/utils/NodeBuilderConfig';

import { FeedDetailsCard } from './src/main/ets/components/FeedDetailsCard'
import { VerticalBigImageCard } from './src/main/ets/components/VerticalBigImageCard'
import { TopTextBottomBigImageCard } from './src/main/ets/components/TopTextBottomBigImageCard'
import { LeftTextRightImageCard } from './src/main/ets/components/LeftTextRightImageCard'
import { TopTextBottomImageCard } from './src/main/ets/components/TopTextBottomImageCard'
import { HotNewsServiceCard } from './src/main/ets/components/HotNewsServiceCard'
import { HotListServiceSwitchCard } from './src/main/ets/components/HotListServiceSwitchCard'
import { TopTextBottomVideoCard } from './src/main/ets/components/TopTextBottomVideoCard'
import { AdvertisementCard } from './src/main/ets/components/AdvertisementCard'
export { transformLayout } from './src/main/ets/utils/Utils'



let nodeBuilderConfigVm = NodeBuilderConfig.instance
nodeBuilderConfigVm.registerBuilderCard('FeedDetailsCard', wrapBuilder(FeedDetailsCard))
nodeBuilderConfigVm.registerBuilderCard('VerticalBigImageCard', wrapBuilder(VerticalBigImageCard))
nodeBuilderConfigVm.registerBuilderCard('TopTextBottomBigImageCard', wrapBuilder(TopTextBottomBigImageCard))
nodeBuilderConfigVm.registerBuilderCard('LeftTextRightImageCard', wrapBuilder(LeftTextRightImageCard))
nodeBuilderConfigVm.registerBuilderCard('TopTextBottomImageCard', wrapBuilder(TopTextBottomImageCard))
nodeBuilderConfigVm.registerBuilderCard('HotNewsServiceCard', wrapBuilder(HotNewsServiceCard))
nodeBuilderConfigVm.registerBuilderCard('HotListServiceSwitchCard', wrapBuilder(HotListServiceSwitchCard))
nodeBuilderConfigVm.registerBuilderCard('TopTextBottomVideoCard', wrapBuilder(TopTextBottomVideoCard))
nodeBuilderConfigVm.registerBuilderCard('AdvertisementCard',wrapBuilder(AdvertisementCard))
export { NodeBuilderConfig } from './src/main/ets/utils/NodeBuilderConfig'