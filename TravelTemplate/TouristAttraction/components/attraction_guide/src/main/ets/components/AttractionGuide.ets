import { MapComponent } from '@kit.MapKit';
import { TextReader } from '@kit.SpeechKit';
import { AccommodationInfo, AttractionInfo, AttractionsInfo, CateringInfo, ToiletInfo } from 'module_base';
import { GUIDE_TABS_INFO } from '../constants/Constant';
import { Guide } from '../model/GuideInfo';
import { AttractionGuideVM } from '../viewmodel/AttractionGuideVM';
import { LocationDetailModal } from './LocationDetailModal';

@ComponentV2
export struct AttractionGuide {
  vm: AttractionGuideVM = AttractionGuideVM.instance;
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  @Param @Require location: number[] = [];
  @Param @Require initAttractionInfo: AttractionsInfo;

  aboutToAppear() {
    this.vm.attractionInfo = this.initAttractionInfo.attractions;
    this.vm.latitude = this.location[0];
    this.vm.longitude = this.location[1];
    this.vm.initGuideInfo();
    this.vm.initMapOptions(this.location[0], this.location[1]);
  }

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Stack({ alignContent: Alignment.TopStart }) {
        MapComponent({
          mapOptions: this.vm.mapOptions,
          mapCallback: this.vm.callback,
        }).width('100%');

        Row() {
          ForEach(GUIDE_TABS_INFO,
            (item: Guide<AttractionInfo | CateringInfo | AccommodationInfo | ToiletInfo>, index: number) => {
              Column() {
                Image(this.vm.type === index ? item.activeIcon : item.defaultIcon).size({ height: 48, width: 48 });
                Text(item.title).margin({ top: 8 }).fontSize(12);
              }.onClick(() => {
                // 释放播控资源
                TextReader.stop().then(() => {
                  TextReader.release();
                });
                this.vm.guideInfo = GUIDE_TABS_INFO[index];
                this.vm.type = index;
                this.vm.changeGuideInfo(index);
                this.vm.showDetail = false;
                // 重新绘制地图
                this.vm.redrawScenes();
              });
            }, (item: Guide<AttractionInfo | CateringInfo | AccommodationInfo | ToiletInfo>) => item.title);
        }
        .padding(16)
        .backgroundColor($r('sys.color.font_on_primary'))
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);
      };

      if (this.vm.showDetail) {
        Column() {
          LocationDetailModal({
            showDetail: this.vm.showDetail,
            distance: this.vm.distance,
            type: this.vm.type,
            close: () => {
              this.vm.showDetail = false;
            },
          });
        }.padding(12).margin({ bottom: 12 });
      }
    };
  }
}