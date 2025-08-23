import { RouterMap } from 'commonlib'

export interface SettingItem{
  label:string
  routerName?:RouterMap
  routerParams?:Object
}