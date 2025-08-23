import { DramaInfo } from '../common/DramaInfo'
import { RetBean } from '../common/RetBean'

export class MyLikeDramaData extends DramaInfo {
  currentWatch: number; //当前正在看的集数

  constructor(data: MyLikeDramaData) {
    super(data);
    this.currentWatch = data?.curIndex;
  }
}

export class MyLikeDramaRes {
  ret: RetBean;
  myLikeDramas: MyLikeDramaData[];
  total: number;

  constructor(myLikeDramaRes?: MyLikeDramaRes) {
    this.ret = new RetBean(myLikeDramaRes?.ret);
    this.myLikeDramas = (myLikeDramaRes?.myLikeDramas || []).map((item) => new MyLikeDramaData(item));
    this.total = myLikeDramaRes?.total || 0;
  }
}
