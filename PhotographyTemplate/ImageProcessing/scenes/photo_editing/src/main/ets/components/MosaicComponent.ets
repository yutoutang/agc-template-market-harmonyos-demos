import { PhotoBeautificationVM } from '../viewmodel/PhotoBeautificationVM'




@ComponentV2
export struct MosaicComponent{
  @Local vm: PhotoBeautificationVM = PhotoBeautificationVM.instance

  build() {
    Canvas(this.vm.context){

    }.width('100%')
    .height('100%')
    .id('canvas')
    .onAreaChange((oldValue: Area, newValue: Area) => {
      this.vm.canvasAreaChange(newValue)
    })
    .onGestureRecognizerJudgeBegin((event: BaseGestureEvent, current: GestureRecognizer,
      others: Array<GestureRecognizer>) => {
      if (!this.vm.mosaicSource) {
        return GestureJudgeResult.REJECT; // Directly block all gestures
      }
      if (current.getEventTargetInfo()?.getId() === 'canvas' &&
        current.getType() === GestureControl.GestureType.PAN_GESTURE) {
        return GestureJudgeResult.CONTINUE;
      }
      return GestureJudgeResult.CONTINUE;
    })
    .gesture(
      PanGesture()
        .onActionStart((event: GestureEvent) => {
          let finger: FingerInfo = event.fingerList[0];
          if (finger === undefined) {
            return
          }
          let x = finger.localX
          let y = finger.localY
          this.vm.moveStart(x, y)
        })
        .onActionUpdate((event: GestureEvent) => {
          let finger: FingerInfo = event.fingerList[0];
          if (finger === undefined) {
            return
          }
          let x = finger.localX
          let y = finger.localY
          this.vm.moveUpdate(x, y)
        })
        .onActionEnd((event: GestureEvent) => {
          let finger: FingerInfo = event.fingerList[0];
          if (finger === undefined) {
            return
          }
          this.vm.moveEnd()
        })
    )

  }

}