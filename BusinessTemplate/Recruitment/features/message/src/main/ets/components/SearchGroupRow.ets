import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel } from 'common';
import { SearchGroupInfoModel } from '../viewmodel/AddFriendModel';

@ComponentV2
export struct SearchGroupRow {
  @Param @Require groupInfoVM: SearchGroupInfoModel;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Event onGroupClick: (groupInfoVM: SearchGroupInfoModel) => void =
    (_groupInfoVM: SearchGroupInfoModel) => {
    }

  build() {
    Row() {
      this.setAvatarImage();
      Blank().width($r('app.float.vp_12'));
      Text() {
        ForEach(this.groupInfoVM.normalArr, (str: string, index: number) => {
          Span(str);
          if (this.groupInfoVM.lightArr.length > index) {
            Span(this.groupInfoVM.lightArr[index])
              .fontColor('#0A59F7')
          }
        },(item:string,index:number)=>`${JSON.stringify(item)}_${index}}`);
      }
      .fontColor(Color.Black)
      .fontSize($r('sys.float.Body_M'))
      .fontWeight(FontWeight.Medium)
      .lineHeight($r('app.float.vp_18'))
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .textAlign(TextAlign.Start)

      Blank().width($r('app.float.vp_6'));
      Text(`(${this.groupInfoVM.count}个朋友)`)
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('app.color.color_66000000'))
        .fontWeight(FontWeight.Regular)
        .lineHeight($r('app.float.vp_18'))
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Color.White)
    .width('100%')
    .height($r('app.float.vp_64'))
    .padding({
      top: $r('app.float.vp_8'),
      left: this.breakPointModel.pagePadding,
      bottom: $r('app.float.vp_8'),
      right: this.breakPointModel.pagePadding
    })
    .onClick(() => this.onGroupClick(this.groupInfoVM))
  }

  @Builder
  setAvatarImage() {
    if (this.groupInfoVM.faceURL.length > 0) {
      Image(this.groupInfoVM.faceURL)
        .width($r('app.float.vp_48'))
        .aspectRatio(1)
        .objectFit(ImageFit.Fill)
        .borderRadius($r('sys.float.corner_radius_level6'))
    } else {
      Column({ space: this.groupInfoVM.memberInfoList.length > 4 ? 2 : 4 }) {
        ForEach(this.groupInfoVM.memberAvatarList, (rowAvatar: string[]) => {
          Row({ space: this.groupInfoVM.memberInfoList.length > 4 ? 2 : 4 }) {
            ForEach(rowAvatar, (avatar: string) => {
              Image($r('app.media.' + avatar))
                .width(this.groupChatAvatarWidth)
                .aspectRatio(1)
                .objectFit(ImageFit.Fill)
            }, (avatar: string, index: number) => avatar + index);
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }, (index: number) => index.toString());
      }
      .width($r('app.float.vp_48'))
      .height($r('app.float.vp_48'))
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor($r('app.color.color_F1F3F5'))
      .borderRadius($r('sys.float.corner_radius_level6'))
      .clip(true)
    }
  }

  @Computed
  get groupChatAvatarWidth() {
    if (this.groupInfoVM.memberInfoList.length < 5) {
      return $r('app.float.vp_20');
    } else {
      return 40 / 3.0;
    }
  }
}