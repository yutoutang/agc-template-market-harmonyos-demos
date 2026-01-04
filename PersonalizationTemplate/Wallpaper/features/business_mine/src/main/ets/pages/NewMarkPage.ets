import { promptAction } from '@kit.ArkUI';
import { Context } from '@kit.AbilityKit';
import { NewBaseMarkLikePage } from '../components/NewBaseMarkLikePage';
import { DialogResult } from 'upload_recipe';
import { NewMarkVM } from '../viewmodels/NewMarkVM';
import { Logger, RouterUtils } from 'lib_common';

const TAG = '[NewMarkPage]';

@Builder
// eslint-disable-next-line @typescript-eslint/naming-convention
export function NewMarkPageBuilder() {
  NewMarkPage()
}

interface NavPathStackEvent {
  pathStack: NavPathStack;
}

@ComponentV2
struct NewMarkPage {
  @Local vm: NewMarkVM = new NewMarkVM();
  private touchChange: boolean = false;
  private context: Context = getContext();
  private stack: NavPathStack = new NavPathStack();

  aboutToAppear() {
    this.vm.aboutToAppear();
  }

  aboutToDisappear() {
    this.vm.aboutToDisappear();
  }

  clearAllMark(): void {
    try {
      promptAction.showDialog({
        message: '确定要删除所选记录吗？',
        buttons: [
          { text: '取消', color: '#000000' },
          { text: '确定', color: '#0A59F7' }
        ]
      }).then((result: DialogResult) => {
        if (result.index === 1) {
          this.handleClearConfirm();
        }
      });
    } catch (error) {
      Logger.error(TAG, 'open dialog failed. error:' + JSON.stringify(error));
    }
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Image($r('app.media.ic_back'))
            .width(40)
            .height(40)
            .margin({ left: 16 })
            .onClick(() => RouterUtils.pop());

          Text('收藏记录')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .margin({ left: 12 })
            .layoutWeight(1);
          if (this.vm.list.length > 0) {
            Image($r('app.media.icon_edit'))
              .width(40)
              .aspectRatio(1)
              .margin({ right: 16 })
              .visibility(this.vm.selectEdit ? Visibility.None : Visibility.Visible)
              .onClick(() => this.vm.selectEdit = true);

            Text('退出编辑')
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .margin({ right: 16 })
              .fontColor($r('sys.color.font_emphasize'))
              .visibility(this.vm.selectEdit ? Visibility.Visible : Visibility.None)
              .onClick(() => {
                this.vm.selectEdit = false
                this.vm.removeSelectAll()
              });
          }
        }
        .margin({ top: 40 })
        .width('100%')
        .height(56)
        .alignItems(VerticalAlign.Center);

        NewBaseMarkLikePage({ vm: this.vm }).layoutWeight(1).backgroundColor($r('sys.color.background_secondary'))
        this.BottomSelectEdit()
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .onReady((event: NavPathStackEvent) => {
      this.stack = event.pathStack;
    });
  }

  @Builder
  BottomSelectEdit() {
    Row() {
      Row() {
        Toggle({ type: ToggleType.Checkbox, isOn: this.vm.selectAll })
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .onChange((isOn: boolean) => {
            if (this.touchChange) {
              if (isOn) {
                this.vm.addSelectAll()
              } else {
                this.vm.removeSelectAll()
              }
            }
            this.touchChange = false;
          }).onTouch((event: TouchEvent) => {
          this.touchChange = true;
        })

        Text('全选')
          .fontSize($r('sys.float.Body_L'))
          .margin({ left: 16 })
      }.alignItems(VerticalAlign.Center)

      Button('删除')
        .height(40)
        .width(120)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .enabled(this.vm.canDelete)
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .onClick(() => {
          this.clearAllMark();
        });
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 16 })
    .height(72)
    .visibility(this.vm.selectEdit ? Visibility.Visible : Visibility.None)
  }

  private async handleClearConfirm(): Promise<void> {
    // eslint-disable-next-line @typescript-eslint/await-thenable
    await this.vm.delete();
  }
}