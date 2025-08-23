export interface TabItem {
  text: string,
  value: string | number,
}

export interface TabStyle {
  tabHeight: number
  tabActiveColor: ResourceColor
  tabFontColor: ResourceColor
  tabFontWeight: number | FontWeight | string
  tabFontSize: ResourceStr | number
}

