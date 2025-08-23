import { ExplainTicketInfo } from 'network';

export interface DayItem {
  name: string,
  dayLabel: string,
  date: Date
}


export interface ExplainDetail extends ExplainTicketInfo {
  title:string,
  time:number,
  cover:string
}