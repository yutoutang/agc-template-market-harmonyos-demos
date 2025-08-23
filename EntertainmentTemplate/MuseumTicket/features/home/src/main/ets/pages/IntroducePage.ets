import { TitleBar } from 'commonlib';
import { HomePageVM } from '../viewModels/HomePageVM';

@Builder
export function IntroducePageBuilder() {
  IntroducePage();
}


@ComponentV2
struct IntroducePage {
  vm: HomePageVM = HomePageVM.instance;

  aboutToAppear(): void {
    this.vm.getIntroduceText();
  }

  build() {
    NavDestination() {
      Stack() {
        Image(this.vm.cloudUrl.introductionBg)
          .width('100%')
          .height(220)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
        TitleBar({
          text: '省博介绍',
        });
        Scroll() {
          if (this.vm.introduceText) {
            Column({ space: 16 }) {
              Row({ space: 12 }) {
                Image($r('app.media.museum_icon')).width(88).height(88);
                Text(this.vm.introduceText.museumName)
                  .fontSize($r('sys.float.Title_M'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.string.color_brown'));
              }.width('100%');

              Column({ space: 4 }) {
                Text('展馆地址')
                  .secondTitle();
                Row({ space: 8 }) {
                  Image($r('app.media.introduce_address')).width(24).height(24);
                  Text(this.vm.introduceText.address)
                    .mainText();
                };
              }.alignItems(HorizontalAlign.Start);

              Column({ space: 4 }) {
                Text('联系方式')
                  .secondTitle();
                Row({ space: 8 }) {
                  Image($r('app.media.introduce_phone')).width(24).height(24);
                  Text(this.vm.introduceText.tel)
                    .mainText();
                };
              }.alignItems(HorizontalAlign.Start);

              Column({ space: 4 }) {
                Text('开放时间')
                  .secondTitle();
                Row({ space: 8 }) {
                  Image($r('app.media.introduce_time')).width(24).height(24);
                  Text(this.vm.introduceText.openTime)
                    .mainText();
                };
              }.alignItems(HorizontalAlign.Start);

              Column({ space: 4 }) {
                Text('交通路线')
                  .secondTitle();
                Row({ space: 8 }) {
                  Image($r('app.media.introduce_bus')).width(24).height(24);
                  Text(this.vm.introduceText.bus)
                    .mainText();
                };

                Row({ space: 8 }) {
                  Image($r('app.media.introduce_subway')).width(24).height(24);
                  Text(this.vm.introduceText.subway)
                    .mainText();
                };
              }.alignItems(HorizontalAlign.Start);

              Divider().width('100%');

              Column({ space: 4 }) {
                Text('场馆介绍').secondTitle();
                Text(this.vm.introduceText.introduction)
                  .fontSize(14)
                  .fontWeight(FontWeight.Regular)
                  .lineHeight(22)
                  .fontColor('#000000')
                  .textIndent(28);


              }.width('100%').alignItems(HorizontalAlign.Start);

            }
            .alignItems(HorizontalAlign.Start)
            .constraintSize({ minHeight: '100%' });
          }


        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .margin({ top: 108 })
        .backgroundImage(this.vm.cloudUrl.sheetBg)
        .backgroundImageSize({ width: '100%', height: '100%' })
        .borderRadius({ topLeft: 16, topRight: 16 })
        .padding({
          left: 16,
          right: 16,
          top: 12,
          bottom: 15,
        })
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })

      }.height('100%').alignContent(Alignment.Top)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);

    }.expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .hideTitleBar(true)
    .systemBarStyle({
      statusBarContentColor: '#FFFFFF',
    });
  }
}

@Extend(Text)
function mainText() {
  .fontColor($r('app.string.color_brown'))
  .fontSize($r('sys.float.Body_M'))
  .fontWeight(FontWeight.Medium);
}

@Extend(Text)
function secondTitle() {
  .fontColor($r('app.string.color_brown'))
  .fontSize($r('sys.float.Title_S'))
  .fontWeight(FontWeight.Medium);
}
