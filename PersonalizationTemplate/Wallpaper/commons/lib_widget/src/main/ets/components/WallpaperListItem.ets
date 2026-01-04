import { RouterMap, RouterUtils } from 'lib_common';
import { ImageInfo, ImageInfos } from 'module_wallpaper_details';


@Builder
export function WallpaperListItem(item: ImageInfo, list: ImageInfo[]) {
  Stack() {
    Column() {
      Image(item.url)
        .objectFit(ImageFit.Cover)
        .width('100%')
        .aspectRatio(0.565)
        .borderRadius(6)
        .onClick(async () => {
          try {
            const imageInfos: ImageInfos = {
              url: item.url, list: list
            };

            // 跳转到详情页
            RouterUtils.pushPathByName(RouterMap.NEW_ROUTER_MAP_WALLPAPER_DETAIL, imageInfos);
          } catch (error) {
          }
        })

      Row() {
        Image(item.userAvatar)
          .width(16)
          .height(16)
          .margin({ right: 4 })
          .objectFit(ImageFit.Cover)
          .borderRadius(90)

        Text(item.userName)
          .fontSize(10)
          .fontColor($r('sys.color.font_secondary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
      }
      .height(16)
      .margin({ top: 2 })
    }

    if (item.isVideo) {
      Image($r('app.media.ic_live'))
        .objectFit(ImageFit.Cover)
        .width(24)
        .height(24).margin(4)
    }
  }.alignContent(Alignment.TopStart)
}