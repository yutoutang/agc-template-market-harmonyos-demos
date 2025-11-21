import { Sex } from '../common/constant'

export interface SelectorRes {
  selector: string,
  sex: Sex
}

export interface SelectorParam {
  from: string,
  to: string,
  sex: Sex,
  optimal: boolean,
}