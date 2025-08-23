import dayjs from 'dayjs';

export function getVipDuration(dateType: string) {
  const today = dayjs();
  let res: string = ''

  const oneWeekLater = today.clone().add(1, 'week');
  const oneMonthLater = today.clone().add(1, 'month');
  const threeMonthsLater = today.clone().add(3, 'months');
  const sixMonthsLater = today.clone().add(6, 'months');
  const oneYearLater = today.clone().add(1, 'year');

  if (dateType === 'week') {
    res = oneWeekLater.format('YYYY-MM-DD');
  }
  if (dateType === 'month') {
    res = oneMonthLater.format('YYYY-MM-DD');
  }
  if (dateType === 'quarter') { // 季度
    res = threeMonthsLater.format('YYYY-MM-DD') ;
  }
  if (dateType === 'halfYear') {
    res = sixMonthsLater.format('YYYY-MM-DD');
  }
  if (dateType === 'year') {
    res = oneYearLater.format('YYYY-MM-DD');
  }
  // if (dateType === 'perpetual') {
  //   res = '终生会员';
  // }
  return res
}

export function calculateNewVipExpiryDate(currentExpiryDate: Date, dateType: string): Date {
  const current = dayjs(currentExpiryDate);
  let newExpiryDate: dayjs.Dayjs;

  if (dateType === 'week') {
    newExpiryDate = current.add(1, 'week');
  } else if (dateType === 'month') {
    newExpiryDate = current.add(1, 'month');
  } else if (dateType === 'quarter') { // 季度
    newExpiryDate = current.add(3, 'months');
  } else if (dateType === 'halfYear') {
    newExpiryDate = current.add(6, 'months');
  } else if (dateType === 'year') {
    newExpiryDate = current.add(1, 'year');
  } else {
    newExpiryDate = current; // 默认情况下不改变
  }

  return newExpiryDate.toDate();
}