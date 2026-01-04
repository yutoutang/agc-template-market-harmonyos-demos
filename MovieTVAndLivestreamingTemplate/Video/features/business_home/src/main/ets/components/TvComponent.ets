import { FlexLayoutModel } from '../viewmodels/FlexLayoutModel';
import { ConfigTitle } from './ConfigTitle';
import { RecommendGridContent } from './RecommendGridContent';
import { ThreeGridContent } from './ThreeGridContent';
import { TwoGridContent } from './TwoGridContent';

@ComponentV2
export struct TvComponent {
  @Local vm: FlexLayoutModel = new FlexLayoutModel();

  aboutToAppear(): void {
    this.vm.init(1)
  }

  build() {

    Column() {
      ConfigTitle({ text: '人气热播', currentIndex: this.vm.currentIndex })
      TwoGridContent({ data: this.vm.hitList.slice(0, 4) })

      ConfigTitle({ text: '经典热搜', currentIndex: this.vm.currentIndex })
      ThreeGridContent({ data: this.vm.hotSearchList.slice(0, 6) })

      ConfigTitle({ text: '推荐必看', currentIndex: this.vm.currentIndex })
      RecommendGridContent({ data: this.vm.mustList.slice(0, 4) })
    }
  }
}
