import { CircleButtonModifier, CommonConstants } from 'lib_common';
import { CommentViewModel } from '../viewmodels/CommentVM'
import { HistoryViewModel } from '../viewmodels/HistoryVM'

@ComponentV2
export struct HeaderRightPart {
  @Require @Param vm: HistoryViewModel | CommentViewModel;
  @Local buttonModifier: CircleButtonModifier = new CircleButtonModifier();

  build() {
    Row() {
      Button() {
        if (this.vm.isEditMode) {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontColor(this.vm.allowEnterEdit ? [$r('sys.color.font_primary')] : [$r('sys.color.font_secondary')])
            .fontWeight(FontWeight.Normal)
            .fontSize($r('app.float.normal_img_size'))
        } else {
          SymbolGlyph($r('sys.symbol.trash'))
            .fontColor([$r('sys.color.font_primary')])
            .fontWeight(FontWeight.Normal)
            .fontSize($r('app.float.normal_img_size'))
        }
      }
      .enabled(this.vm.allowEnterEdit)
      .attributeModifier(this.buttonModifier)
      .accessibilityText(this.vm.isEditMode ? '关闭' : '删除')
      .onClick(() => {
        if (this.vm.isEditMode) {
          this.vm.quitEdit();
        } else {
          this.vm.enterEdit();
        }
      })
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.End)
  }
}

@ComponentV2
export struct ToolBarBottom {
  @Require @Param vm: HistoryViewModel | CommentViewModel;

  build() {
    Row() {
      Column({ space: CommonConstants.SPACE_XS }) {
        Image($r('app.media.ic_public_eraser'))
          .width($r('app.float.normal_img_size'))
          .aspectRatio(1)
          .draggable(false)
          .fillColor($r('sys.color.font_primary'))
        Text('一键清空')
          .fontSize(10 * this.vm.settingInfo.fontSizeRatio)
          .fontColor($r('sys.color.font_primary'))
      }
      .width(CommonConstants.HALF_PERCENT)
      .padding(CommonConstants.PADDING_XS)
      .accessibilityText('一键清空按钮')
      .onClick(() => {
        this.vm.deleteAllConfirm();
      })

      Column({ space: CommonConstants.SPACE_XS }) {
        Image($r('app.media.ic_public_delete'))
          .width($r('app.float.normal_img_size'))
          .aspectRatio(1)
          .draggable(false)
          .fillColor(this.vm.allowDelete ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
        Text('删除')
          .fontSize(10 * this.vm.settingInfo.fontSizeRatio)
          .fontColor(this.vm.allowDelete ? $r('sys.color.font_primary') : $r('sys.color.font_secondary'))
      }
      .width(CommonConstants.HALF_PERCENT)
      .padding(CommonConstants.PADDING_XS)
      .enabled(this.vm.allowDelete)
      .accessibilityText('删除按钮')
      .onClick(() => {
        this.vm.deleteConfirm();
      })
    }
    .width(CommonConstants.FULL_PERCENT)
  }
}

@ComponentV2
export struct EditCheckbox {
  @Param isEditMode: boolean = false;
  @Event onChange: (value: boolean) => void = () => {
  };

  build() {
    Row() {
      Checkbox()
        .width($r('app.float.normal_img_size'))
        .select(false)
        .shape(CheckBoxShape.CIRCLE)
        .selectedColor($r('sys.color.warning'))
        .onChange((value: boolean) => {
          this.onChange(value);
        })
    }
    .padding({
      right: CommonConstants.PADDING_L,
    })
    .visibility(this.isEditMode ? Visibility.Visible : Visibility.None)
  }
}
