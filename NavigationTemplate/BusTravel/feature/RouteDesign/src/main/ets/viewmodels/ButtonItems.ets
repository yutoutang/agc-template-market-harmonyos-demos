export class ButtonOptions {
  buttons: ButtonItem[] = []
  selectedBackgroundColor: ResourceStr = $r('app.color.system_color_green')
  selectedFontColor: ResourceStr = $r('sys.color.font_on_primary')
  fontColor: ResourceStr = $r('sys.color.font_secondary')
  fontSize: ResourceStr = $r('sys.float.Body_M')
  selectedFontSize: ResourceStr = $r('sys.float.Body_M')
  textPadding: ResourceStr = '4vp'

  constructor(buttons?: ButtonItem[], selectedBackgroundColor?: ResourceStr, selectedFontColor?: ResourceStr,
    fontColor?: ResourceStr, fontSize?: ResourceStr, selectedFontSize?: ResourceStr, textPadding?: ResourceStr) {
    this.buttons = buttons ?? this.buttons
    this.selectedBackgroundColor = selectedBackgroundColor ?? this.selectedBackgroundColor
    this.selectedFontColor = selectedFontColor ?? this.selectedFontColor
    this.fontColor = fontColor ?? this.fontColor
    this.fontSize = fontSize ?? this.fontSize
    this.selectedFontSize = selectedFontSize ?? this.selectedFontSize
    this.textPadding = textPadding ?? this.textPadding
  }
}

export class ButtonItem {
  text: ResourceStr = ''
  icon: ResourceStr = ''
  selectedIcon: ResourceStr = ''
}