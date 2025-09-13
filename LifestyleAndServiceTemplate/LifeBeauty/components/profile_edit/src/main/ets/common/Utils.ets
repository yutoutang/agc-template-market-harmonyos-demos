export const padZero = (input: number): string => {
  return input.toString().padStart(2, '0');
}

export const formatDate = (datetime?: number): string => {
  if (!datetime) {
    return '';
  }
  const date = new Date(datetime);
  return `${date.getFullYear()}-${padZero(date.getMonth() + 1)}-${padZero(date.getDate())}`;
}