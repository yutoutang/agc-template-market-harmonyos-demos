export interface BaseSuccessResponse<T = Object> {
  code: number;
  msg?: string;
  data: T;
}
