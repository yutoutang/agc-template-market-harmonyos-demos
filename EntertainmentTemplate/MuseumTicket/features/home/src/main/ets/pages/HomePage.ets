import { BaseHeader, RouterMap, RouterModule } from 'commonlib';
import { Banner } from '../components/Banner';
import { MainServer } from '../components/MainServer';
import { OrderBar } from '../components/OrderBar';
import { RecommendBar } from '../components/RecommendBar';
import { UserBar } from '../components/UserBar';
import { TreasureItem } from 'network';
import { HomePageVM } from '../viewModels/HomePageVM';


@Builder
export function HomePageBuilder() {
  HomePage();
}


@ComponentV2
struct HomePage {
  vm: HomePageVM = HomePageVM.instance;

  async aboutToAppear(): Promise<void> {
    await this.vm.initData();
  }

  // 珍品
  @Builder
  treasureBuilder() {
    Column({ space: 8 }) {
      Row() {
        Text('馆藏珍品').fontSize($r('sys.float.Body_L')).fontWeight(FontWeight.Medium).fontColor('#000000');
        Row({ space: 4 }) {
          Text('全部').fontSize($r('sys.float.Body_S')).fontWeight(FontWeight.Regular).fontColor('#000000');
          Image($r('app.media.ic_public_arrow_right')).width(12).height(24);
        }.onClick(() => {
          RouterModule.push({ url: RouterMap.TREASURE_PAGE });
        });
      }.padding({ left: 16, right: 16 }).width('100%').justifyContent(FlexAlign.SpaceBetween);

      List({ space: 12 }) {
        ForEach(this.vm.treasureInfo, (item: TreasureItem, index) => {
          ListItem() {
            Stack({}) {
              Image(item.cover).width('100%').height('100%');
              Text(item.title)
                .margin({ left: 12, bottom: 12 })
                .fontColor($r('sys.float.Body_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF');
            }
            .width(260)
            .height(166)
            .borderRadius(16)
            .clip(true)
            .alignContent(Alignment.BottomStart);
          }.onClick(() => {
            RouterModule.push({ url: RouterMap.TREASURE_PAGE, param: { defaultIndex: index } });
          });

        }, (item: TreasureItem) => item.treasureId.toString());
      }.listDirection(Axis.Horizontal).margin({ left: 16 }).scrollBar(BarState.Off);

    };
  }

  // 活动
  @Builder
  activeBuilder() {
    Column({ space: 8 }) {
      Text('活动预约').fontSize($r('sys.float.Body_L')).fontWeight(FontWeight.Medium).fontColor('#000000');
      Stack() {
        Image(this.vm.cloudUrl.activeCover);
        Column({ space: 8 }) {
          Text('南博活动').fontColor('#FFFFFF').fontSize($r('sys.float.Body_M')).fontWeight(FontWeight.Medium);
          Button('查看更多')
            .fontSize($r('sys.float.Body_S'))
            .fontWeight(FontWeight.Regular)
            .fontColor('#603C00')
            .padding(0)
            .width(78)
            .height(24)
            .borderRadius(14)
            .backgroundColor('#D1B380')
            .onClick(() => {
              RouterModule.push({ url: RouterMap.ACTIVE_PAGE });
            });
        }
        .width('100%')
        .height('100%')
        .padding(12)
        .justifyContent(FlexAlign.End)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .height(166)
      .borderRadius(16)
      .alignContent(Alignment.BottomStart)
      .clip(true);
    }.alignItems(HorizontalAlign.Start);

  }

  build() {
    NavDestination() {
      BaseHeader('博物馆');
      Scroll() {
        Stack({ alignContent: Alignment.Top }) {
          Banner();
          Column({ space: 12 }) {
            Column({ space: 12 }) {
              // 用户信息
              UserBar();
              //   订票
              OrderBar();
              //   主要服务
              MainServer();
            }.padding({ left: 16, right: 16 });

            this.treasureBuilder();

            Column({ space: 12 }) {
              // 活动
              this.activeBuilder();
              //   精彩推荐
              RecommendBar();
            }.padding({ left: 16, right: 16 });

          }
          .justifyContent(FlexAlign.Start)
          .margin({ top: 146 });
        }.backgroundColor($r('sys.color.ohos_id_color_sub_background'));

      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring);
    }.hideTitleBar(true);
  }
}
