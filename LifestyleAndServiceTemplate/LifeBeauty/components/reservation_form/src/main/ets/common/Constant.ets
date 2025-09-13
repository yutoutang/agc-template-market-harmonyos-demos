export const WEEK_LABELS: ResourceStr[] = [
  $r('app.string.week_weekday'),
  $r('app.string.week_monday'),
  $r('app.string.week_tuesday'),
  $r('app.string.week_wednesday'),
  $r('app.string.week_thursday'),
  $r('app.string.week_friday'),
  $r('app.string.week_saturday'),
  $r('app.string.week_today'),
  $r('app.string.week_tomorrow'),
];

export class ConstantsHome {
  static MAX_CONTACT_NAME_LENGTH: number = 10;
  static MIN_NUMS: number = 1;
  static MAX_NUMS: number = 9;
  static MAX_REMARK_LENGTH = 50;
}

// 手机号正则
export const PHONE_REG = /^[1][3,4,5,6,7,8,9][0-9]{9}$/;