/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

@ComponentV2
export struct DanMuSheet {
  @Param rowsNum: number = 2;
  @Param notOpacity: number = 80;
  @Param danMuSpeed: string = '适中';
  @Param danMuSize: string = '适中';
  @Event setRowsNum: Function = (set: number) => {
  };
  @Event setNotOpacity: Function = (set: number) => {
  };
  @Event setDanMuSpeed: Function = (set: string) => {
  };
  @Event setDanMuSize: Function = (set: string) => {
  };

  build() {
    Column() {
      Row() {
        Text('弹幕设置')
          .width('100%')
          .height(27)
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'));
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 8 });

      Column({ space: 16 }) {
        // 显示行数
        Row() {
          Text('显示行数')
            .width(56)
            .height(19)
            .fontSize(14)
            .fontWeight(FontWeight.Regular);
          Row() {
            ForEach(
              [1, 2, 3, 4, 5, 6],
              (item: number) => {
                Text(`${item}`)
                  .layoutWeight(1)
                  .constraintSize({ minHeight: 36 })
                  .fontSize(14)
                  .fontWeight(this.rowsNum === item ? FontWeight.Bold : FontWeight.Medium)
                  .borderRadius(18)
                  .textAlign(TextAlign.Center)
                  .fontColor(this.rowsNum === item ? '#000' : '#9000')
                  .backgroundColor(this.rowsNum === item ? '#fff' : 'transparent')
                  .shadow(this.rowsNum === item ? { color: '#3000', radius: 3 } : { color: 'transparent', radius: 0 })
                  .onClick(() => {
                    this.setRowsNum(item);
                  });
              }
              , (index: number) => index + '_');
          }
          .width('80%')
          .height(36)
          .margin({ left: 12 })
          .borderRadius(18)
          .backgroundColor('#0d000000')
          .justifyContent(FlexAlign.SpaceBetween);
        }
        .width('100%')
        .height(48);

        // 不透明度
        Row() {
          Text('透明度')
            .width(56)
            .height(19)
            .fontSize(14)
            .fontWeight(FontWeight.Regular);
          Row() {
            ForEach(
              [20, 40, 60, 80, 100],
              (item: number) => {
                Text(item === 0 ? '' : `${item}%`)
                  .layoutWeight(1)
                  .constraintSize({ minHeight: 36 })
                  .fontSize(14)
                  .fontWeight(this.notOpacity === item ? FontWeight.Bold : FontWeight.Medium)
                  .borderRadius(18)
                  .textAlign(TextAlign.Center)
                  .fontColor(this.notOpacity === item ? '#000' : '#9000')
                  .backgroundColor(this.notOpacity === item ? '#fff' : 'transparent')
                  .shadow(this.notOpacity === item ? { color: '#3000', radius: 3 } :
                    { color: 'transparent', radius: 0 })
                  .onClick(() => {
                    this.setNotOpacity(item);
                  });
              }, (index: number) => index + '_');
          }
          .width('80%')
          .height(36)
          .margin({ left: 12 })
          .borderRadius(18)
          .backgroundColor('#0d000000')
          .justifyContent(FlexAlign.SpaceBetween);
        }
        .width('100%')
        .height(48);

        // 弹幕速度
        Row() {
          Text('弹幕速度')
            .width(56)
            .height(19)
            .fontSize(14)
            .fontWeight(FontWeight.Regular);
          Row() {
            ForEach(
              ['慢', '适中', '快'],
              (item: string) => {
                Text(item)
                  .layoutWeight(1)
                  .constraintSize({ minHeight: 36 })
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .borderRadius(18)
                  .textAlign(TextAlign.Center)
                  .fontColor(this.danMuSpeed === item ? '#000' : '#9000')
                  .backgroundColor(this.danMuSpeed === item ? '#fff' : 'transparent')
                  .shadow(this.danMuSpeed === item ? { color: '#3000', radius: 3 } :
                    { color: 'transparent', radius: 0 })
                  .onClick(() => {
                    if (item) {
                      this.setDanMuSpeed(item);
                    }
                  });
              }, (index: number) => index + '_');
          }
          .width('80%')
          .height(36)
          .margin({ left: 12 })
          .borderRadius(18)
          .backgroundColor('#0d000000')
          .justifyContent(FlexAlign.SpaceBetween);
        }
        .width('100%')
        .height(48);

        // 弹幕字号
        Row() {
          Text('弹幕字号')
            .width(56)
            .height(19)
            .fontSize(14)
            .fontWeight(FontWeight.Regular);
          Row() {
            ForEach(
              ['小', '适中', '大'],
              (item: string) => {
                Text(item)
                  .layoutWeight(1)
                  .constraintSize({ minHeight: 36 })
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .borderRadius(18)
                  .textAlign(TextAlign.Center)
                  .fontColor(this.danMuSize === item ? '#000' : '#9000')
                  .backgroundColor(this.danMuSize === item ? '#fff' : 'transparent')
                  .shadow(this.danMuSize === item ? { color: '#3000', radius: 3 } : { color: 'transparent', radius: 0 })
                  .onClick(() => {
                    if (item) {
                      this.setDanMuSize(item);
                    }
                  });
              }, (index: number) => index + '_');
          }
          .width('80%')
          .height(36)
          .margin({ left: 12 })
          .borderRadius(18)
          .backgroundColor('#0d000000')
          .justifyContent(FlexAlign.SpaceBetween);
        }
        .width('100%')
        .height(48);
      }
      .width('100%');
    };
  }
}
