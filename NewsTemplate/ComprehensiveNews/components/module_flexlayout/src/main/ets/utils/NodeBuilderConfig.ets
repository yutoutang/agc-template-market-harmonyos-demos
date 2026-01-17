import { UtilLog } from '@hw-agconnect/util-log'
import { LayoutParams } from '../model/CommonModel'

const TAG = '[NodeBuilderRegister]'

export class NodeBuilderRegister {
  buildNodeMap: Map<string, WrappedBuilder<[LayoutParams]>> = new Map()
  private static _instance: NodeBuilderRegister

  public static get instance() {
    if (!NodeBuilderRegister._instance) {
      NodeBuilderRegister._instance = new NodeBuilderRegister()
    }
    return NodeBuilderRegister._instance
  }

  // 注册卡片
  public registerBuilderCard(key: string, value: WrappedBuilder<[LayoutParams]>) {
    if (!this.buildNodeMap.has(key)) {
      this.buildNodeMap.set(key, value)
    }
  }

  // 获取卡片
  public getBuilderNode(key: string): WrappedBuilder<[LayoutParams]> | undefined {
    if (!this.buildNodeMap.has(key)) {
      UtilLog.error(TAG, `can not find ${key} register`)
    }
    return this.buildNodeMap.get(key)
  }
}

