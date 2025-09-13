import { RouterMap, RouterModule } from 'foundation';

@ComponentV2
export struct MineIconLabel {
  @Param icon: ResourceStr = '';
  @Param label: ResourceStr = '';
  @Param routeUrl: RouterMap | string = '';
  @Param routeParam: Object | undefined = undefined;

  build() {
    Column({ space: 6 }) {
      Image(this.icon).width(24).height(24)
      Text(this.label).fontSize(12).height(16)
    }
    .onClick(() => {
      RouterModule.push({ url: this.routeUrl, param: this.routeParam });
    })
  }
}