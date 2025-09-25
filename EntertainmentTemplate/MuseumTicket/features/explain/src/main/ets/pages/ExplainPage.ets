import { LengthMetrics } from '@kit.ArkUI';
import { TitleBuilder, RouterModule, RouterMap } from 'commonlib';
import { CardSwiper, CardItem } from 'module_card_swiper';
import { ExplainPageVM } from '../viewModels/ExplainPageVM';
import { ExplainTicketInfo } from 'network';
import { DayItem, ExplainDetail } from '../types/Index';

@Builder
export function ExplainPageBuilder() {
  ExplainPage();
}


@ComponentV2
struct ExplainPage {
  vm: ExplainPageVM = ExplainPageVM.instance;

  aboutToAppear(): void {
    this.vm.handleDaysList();
    this.vm.intData();
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 12 }) {
          if (this.vm.cardList.length) {
            CardSwiper({
              cardList: this.vm.cardList,
              onChange: (index) => {
                this.vm.curSwiperIndex = index;
                this.vm.curDayIndex = 0;
              },
            });
          }
          Column() {
            Row() {
              ForEach(this.vm.daysList, (item: DayItem, index) => {
                Column() {
                  Text(item.name)
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(this.vm.curDayIndex === index ? FontWeight.Bold : FontWeight.Regular)
                    .fontColor(this.vm.curDayIndex === index ? '#D1B380' : $r('sys.color.font_primary'));
                  Text(item.dayLabel)
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(this.vm.curDayIndex === index ? FontWeight.Bold : FontWeight.Regular)
                    .fontColor(this.vm.curDayIndex === index ? '#D1B380' : 'rgba(0,0,0,0.4)');

                }.height(38).justifyContent(FlexAlign.SpaceBetween).onClick(() => {
                  this.vm.curDayIndex = index;
                });
              }, (item: DayItem) => item.dayLabel);
            }.padding(12).width('100%').justifyContent(FlexAlign.SpaceBetween);

            Divider().width('100%');

            List() {
              ForEach(this.vm.explainTicketData, (item: ExplainTicketInfo) => {
                ListItem() {
                  Row() {
                    Column() {
                      Text(item.timeSegment)
                        .fontSize($r('sys.float.Body_M'))
                        .fontWeight(FontWeight.Regular)
                        .fontColor($r('sys.color.font_primary'));
                      Text(item.name).secondTextExtend();
                    }.height('100%').justifyContent(FlexAlign.SpaceBetween).alignItems(HorizontalAlign.Start);

                    Column() {
                      Text(item.language + '/' + item.device).secondTextExtend();
                    }.height('100%').justifyContent(FlexAlign.End);

                    Column() {
                      Text(`¥${item.price}/人`)
                        .fontWeight(FontWeight.Medium)
                        .fontColor($r('sys.color.multi_color_08'))
                        .fontSize($r('sys.float.Body_M'));
                      Text(`余票：${item.remaining}`).secondTextExtend();
                    }.height('100%').justifyContent(FlexAlign.SpaceBetween).alignItems(HorizontalAlign.Start);

                    Button('预约')
                      .backgroundColor(item.remaining > 0 ? '#D1B380' : $r('sys.color.icon_tertiary'))
                      .fontSize($r('sys.float.Body_S'))
                      .fontColor($r('sys.color.font_on_primary'))
                      .fontWeight(500)
                      .width(60)
                      .height(28)
                      .onClick(() => {
                        if (item.remaining > 0) {
                          const param: ExplainDetail = {
                            title: this.vm.cardList[this.vm.curSwiperIndex].title,
                            cover: this.vm.cardList[this.vm.curSwiperIndex].img as string,
                            time: this.vm.daysList[this.vm.curDayIndex].date.getTime(),
                            name: item.name,
                            timeSegment: item.timeSegment,
                            headsetPrice: item.headsetPrice,
                            price: item.price,
                            language: item.language,
                            remaining: item.remaining,
                            device: item.device,
                          };
                          RouterModule.push({ url: RouterMap.EXPLAIN_ORDER_PAGE, param });
                        }
                      });
                  }.width('100%').justifyContent(FlexAlign.SpaceBetween);

                }.height(63).padding({ top: 12, bottom: 12 });

              }, (item: ExplainTicketInfo) => JSON.stringify(item));
            }
            .divider({ strokeWidth: 1, color: $r('sys.color.comp_divider') })
            .padding({ left: 12, right: 12, bottom: 4 });

          }.cardWrapper();

          Column({ space: 8 }) {
            Text('讲解须知')
              .fontWeight(FontWeight.Regular)
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_primary'));
            Text('一、讲解服务总览\n' +
              '欢迎来到省博物馆！为了让您更好地领略馆内丰富' +
              '的文化魅力，我们为您提供多种形式的讲解服务，' +
              '您可以根据自己的时间、兴趣和参观方式自由选择。\n' +
              '\n' +
              '二、讲解类型及特点\n' +
              '个性化自动语音讲解：在您参观过程中，当靠近某' +
              '个重要展品时，小程序会自动弹出该展品的图片、' +
              '文字介绍等信息，并伴有生动的语音讲解。语音讲' +
              '解均为人工配音，拒绝生硬的AI配音，让您听着更' +
              '加舒服。您还可以查看讲解词，并且能根据自己' +
              '的需求对讲解语音进行加速操作。此外，小程序能' +
              '结合展品信息，在导航过程中为您提供相关的介绍' +
              '和提示，让您在前往目的地的同时，也能提前了解' +
              '即将参观的展品，增加参观的趣味性和期待感。' +
              '互动智能讲解（“翼讲解”特色）：此讲解方式支持' +
              '语音、文字输入等多种实时互动提问方式，满足不' +
              '同用户操作习惯与使用需求。您无需遵循固定讲解' +
              '时间和行程安排，只需在手机微信搜索小程序并切' +
              '换至对应场馆或扫描场馆处二维码，即可。')
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_secondary'))
              .lineHeight(19);

          }.cardWrapper().padding({ left: 12, top: 12, bottom: 12 }).alignItems(HorizontalAlign.Start);

        }.padding({ left: 16, right: 16, bottom: 10 });
      }.scrollBar(BarState.Off).layoutWeight(1).align(Alignment.Top).edgeEffect(EdgeEffect.Spring);
    }
    .title(TitleBuilder('讲解服务'), { paddingStart: LengthMetrics.vp(16) })
    .backgroundColor($r('sys.color.background_secondary'));

  }
}


@Extend(Text)
function secondTextExtend() {
  .fontSize($r('sys.float.Body_S')).fontWeight(FontWeight.Regular).fontColor($r('sys.color.font_secondary'));
}

@Extend(Column)
function cardWrapper() {
  .width('100%').borderRadius(16).backgroundColor('#FFFFFF');
}
