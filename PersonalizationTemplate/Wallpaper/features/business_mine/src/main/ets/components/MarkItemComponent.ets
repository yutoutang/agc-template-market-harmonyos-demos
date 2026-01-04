import { TimeUtils } from 'lib_common';
import { ImageInfo } from 'module_wallpaper_details';
import { NewMarkVM } from '../viewmodels/NewMarkVM';

@ComponentV2
export struct MarkItemComponent {
  @Param @Require record: ImageInfo;
  @Param @Require index: number;
  @Param @Require selectEdit: boolean;
  @Param @Require vm: NewMarkVM;

  build() {
    Row() {
      Toggle({ type: ToggleType.Checkbox, isOn: this.record.select })
        .margin({ right: 16 })
        .visibility(this.selectEdit ? Visibility.Visible : Visibility.None)
        .selectedColor($r('sys.color.comp_background_emphasize'))
        .onChange((isOn: boolean) => {
          if (isOn) {
            this.vm.addSelect(this.record);
          } else {
            this.vm.removeSelect(this.record);
          }
        })

      Row() {
        Stack() {
          Image(this.record.url)
            .borderRadius(8)
            .width(88)
            .height(156)
            .objectFit(ImageFit.Cover)

          if (this.record.isVideo) {
            Image($r('app.media.ic_live'))
              .width(24)
              .height(24)
              .margin(4)
              .objectFit(ImageFit.Cover)
          }
        }.alignContent(Alignment.TopStart)

        Column() {
          Column() {
            Row() {
              Text(this.record.type)
                .fontColor($r('sys.color.font_primary'))
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Center)
                .align(Alignment.Center)
                .layoutWeight(1)
            }
            .height(28)
            .width(66)
            .border({
              color: '#66000000',
              width: 1,
              radius: 33
            })
            .margin({ left: 10 })
            .justifyContent(FlexAlign.Center)

            // 关键词
            Text(this.record.keywords.split(',').join(' '))
              .fontSize(14)
              .maxLines(1)
              .margin({ top: 8, left: 10 })
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.Start)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Column() {
            Row() {
              Image(this.record.userAvatar)
                .width(16)
                .height(16)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)
                .margin({ right: 6 })

              Text(this.record.userName)
                .fontSize(12)
                .fontColor($r('sys.color.font_primary'))
                .maxLines(1)
            }
            .margin({ left: 10 })
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)

            Row() {
              Text('收藏时间：')
                .fontColor($r('sys.color.font_tertiary'))
                .fontSize(12)

              Text(TimeUtils.formatDate(this.record.time, 'YYYY-MM-DD HH:mm'))
                .fontSize(12)
                .fontColor($r('sys.color.font_tertiary'))
            }
            .alignItems(VerticalAlign.Center)
            .margin({ top: 6, left: 10 })
            .justifyContent(FlexAlign.Start)
          }
          .alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .height(156)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)
      }
      .padding(8)
      .layoutWeight(1)
      .borderRadius(12)
      .backgroundColor($r('sys.color.comp_background_primary'))
      .onClick(() => {
        this.vm.goDetail(this.index);
      });
    }
  }
}
