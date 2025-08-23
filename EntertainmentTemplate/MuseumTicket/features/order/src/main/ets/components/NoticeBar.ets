@ComponentV2
export struct NoticeBar {
  @Param noticeText: string[][] = [
    [
      '1.开放时间',
      '周二至周日9:00-17:00，16:30停止入展厅，周一闭馆。',
    ],
    [
      '2.安检和安全',
      '参观者需接受安全检查，不得携带易燃易爆、管制械具等危险品入馆。',
      '在展厅内，不得摄像、拍照时请勿使用闪光灯、三脚架及自拍杆。',
    ],
    [
      '3.行为规范',
      '在展馆内进行讲解、研学、调查、采访等活动须提前申请。参观者需注意个人卫生，不得在馆内乱丢杂物。',
    ],
  ];

  build() {
    Column({ space: 12 }) {
      Text('温馨提示').fontColor('#000000').fontSize(16);
      ForEach(this.noticeText, (item: string[]) => {
        Column() {
          ForEach(item, (v: string) => {
            Text(v).fontSize($r('sys.float.Body_S')).fontColor('#000000');
          }, (v: string) => v);
        }.alignItems(HorizontalAlign.Start).width('100%');
      }, (item: string[], index) => index.toString());

    }
    .alignItems(HorizontalAlign.Start)
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(16);
  }
}