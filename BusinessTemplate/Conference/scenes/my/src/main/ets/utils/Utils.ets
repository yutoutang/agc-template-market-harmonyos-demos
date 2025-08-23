export interface ComponentInfo {
  left: number,
  right: number,
  top: number,
  bottom: number,
  width: number,
  height: number
}

export class Utils {
  static rectLeft: number;
  static rectTop: number;
  static rectRight: number;
  static rectBottom: number;
  static rectValue: Record<string, number>;

  //获取组件所占矩形区域坐标
  static getComponentRect(key: string): ComponentInfo {
    let strJson = getInspectorByKey(key);
    let obj: Record<string, string> = JSON.parse(strJson);
    let rectInfo: string[] = JSON.parse('[' + obj.$rect + ']');
    Utils.rectLeft = JSON.parse('[' + rectInfo[0] + ']')[0]; // 相对于组件左上角的水平方向坐标
    Utils.rectTop = JSON.parse('[' + rectInfo[0] + ']')[1]; // 相对于组件左上角的垂直方向坐标
    Utils.rectRight = JSON.parse('[' + rectInfo[1] + ']')[0]; // 相对于组件右下角的水平方向坐标
    Utils.rectBottom = JSON.parse('[' + rectInfo[1] + ']')[1]; // 相对于组件右下角的垂直方向坐标

    return {
      left: px2vp(Utils.rectLeft),
      right: px2vp(Utils.rectRight),
      top: px2vp(Utils.rectTop),
      bottom: px2vp(Utils.rectBottom),
      width: px2vp(Utils.rectRight - Utils.rectLeft),
      height: Math.abs(px2vp(Utils.rectTop - Utils.rectBottom)),
    };
  }
}