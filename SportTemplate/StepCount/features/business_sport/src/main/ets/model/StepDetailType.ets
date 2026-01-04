export interface StepDetail {
  catType: CatType
  date: Date
}

export enum CatType {
  STEP_COUNT, DISTANCE, DEPLETE
}