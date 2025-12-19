import { MapComponent, site } from '@kit.MapKit';
import { promptAction } from '@kit.ArkUI';
import { Facility } from '../model/Index';
import { SurroundVM } from '../viewmodel/SurroundVM';

@ComponentV2
export struct Surrounding {
  vm: SurroundVM = SurroundVM.instance;
  @Param @Require title: string;
  @Param @Require facilityOptions: Facility[];
  @Param pathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.vm.stack = this.pathStack;
    this.vm.getSurroundFacilityList(this.facilityOptions);
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Row({ space: 8 }) {
          Image($r('app.media.surround')).size({ width: 12, height: 12 });
          Text('周边配套和通勤').fontSize(12).fontWeight(500).opacity(0.9);
        };

        Row({ space: 8 }) {
          Text('查看完整配套').fontSize(10).opacity(0.4);
          Image($r('app.media.ic_right')).size({ width: 12, height: 12 });
        };
      }.width('100%').justifyContent(FlexAlign.SpaceBetween).onClick(() => {
        if (this.vm.mapUtil.mapOptions?.position) {
          this.pathStack.pushPathByName('FullSurrounding', null);
        } else {
          this.getUIContext().getPromptAction().showToast({ message: '请退出房源详情页后重试', duration: 1000 });
        }
      });

      MapComponent({
        mapOptions: this.vm.mapUtil.mapOptions,
        mapCallback: this.vm.mapUtil.callback,
      }).height(140);

      if (this.vm.isShow) {
        Column({ space: 12 }) {
          ForEach(this.vm.getPreview(this.title), (item: Facility) => {
            Text(item.name).fontSize(12).fontWeight(FontWeight.Bold).width('100%').textAlign(TextAlign.Start);
            ForEach(item.sites, (site: site.Site) => {
              Row() {
                Text(site.name)
                  .fontSize(12)
                  .opacity(0.9)
                  .width('60%')
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis });
                Text(`直线距离${(this.vm.calDistance(this.vm.mapUtil.mapOptions, site.location) / 1000).toFixed(2)}km`)
                  .fontSize(12)
                  .opacity(0.9);
              }.width('100%').justifyContent(FlexAlign.SpaceBetween);
            }, (site: site.Site) => site.siteId);
          }, (item: Facility) => item.name);
        };
      }
    };
  }
}
