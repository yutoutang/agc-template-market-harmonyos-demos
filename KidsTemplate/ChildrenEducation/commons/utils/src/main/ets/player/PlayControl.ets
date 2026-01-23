import { History, VideoDetail, SafeArrayList } from '@ohos_agcit/children_education_datasource';
import { CommonConstants } from '../constants/CommonConstants';
import { GlobalContext } from '../utils/GlobalContext';
import { ArrayList } from '@kit.ArkTS';


export function historyRecord(videoDetailInfo: VideoDetail, index: number) {
  let rawList = GlobalContext.getContext().getObject(CommonConstants.HISTORY_LIST) as ArrayList<History>;
  const historyList = new SafeArrayList(rawList);
  let videoCard = videoDetailInfo.videoCard;

  // 如果存在，则删除
  let hitIndex = -1;
  historyList.forEach((history: History, index: number) => {
    if (history.videoCard.title === videoCard.title) {
      hitIndex = index;
    }
  });
  if (hitIndex !== -1) {
    historyList.removeByIndex(hitIndex);
  }
  // 添加新的数据
  let history: History = {
    // 所有集数信息列表
    videoCardList: videoDetailInfo.videoCardDetailList,
    videoCard: videoCard,
    lastWatch: videoDetailInfo.videoCardDetailList[index],
  };
  historyList.add(history);

  if (historyList.getCapacity() >= 20) {
    historyList.removeByIndex(0);
  }
  GlobalContext.getContext().setObject(CommonConstants.HISTORY_LIST, historyList.getRaw());
}