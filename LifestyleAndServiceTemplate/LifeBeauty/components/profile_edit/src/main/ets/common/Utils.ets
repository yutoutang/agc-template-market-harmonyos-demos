export const padZero = (input: number): string => {
  return input.toString().padStart(2, '0');
}

export const formatDate = (date: number | string | Date | undefined, format = 'YYYY-MM-DD'): string => {
  if (!date) {
    return ''
  }
  let targetDate = date instanceof Date ? date : new Date(date);

  const month = targetDate.getMonth();

  const formats: Record<string, string | number> = {
    // 年份
    'YYYY': targetDate.getFullYear(),
    'YY': targetDate.getFullYear().toString().slice(-2),
    // 月份
    'MM': padZero(month + 1),
    // 日期
    'DD': padZero(targetDate.getDate()),

    // 时间
    'HH': padZero(targetDate.getHours()),
    'hh': padZero(targetDate.getHours() % 12 || 12),
    'mm': padZero(targetDate.getMinutes()),
    'ss': padZero(targetDate.getSeconds()),
  }
  return format.replace(/\[([^\]]+)]|Y{2,4}|M{1,4}|D{1,2}|H{1,2}|h{1,2}|m{1,2}|s{1,2}/g,
    (match: string, escaped: string): string => escaped || formats[match].toString())
}