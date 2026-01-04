/** 标记节点 */
export type CustomSliderMarker = Object;

/** 滑块样式; */
export enum CustomSliderThumbStyle {
  /** 不显示滑块; */
  None,
  /** 圆点样式; */
  Dot,
  /** 自定义; */
  Custom,
}

export interface CustomSliderTraceParameters {
  readonly value: number;
  readonly minValue: number;
  readonly maxValue: number;
  readonly trackLayoutWidth: number;
  readonly trackLayoutHeight: number;
}

export interface CustomSliderMarkerParameters {
  readonly marker: CustomSliderMarker;
  readonly sliderDirection: Axis;
  readonly trackLayoutWidth: number;
  readonly trackLayoutHeight: number;
}

/** 数值变化触发来源 */
export enum CustomSliderChangeValueSource {
  /** 通过滑动手势改变值 */
  Drag = 'Drag',
  /** 通过点击改变值 */
  Click = 'Click',
}

@ComponentV2
export struct CustomSlider {
  @Param minValue: number = 0.0;
  @Param maxValue: number = 1.0;
  @Param value: number = 0.0;
  /** 拖动开始; */
  @Event onWillBeginDragging: () => void;
  /** 改变value; */
  @Event onChangeValue: (value: number, source: CustomSliderChangeValueSource) => void;
  /** 拖动结束; */
  @Event onDidEndDragging: () => void;
  /** slider 高度; 默认 auto; */
  @Param sliderSize: Length = 'auto';
  /** 滑动方向; 默认水平滑动; */
  @Param sliderDirection: Axis = Axis.Horizontal;
  /** 轨道高度; 默认值: 8.0; */
  @Param trackSize: number = 8.0;
  /** 轨道颜色; 默认值: 0xE0E0E0; */
  @Param trackColor: ResourceColor = 0xE0E0E0;
  /** 自定义轨道; 默认值: undefined; */
  @BuilderParam customTrackBuilder: () => void;
  /** 轨迹颜色; 默认值: 0x007AFF; */
  @Param traceColor: ResourceColor = 0x007AFF;
  /** 自定义轨迹; 默认值: undefined; */
  @BuilderParam customTraceBuilder: (params: CustomSliderTraceParameters) => void;
  /** 滑块样式; 默认值: CustomSliderThumbStyle.Dot; */
  @Param thumbStyle: CustomSliderThumbStyle = CustomSliderThumbStyle.Dot;
  /** 滑块大小; 默认值: 16.0; */
  @Param thumbSize: number = 16.0;
  /** 滑块颜色; 默认值: 0xFFFFFF; */
  @Param thumbColor: ResourceColor = 0xFFFFFF;
  /** 滑块阴影; 默认值: { color: 0x33000000, radius: 8.0 }; */
  @Param thumbShadow: ShadowOptions | ShadowStyle = { color: 0x33000000, radius: 8.0 };
  /** 自定义滑块; 默认值: undefined;
   *
   * 需要同时指定 thumbStyle 为 CustomSliderThumbStyle.Custom 才能生效;
   * */
  @BuilderParam customThumbBuilder: () => void;
  /** 标记节点(单个), 有多个标记点时请使用 markers 进行设置; */
  @Param marker?: CustomSliderMarker = undefined;
  /** 有多个标记点时请使用 markers 进行设置; */
  @Param markers?: CustomSliderMarker[] = undefined;
  @BuilderParam markerBuilder: (params: CustomSliderMarkerParameters) => void;
  @Param slideEnabled: boolean = true
  @Local private mTrackLayoutWidth: number = 0.0;
  @Local private mTrackLayoutHeight: number = 0.0;
  @Local private mProgress: number = 0.0;
  @Local private mThumbOffset: number = 0.0;
  @Local private mThumbSize: number = 0.0;

  @Builder
  private HorizontalContentBuilder() {
    Stack({ alignContent: Alignment.Start }) {
      Stack({ alignContent: Alignment.Start }) {
        if (!this.customTrackBuilder) {
          Stack()
            .height('100%')
            .width('100%')
            .backgroundColor(this.trackColor)
        } else {
          this.customTrackBuilder();
        }

        if (!this.customTraceBuilder) {
          Stack()
            .width(this.mProgress)
            .height('100%')
            .backgroundColor(this.traceColor)
        } else if (this.maxValue > this.minValue && this.value >= this.minValue && this.value <= this.maxValue &&
          this.mTrackLayoutWidth > 0.0 && this.mTrackLayoutHeight > 0.0) {
          this.customTraceBuilder({
            value: this.value,
            maxValue: this.maxValue,
            minValue: this.minValue,
            trackLayoutWidth: this.mTrackLayoutWidth,
            trackLayoutHeight: this.mTrackLayoutHeight
          })
        }
      }
      .width('100%')
      .height(this.trackSize)
      .clip(true)
      .borderRadius(this.trackSize * 0.5)
      .onAreaChange((_, newArea) => this.onTrackAreaChange(newArea))

      // markers
      if ((this.marker || this.markers) && this.mTrackLayoutWidth > 0.0 && this.mTrackLayoutHeight > 0.0) {
        if (this.marker) {
          this.markerBuilder({
            marker: this.marker,
            trackLayoutWidth: this.mTrackLayoutWidth,
            sliderDirection: this.sliderDirection,
            trackLayoutHeight: this.mTrackLayoutHeight
          })
        } else {
          ForEach(this.markers, (mk: CustomSliderMarker) => {
            this.markerBuilder({
              marker: mk,
              trackLayoutWidth: this.mTrackLayoutWidth,
              sliderDirection: this.sliderDirection,
              trackLayoutHeight: this.mTrackLayoutHeight
            })
          }, (mk: CustomSliderMarker) => JSON.stringify(mk))
        }
      }

      // thumb
      if (this.thumbStyle === CustomSliderThumbStyle.Dot) {
        Stack()
          .height(this.thumbSize)
          .width(this.thumbSize)
          .backgroundColor(this.thumbColor)
          .shadow({ color: 0x80000000, radius: this.thumbSize * 0.5 })
          .offset({ x: this.mThumbOffset })
          .borderRadius(this.thumbSize * 0.5)
          .onAreaChange((_, newArea) => {
            this.mThumbSize = newArea.width as number;
          })
      } else if (this.thumbStyle === CustomSliderThumbStyle.Custom) {
        Stack() {
          this.customThumbBuilder()
        }
        .offset({ x: this.mThumbOffset })
        .onAreaChange((_, newArea) => {
          this.mThumbSize = newArea.width as number;
        })
      }
    }
    .width('100%')
    .height('100%')
    .constraintSize({ minHeight: this.sliderSize })
    .gesture(
      PanGesture(new PanGestureOptions({ direction: PanDirection.Horizontal }))
        .onActionStart((event) => this.onPanStart(event))
        // onActionUpdate
        .onActionUpdate((event) => this.onPanUpdate(event))
        .onActionEnd((event) => this.onPanEnd(event))
        .onActionCancel(() => this.onPanCancel())
    )
    .onClick((event) => this.onClickSlider(event))
  }

  @Builder
  private VerticalContentBuilder() {
    Stack({ alignContent: Alignment.Bottom }) {
      Stack({ alignContent: Alignment.Bottom }) {
        if (!this.customTrackBuilder) {
          Stack()
            .width('100%')
            .height('100%')
            .backgroundColor(this.trackColor)
        } else {
          this.customTrackBuilder();
        }

        if (!this.customTraceBuilder) {
          Stack()
            .width('100%')
            .height(this.mProgress)
            .backgroundColor(this.traceColor)
        } else if (this.maxValue > this.minValue && this.value >= this.minValue && this.value <= this.maxValue &&
          this.mTrackLayoutWidth > 0.0 && this.mTrackLayoutHeight > 0.0) {
          this.customTraceBuilder({
            value: this.value,
            minValue: this.minValue,
            maxValue: this.maxValue,
            trackLayoutWidth: this.mTrackLayoutWidth,
            trackLayoutHeight: this.mTrackLayoutHeight
          })
        }
      }
      .width(this.trackSize)
      .height('100%')
      .clip(true)
      .borderRadius(this.trackSize * 0.5)
      .onAreaChange((_, newArea) => this.onTrackAreaChange(newArea))
      .onClick((event) => this.onClickSlider(event))

      // markers
      if ((this.marker || this.markers) && this.mTrackLayoutWidth > 0.0 && this.mTrackLayoutHeight > 0.0) {
        if (this.marker) {
          this.markerBuilder({
            marker: this.marker,
            sliderDirection: this.sliderDirection,
            trackLayoutWidth: this.mTrackLayoutWidth,
            trackLayoutHeight: this.mTrackLayoutHeight
          })
        } else {
          ForEach(this.markers, (mk: CustomSliderMarker) => {
            this.markerBuilder({
              marker: mk,
              sliderDirection: this.sliderDirection,
              trackLayoutWidth: this.mTrackLayoutWidth,
              trackLayoutHeight: this.mTrackLayoutHeight
            })
          }, (mk: CustomSliderMarker) => JSON.stringify(mk))
        }
      }

      // thumb
      if (this.thumbStyle === CustomSliderThumbStyle.Dot) {
        Stack()
          .width(this.thumbSize)
          .height(this.thumbSize)
          .backgroundColor(this.thumbColor)
          .shadow({ color: 0x80000000, radius: this.thumbSize * 0.5 })
          .borderRadius(this.thumbSize * 0.5)
          .offset({ y: this.mThumbOffset })
          .onAreaChange((_, newArea) => {
            this.mThumbSize = newArea.height as number;
          })
      } else if (this.thumbStyle === CustomSliderThumbStyle.Custom) {
        Stack() {
          this.customThumbBuilder()
        }
        .offset({ y: this.mThumbOffset })
        .onAreaChange((_, newArea) => {
          this.mThumbSize = newArea.height as number;
        })
      }
    }
    .width('100%')
    .height('100%')
    .constraintSize({ minWidth: this.sliderSize })
    .gesture(
      PanGesture(new PanGestureOptions({ direction: PanDirection.Vertical }))
        .onActionStart((event) => this.onPanStart(event))
        .onActionUpdate((event) => this.onPanUpdate(event))
        .onActionEnd((event) => this.onPanEnd(event))
        // onActionCancel
        .onActionCancel(() => this.onPanCancel())
    )
  }

  build() {
    if (this.sliderDirection === Axis.Horizontal) {
      this.HorizontalContentBuilder()
    } else {
      this.VerticalContentBuilder()
    }
  }

  private onTrackAreaChange(newArea: Area): void {
    if (this.mTrackLayoutWidth !== newArea.width || this.mTrackLayoutHeight !== newArea.height) {
      this.mTrackLayoutWidth = newArea.width as number;
      this.mTrackLayoutHeight = newArea.height as number;
    }
  }

  @Monitor('mTrackLayoutWidth', 'mTrackLayoutHeight', 'value', 'minValue', 'maxValue', 'mThumbSize')
  private onUpdateProgress() {
    if (this.mTrackLayoutWidth === 0.0 || this.mTrackLayoutHeight === 0.0) {
      return;
    }

    if (this.maxValue > this.minValue && this.value >= this.minValue && this.value <= this.maxValue) {
      if (this.sliderDirection === Axis.Horizontal) {
        this.mProgress = (this.value - this.minValue) / (this.maxValue - this.minValue) * this.mTrackLayoutWidth;
      } else {
        this.mProgress = (this.value - this.minValue) / (this.maxValue - this.minValue) * this.mTrackLayoutHeight;
      }
    }

    if (this.sliderDirection === Axis.Horizontal) {
      this.mThumbOffset = this.mProgress - this.mThumbSize * 0.5;
    } else {
      this.mThumbOffset = this.mThumbSize * 0.5 - this.mProgress;
    }
  }

  private mPanOffset = 0;

  private onPanStart(event: GestureEvent) {
    if (!this.slideEnabled) {
      return
    }
    switch (this.sliderDirection) {
      case Axis.Horizontal: {
        this.mPanOffset = event.offsetX;
        break;
      }
      case Axis.Vertical: {
        this.mPanOffset = event.offsetY;
        break;
      }
    }
    this.onWillBeginDragging();
  }

  private onPanUpdate(event: GestureEvent) {
    if (!this.slideEnabled) {
      return
    }
    switch (this.sliderDirection) {
      case Axis.Horizontal: {
        const delta = event.offsetX - this.mPanOffset;
        let value = this.value + delta / this.mTrackLayoutWidth * (this.maxValue - this.minValue);
        if (value < this.minValue) {
          value = this.minValue;
        } else if (value > this.maxValue) {
          value = this.maxValue;
        }
        this.onChangeValue(value, CustomSliderChangeValueSource.Drag);
        this.mPanOffset = event.offsetX;
        break;
      }
      case Axis.Vertical: {
        const delta = this.mPanOffset - event.offsetY;
        let value = this.value + delta / this.mTrackLayoutHeight * (this.maxValue - this.minValue);
        if (value < this.minValue) {
          value = this.minValue;
        } else if (value > this.maxValue) {
          value = this.maxValue;
        }
        this.onChangeValue(value, CustomSliderChangeValueSource.Drag);
        this.mPanOffset = event.offsetY;
        break;
      }
    }
  }

  private onPanEnd(event: GestureEvent) {
    if (!this.slideEnabled) {
      return
    }
    this.onPanUpdate(event);
    this.onDidEndDragging();
  }

  private onPanCancel() {
    if (!this.slideEnabled) {
      return
    }
    this.onDidEndDragging();
  }

  private onClickSlider(event: ClickEvent): void {
    if (!this.slideEnabled) {
      return
    }
    if (this.maxValue > this.minValue) {
      let newValue: number;
      switch (this.sliderDirection) {
        case Axis.Horizontal: {
          newValue = this.minValue + (event.x / this.mTrackLayoutWidth) * (this.maxValue - this.minValue);
          break;
        }
        case Axis.Vertical: {
          newValue = this.minValue + (event.y / this.mTrackLayoutHeight) * (this.maxValue - this.minValue);
          break;
        }
      }
      this.onChangeValue(newValue!, CustomSliderChangeValueSource.Click);
    }
  }
}