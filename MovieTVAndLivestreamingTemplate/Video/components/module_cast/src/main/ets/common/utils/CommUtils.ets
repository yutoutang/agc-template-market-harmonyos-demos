import { CommonConstants } from '../CommonConstants';

export function secondToTime(seconds: number): string {
  let hourUnit = CommonConstants.HOUR_UNIT * CommonConstants.HOUR_UNIT;
  let hour: number = Math.floor(seconds / hourUnit);
  let minute: number = Math.floor((seconds - hour * hourUnit) / CommonConstants.HOUR_UNIT);
  let second: number = seconds - hour * hourUnit - minute * CommonConstants.HOUR_UNIT;
  let hourStr: string = hour < CommonConstants.TIME_CONST_TEN ? `0${hour.toString()}` : `${hour.toString()}`
  let minuteStr: string = minute < CommonConstants.TIME_CONST_TEN ? `0${minute.toString()}` : `${minute.toString()}`
  let secondStr: string = second < CommonConstants.TIME_CONST_TEN ? `0${second.toString()}` : `${second.toString()}`
  if (hour > 0) {
    return `${hourStr}:${minuteStr}:${secondStr}`;
  }
  if (minute > 0) {
    return `${minuteStr}:${secondStr}`;
  } else {
    return `00:${secondStr}`;
  }
}