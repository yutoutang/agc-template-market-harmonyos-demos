import {ActiveInfo} from 'network'

@ComponentV2
export struct ActiveCard {
  @Param @Require activeInfo: ActiveInfo;
  @Param isShowAddress:boolean = true
  @Param isShowRemain:boolean = true

  build() {
    Column() {
      Image(this.activeInfo.cover).height(120).width('100%');
      Column() {
        Text(this.activeInfo.title)
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')
          .margin({ bottom: 4 });
        Text(this.activeInfo.subtitle)
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Regular)
          .fontColor('#000000')
          .margin({ bottom: 12 })
          .opacity(0.66);
        Row() {
          Image($r('app.media.active_time')).width(16).height(16);
          Text(this.activeInfo.time).tagTextExtend();
        }.margin({ bottom: 8 });

        Row() {
          Image($r('app.media.active_compere')).width(16).height(16);
          Text(`主讲人：${this.activeInfo.compere} ${this.activeInfo.resume}`).tagTextExtend();
        }.margin({ bottom: 8 });

        Row() {
          Image($r('app.media.active_fit_age')).width(16).height(16);
          Text(`适龄人群：${this.activeInfo.fitAge}`).tagTextExtend();
        }.margin({ bottom: 8 });

        if (this.isShowAddress){
          Row() {
            Image($r('app.media.active_address')).width(16).height(16);
            Text(`举办地点：${this.activeInfo.address}`).tagTextExtend();
          }.margin({ bottom: 8 });
        }

        if (this.isShowRemain){
          Row({ space: 14 }) {
            Text(`剩余席位：${this.activeInfo.remain}`)
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor('#D1B380');
            Text(this.activeInfo.price <= 0 ? '免费' : `¥${this.activeInfo.price}`).fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor('#E84026');
          }.width('100%').justifyContent(FlexAlign.End)
        }

      }.padding(12).width('100%').alignItems(HorizontalAlign.Start);

    }.width('100%').borderRadius(16).backgroundColor('#FFFFFF').clip(true);
  }
}

@Extend(Text)
function tagTextExtend() {
  .fontSize($r('sys.float.Body_S'))
  .fontWeight(FontWeight.Regular)
  .fontColor($r('sys.color.font_primary'))
  .opacity(0.66);
}