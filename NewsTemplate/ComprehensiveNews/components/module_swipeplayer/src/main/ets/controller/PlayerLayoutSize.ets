@ObservedV2
export class PlayerLayoutSize {
  @Trace private playerWidth: Length = '100%';
  @Trace private playerHeight: Length = '100%';
  @Trace private xComponentWidth: Length = '100%';
  @Trace private xComponentHeight: Length = '100%';
  @Trace private layoutSizeChangeFlag: boolean = false;
  @Trace private slideMovingFlag: boolean = false;

  updatePlayerWidth(playerWidth: Length): void {
    this.playerWidth = playerWidth;
  }

  getPlayerWidth(): Length {
    return this.playerWidth;
  }

  updatePlayerHeight(playerHeight: Length): void {
    this.playerHeight = playerHeight;
  }

  getPlayerHeight(): Length {
    return this.playerHeight;
  }

  updateXComponentWidth(xComponentWidth: Length): void {
    this.xComponentWidth = xComponentWidth;
  }

  getXComponentWidth(): Length {
    return this.xComponentWidth;
  }

  updateXComponentHeight(xComponentHeight: Length): void {
    this.xComponentHeight = xComponentHeight;
  }

  getXComponentHeight(): Length {
    return this.xComponentHeight;
  }

  updateLayoutSizeChangeFlag(flag: boolean) {
    this.layoutSizeChangeFlag = flag
  }

  getLayoutSizeChangeFlag(): boolean {
    return this.layoutSizeChangeFlag
  }

  updateSlideMovingFlag(flag: boolean) {
    this.slideMovingFlag = flag
  }

  getSlideMovingFlag(): boolean {
    return this.slideMovingFlag
  }
}