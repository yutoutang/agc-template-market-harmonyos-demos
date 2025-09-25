@ComponentV2
export struct PersonCard {
  @Param cardId: string = '';
  @Param name: string = '';
  @Param isChecked: boolean = true;
  // 该按钮是否禁用
  @Param isDisable: boolean = false;
  @Event onCheckChange: (value: boolean) => void = () => {

  };

  build() {
    Row() {
      Image($r('app.media.module_person')).width(24).height(24).margin({ right: 12 });
      Column({ space: 12 }) {
        Text(this.name).commonTextExtend();
        Text(this.cardId.substring(0, 6) + '********' + this.cardId.substring(14)).commonTextExtend();
      }.layoutWeight(1).alignItems(HorizontalAlign.Start);

      if (this.isChecked) {

        if (this.isDisable) {
          Checkbox()
            .select(true)
            .enabled(false)
            .selectedColor($r('sys.color.comp_background_emphasize'));

        } else {
          Checkbox()
            .selectedColor($r('sys.color.comp_background_emphasize'))
            .onChange((value: boolean) => {
              this.onCheckChange(value);
            });
        }

      }

    }
    .height(74)
    .width('100%')
    .borderRadius(16)
    .padding(12)
    .backgroundColor('#FFFFFF');
  }
}

@Extend(Text)
function commonTextExtend() {
  .fontWeight(FontWeight.Regular).fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_primary'));
}
