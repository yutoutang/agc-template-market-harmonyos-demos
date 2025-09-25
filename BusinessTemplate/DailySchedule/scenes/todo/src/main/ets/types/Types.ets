import {TodoItem} from '../model/TodoItem'

export interface SheetCallbacks {
  onConfirm: () => void;
  onClose: () => void;
}

export interface SectionParam {
  label: string | Resource;
  data: TodoItem[];
  isShow: boolean;
}