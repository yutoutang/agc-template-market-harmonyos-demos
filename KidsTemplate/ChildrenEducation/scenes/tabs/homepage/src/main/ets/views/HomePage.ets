import { EnglishZonePage } from '@ohos_agcit/children_education_englishzone';
import { CartoonPage } from '@ohos_agcit/children_education_cartoon';
import { SelectedPage } from '@ohos_agcit/children_education_selected';
import { SingPage } from '@ohos_agcit/children_education_sing';
import { ChinesePage } from '@ohos_agcit/children_education_chinese';
import { BreakpointType, CommonConstants, DialogUtils, GlobalInfoModel } from '@ohos_agcit/children_education_utils';
import { AppStorageV2 } from '@kit.ArkUI';


@ComponentV2
export struct HomePage {
  @Local currentIndex: number = 0;
  @Provider('age') age: string = '0-3岁';
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;
  @Local isVertical: boolean = new BreakpointType<boolean>({
    sm: false,
    md: false,
    lg: true,
  }).getValue(this.globalInfo.currentBreakpoint)
  private ageArray: Resource = $r('app.strarray.age_array');
  private controller: TabsController = new TabsController();
  @Local scrollMargin: number = 0;

  @Builder
  tabBuilder(index: number, name: string | Resource) {
    Column() {
      Text(name)
        .fontColor(Color.Black)
        .fontSize(14)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Regular)
        .fontColor(this.currentIndex === index ? $r('sys.color.black') : Color.Gray)
        .lineHeight(22)
        .margin({ top: 17, bottom: 10 })
    }
  }

  build() {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.Center }) {
          Row() {
          }
          .borderRadius(20)
          .backgroundColor('#F1F3F5')
          .width('30%')
          .height('100%');

          Row() {
            Text(this.age)
              .fontSize(16);
            SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
              .padding({
                left: '2%',
              });
          };
        };
      }
      .margin({
        top: 10
      })
      .height(36)
      .alignSelf(ItemAlign.Start)
      .padding({
        left: '4%',
      })
      .onClick(() => {
        DialogUtils.textPickerDialog(this.getUIContext(), this.ageArray, (sexValue: string) => {
          this.age = sexValue;
        });
      });

      Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
        TabContent() {
          // 精选
          SelectedPage();
        }
        .tabBar(this.tabBuilder(0, $r('app.string.selected')));

        TabContent() {
          // 看动画
          CartoonPage();
        }
        .tabBar(this.tabBuilder(1, $r('app.string.cartoon')));

        TabContent() {
          // 英语乐园
          EnglishZonePage();
        }
        .tabBar(this.tabBuilder(2, $r('app.string.english_zone')));

        TabContent() {
          // 儿歌
          SingPage();
        }
        .tabBar(this.tabBuilder(3, $r('app.string.sing')));

        TabContent() {
          // 学汉语
          ChinesePage();
        }
        .tabBar(this.tabBuilder(4, $r('app.string.chinese')));
      }
      .barWidth('100%')
      .barHeight(52)
      .width(CommonConstants.FULL_PERCENT)
      .alignSelf(ItemAlign.Start)
      .animationDuration(300)
      .onAnimationStart((index: number, targetIndex: number) => {
        this.currentIndex = targetIndex;
      })
      .align(Alignment.Start)
    };
  };
}