/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { StandardCalcKeyboard } from './StandardCalcKeyboard';
import { ScienceCalcKeyboard } from './ScienceCalcKeyboard';
import { CalcConstants, CalculatorType } from '../common/Constant';
import { CalculatorVM } from '../viewmodel/CalculatorVM';
import { BreakpointModel, BreakpointStorage, BreakpointSystem, BreakpointTypeEnum } from '../utils/BreakpointSystem';

@Entry
@ComponentV2
export struct StandardCalculator {
  @Local text: string = '标准计算器';
  @Local result: string = '0'
  @Local expression: string = '0'
  @Local calculatorType: CalculatorType = CalculatorType.StandardCalc;
  @Local showResultDialog: boolean = false;
  @Param routerModule: NavPathStack = new NavPathStack()
  scrollerResult: Scroller = new Scroller();
  scrollerExpression: Scroller = new Scroller();
  @Local curBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint

  aboutToAppear(): void {
    CalculatorVM.setStack(this.routerModule);
    BreakpointSystem.register(this.getUIContext())
  }

  aboutToDisappear(): void {
    BreakpointSystem.unregister()
  }

  build() {
    Column() {
      this.HeaderInfo();
      this.ResultBuilder();
      if (this.calculatorType === CalculatorType.StandardCalc) {
        StandardCalcKeyboard({
          changeResult: (result, expression) => {
            this.result = result || ' ';
            this.expression = expression;
          }
        })
      } else {
        ScienceCalcKeyboard({
          result: this.result,
          expression: this.expression,
          changeResult: (result, expression) => {
            this.result = result || ' ';
            this.expression = expression;
          },
        });
      }
    }
    .height(CalcConstants.FULL_PERCENT)
    .padding({ left: 8, right: 8 })
  }

  @Builder
  ResultBuilder() {
    Row() {
      Column() {
        Scroll(this.scrollerExpression) {
          Text(this.expression)
            .textStyle()
            .fontSize(new BreakpointModel<number>({
              [BreakpointTypeEnum.TABLET_LANDSCAPE]: 19,
              [BreakpointTypeEnum.LG_WIDE]: 19,
              [BreakpointTypeEnum.LG_NORMAL]: 38,
            }).getValue(this.curBreakpoint.height)).onSizeChange(() => {
            this.scrollerExpression.scrollEdge(Edge.End)
          })
        }
        .margin({
          bottom: new BreakpointModel<number>({
            [BreakpointTypeEnum.TABLET_LANDSCAPE]: 5,
            [BreakpointTypeEnum.LG_WIDE]: 5,
            [BreakpointTypeEnum.LG_NORMAL]: 10,
          }).getValue(this.curBreakpoint.height)
        })
        .width(CalcConstants.FULL_PERCENT)
        .scrollBar(BarState.Off)
        .align(Alignment.End)
        .scrollable(ScrollDirection.Horizontal)

        Scroll(this.scrollerResult) {
          Text(this.result)
            .textStyle()
            .fontSize(new BreakpointModel<number>({
              [BreakpointTypeEnum.TABLET_LANDSCAPE]: 15,
              [BreakpointTypeEnum.LG_WIDE]: 15,
              [BreakpointTypeEnum.LG_NORMAL]: 30,
            }).getValue(this.curBreakpoint.height)).onSizeChange(() => {
            this.scrollerResult.scrollEdge(Edge.End)
          })
        }
        .width(CalcConstants.FULL_PERCENT)
        .alignSelf(ItemAlign.End)
        .scrollBar(BarState.Off)
        .align(Alignment.End)
        .scrollable(ScrollDirection.Horizontal)
      }
      .width(CalcConstants.FULL_PERCENT)
      .height(CalcConstants.FULL_PERCENT)
      .alignItems(HorizontalAlign.End)
      .justifyContent(FlexAlign.End)
    }
    .height(new BreakpointModel<number>({
      [BreakpointTypeEnum.TABLET_LANDSCAPE]: 61,
      [BreakpointTypeEnum.LG_WIDE]: 61,
      [BreakpointTypeEnum.LG_NORMAL]: 121,
    }).getValue(this.curBreakpoint.height))
    .backgroundColor($r('sys.color.background_tertiary'))
    .padding({
      top: 12,
      bottom: 12,
      left: 16,
      right: 16
    })
    .borderRadius(16)
    .width(CalcConstants.FULL_PERCENT)
    .margin({ bottom: 12 })
  }

  @Builder
  HeaderInfo() {
    Row() {
      Row() {
        Column() {
          Text('标准计算器').calculatorTitleStyle()
            .fontColor(CalculatorType.StandardCalc === this.calculatorType ? $r('sys.color.font_on_primary') :
            $r('sys.color.font_tertiary'))
        }.margin({ right: 8 }).calculatorColumnStyle()
        .backgroundColor(CalculatorType.StandardCalc === this.calculatorType ?
        $r('sys.color.comp_background_emphasize') : $r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.calculatorType = CalculatorType.StandardCalc;
          this.expression = '0';
          this.result = '0';
        })

        Column() {
          Text('科学计算器').calculatorTitleStyle()
            .fontColor(CalculatorType.ScienceCalc === this.calculatorType ? $r('sys.color.font_on_primary') :
            $r('sys.color.font_tertiary'))
        }.calculatorColumnStyle()
        .backgroundColor(CalculatorType.ScienceCalc === this.calculatorType ?
        $r('sys.color.comp_background_emphasize') : $r('sys.color.comp_background_tertiary'))
        .onClick(() => {
          this.calculatorType = CalculatorType.ScienceCalc;
          this.expression = '0';
          this.result = '0';
        })

      }

      Row() {
        Image($r('app.media.ic_calculations_record')).height(40).width(40)
          .onClick(() => {
            this.routerModule.pushPathByName('HistoryResult', null)
          })
      }
      .backgroundColor($r('sys.color.background_tertiary'))
      .borderRadius('50%')
      .alignSelf(ItemAlign.End)
    }.justifyContent(FlexAlign.SpaceBetween).width('100%')
    .height(60).padding({ top: 10, bottom: 10 })
  }
}

@Extend(Text)
function textStyle() {
  .fontColor($r('sys.color.font_primary'))
  .maxLines(1)
}


@Extend(Text)
function calculatorTitleStyle() {
  .fontSize($r('sys.float.Body_M'))
  .maxLines(1)
}

@Extend(Column)
function calculatorColumnStyle() {
  .padding({
    top: 10,
    bottom: 10,
    left: 16,
    right: 16
  })
  .borderRadius(21)
}