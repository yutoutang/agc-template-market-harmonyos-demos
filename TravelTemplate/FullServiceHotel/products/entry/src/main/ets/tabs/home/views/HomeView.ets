import { MainService } from '../components/MainService';
import { PublicNotice } from '../components/PublicNotice';
import { HomePageVM } from '../viewModels/HomePageVM';
import { MainProduct } from '../components/MainProduct';
import { VIPCard } from '../components/VipCard';
import { CommonBanner, CommonHeader, CommonScroll } from 'componentlib';


@Builder
export function homeViewBuilder() {
  HomeView()
}

@ComponentV2
export struct HomeView {
  vm: HomePageVM = HomePageVM.instance;

  async aboutToAppear() {
    await this.vm.initData();
  }

  build() {
    Column() {
      CommonHeader({ title: '首页', isSubTitle: false })
      CommonScroll() {
        // 首页banner
        CommonBanner({
          covers: this.vm.bannerList,
          imageFit: ImageFit.Fill,
        })
        // 滚动公告
        PublicNotice()
        // 会员信息
        VIPCard()
        // 服务列表
        MainService()
        // 商品广告及列表 -- 商城服务
        MainProduct()
      }
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .backgroundColor($r('app.color.background_color_grey'))
  }
}