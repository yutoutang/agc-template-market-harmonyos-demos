import {
  AvoidArea,
  CommonConstants,
  FavoriteDatabase,
  LeftReturnComponent,
  promptFun,
  SearchType,
} from '@ohos_agcit/common_component';
import { JobListItem } from '@ohos_agcit/common_component';
import { AppStorageV2, PersistenceV2, router, UIContext } from '@kit.ArkUI';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { systemShare } from '@kit.ShareKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@ComponentV2
export struct JobDetail {
  @Local jobInfo: JobListItem = router.getParams() as JobListItem;
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local favoriteDatabase: FavoriteDatabase =
    PersistenceV2.connect(FavoriteDatabase, () => new FavoriteDatabase())!;
  addressList: SearchType[] = CommonConstants.ADDRESS_COLLECTION;
  addressMap: Map<number, SearchType> = new Map<number, SearchType>(
    this.addressList.map(item => [item.index, item]),
  );

  sharePosition() {
    let uiContext: UIContext = this.getUIContext();
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: utd.UniformDataType.HYPERLINK,
      content: 'developer.huawei.com',
      title: this.jobInfo.name, // 标题
      description: this.jobInfo.responsibilities, // 描述
    });
    let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
    let context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
    controller.show(context, {
      previewMode: systemShare.SharePreviewMode.DEFAULT,
      selectionMode: systemShare.SelectionMode.SINGLE,
    }).then(() => {
      console.log('show success');
    }).catch((error: BusinessError) => {
      console.log('show error');
    });
  }

  build() {
    Column() {
      // Scroll的高度应受外层容器控制，里面和其自身不能有高度
      Column(){
        Scroll(){
          Column(){
            Row() {
              LeftReturnComponent()
                .onClick(() => {
                  router.back();
                });
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .height(40)
            .justifyContent(FlexAlign.Start)
            .margin({
              bottom: 27,
            });

            Column() {
              Text(this.jobInfo.name)
                .fontSize(16)
                .fontColor('rgba(0,0,0,0.90)')
                .fontWeight(FontWeight.Medium);
              Text(this.addressMap.get(this.jobInfo.address)?.title + ' · ' + this.jobInfo.jobType)
                .fontSize(14)
                .fontColor('rgba(0,0,0,0.60)')
                .margin({ top: '3%' });
              Row()
                .height(0.8)
                .backgroundColor($r('app.color.button_gray'))
                .width('93%')
                .margin({ top: 10 });
            }
            .height(60)
            .width('100%')
            .alignItems(HorizontalAlign.Start);

            Column() {
              Text('工作职责')
                .fontSize(18)
                .fontColor('rgba(0,0,0,0.90)')
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 8 });
              Scroll() {
                Text(this.jobInfo.responsibilities)
                  .fontSize(14)
                  .fontColor('rgba(0,0,0,0.90)')
                  .lineHeight(20);
              }
              .scrollBar(BarState.Off);
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .margin({ top: 24 });

            Column() {
              Text('职位要求')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('rgba(0,0,0,0.90)')
                .margin({ bottom: 8 });
              Scroll() {
                Text(this.jobInfo.requirements)
                  .fontSize(14)
                  .fontColor('rgba(0,0,0,0.90)')
                  .lineHeight(20);
              }
              .scrollBar(BarState.Off)
              .edgeEffect(EdgeEffect.Spring)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .margin({ top: 24 });

            Text('发布于' + this.jobInfo.publishTime)
              .width('100%')
              .fontSize(12)
              .fontColor('rgba(0,0,0,0.60)')
              .margin({ top: 16 });
          }
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .layoutWeight(1)

      Row() {
        Image($r('app.media.share'))
          .width(24)
          .height(24)
          .margin({
            right: 24,
          })
          .onClick(() => {
            this.sharePosition();
          });
        Image(this.favoriteDatabase.favoriteList.includes(this.jobInfo.id) ?
        $r('app.media.active_collection_star') :
        $r('app.media.job_star'))
          .height(24)
          .width(24)
          .onClick(() => {
            let jobId: string = this.jobInfo.id;
            if (this.favoriteDatabase.favoriteList.includes(jobId)) {
              this.favoriteDatabase.favoriteList.splice(this.favoriteDatabase.favoriteList.indexOf(jobId), 1);
              promptFun('取消收藏', 1500);
              return;
            }
            this.favoriteDatabase.favoriteList.push(jobId);
            promptFun('收藏成功', 1500);
          });
        Blank();

        Button('简历投递')
          .fontSize($r('sys.float.Body_L'))
          .backgroundColor($r('sys.color.font_emphasize'))
          .height('100%')
          .width('75%')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/jobRoute/JobDelivery',
              params: this.jobInfo,
            }, router.RouterMode.Standard);
          });
      }
      .height(48)
      .width('100%');
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.common_background'))
    .padding({
      top: px2vp(this.avoidArea.topRectHeight),
      bottom: px2vp(this.avoidArea.bottomRectHeight),
      left: '4%',
      right: '4%',
    });
  }
}
