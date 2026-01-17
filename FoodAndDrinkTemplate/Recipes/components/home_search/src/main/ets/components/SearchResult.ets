import { BreakpointModel, BreakpointType } from 'base_ui';
import { RecipeBriefInfo, SortType, TabItem } from '../types/Index';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct SearchResult {
  @Param curTabIndex: number = 0;
  @Param resultList: RecipeBriefInfo[] = [];
  @Local tabList: TabItem[] =
    [{ label: '综合', sortType: SortType.General }, { label: '收藏最多', sortType: SortType.Grade },
      { label: '浏览最多', sortType: SortType.Cooked }];
  @Event changeIndex: (index: number) => void = () => {
  }
  @Event goRecipeDetail: (id: number) => void = () => {
  }
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  columnOptions: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 2,
    lg: 2,
    xl: 2,
  });

  @Computed
  get getLanes() {
    let lanes = this.columnOptions.getValue(this.breakPointModel.currentBreakpoint);
    return lanes;
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        ForEach(this.tabList, (item: TabItem, index) => {
          Text(item.label)
            .height(37)
            .textAlign(TextAlign.Center)
            .width(80)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.curTabIndex === index ? '#FD4238' : $r('sys.color.font_primary'))
            .onClick(() => {
              this.changeIndex(index)
            });
        }, (item: TabItem) => item.label);
      }.width('100%').margin({ top: 12 });

      if (this.resultList.length === 0) {
        Text('~~暂无数据~~').fontSize(12).margin({ top: 24 }).opacity(0.6);
      } else {
        List({ space: 16 }) {
          ForEach(this.resultList, (item: RecipeBriefInfo, index) => {
            ListItem() {
              Row({ space: 8 }) {
                Image($r(`app.media.${item.thumbnail}`))
                  .width(120)
                  .height(120)
                  .borderRadius(8)
                  .alt($r('app.media.food_img'));
                Column() {
                  Column({ space: 5 }) {
                    Text(item.title)
                      .width(200)
                      .fontSize(16)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(1)
                      .fontColor($r('sys.color.font_primary'));
                    Row({ space: 4 }) {
                      Text(item.cookingTime + '分钟左右').labelBaseExtend();

                      Text('难度' + item.difficulty)
                        .labelBaseExtend();

                    }.width('100%');
                  }.alignItems(HorizontalAlign.Start);


                  Text(item.likes > 0 ? `${item.likes}人收藏过` : '').fontSize(12);
                  Row({ space: 4 }) {
                    Image($r(`app.media.${item.authorAvatar}`)).width(20).height(20).borderRadius(10);
                    Text(item.author).fontSize(12).fontColor($r('sys.color.font_secondary'));
                  };
                }
                .alignItems(HorizontalAlign.Start)
                .padding({ top: 10, bottom: 10 })
                .justifyContent(FlexAlign.SpaceBetween)
                .height(120);
              };
            }
            .onClick(() => {
              this.goRecipeDetail(item.id);
            });
          }, (item: RecipeBriefInfo) => item.id.toString());
        }
        .height('calc(100% - 49vp)')
        .scrollBar(BarState.Off)
        .padding({ bottom: 20 })
        .layoutWeight(1)
        .lanes(this.getLanes)
      }
    }
  }
}

@Extend(Text)
function labelBaseExtend() {
  .fontSize(10)
  .backgroundColor('#F1F3F5')
  .padding({ left: 4, right: 4 })
  .borderRadius(4)
  .height(14)
  .fontColor($r('sys.color.font_secondary'));
}
