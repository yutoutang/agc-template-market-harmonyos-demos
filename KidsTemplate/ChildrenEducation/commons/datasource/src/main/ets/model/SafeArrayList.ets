import { ArrayList } from '@kit.ArkTS';

export class SafeArrayList<T> {
  private list: ArrayList<T>;
  
  constructor(list: ArrayList<T>) {
    this.list = list
  }

  forEach(cb: (item: T, index: number) => void) {
    try {
      this.list.forEach(cb);
    } catch (e) {
      console.error('forEach failed', e);
    }
  }

  add(item: T) {
    try {
      this.list.add(item);
    } catch (e) {
      console.error('add failed', e);
    }
  }

  removeByIndex(index: number) {
    try {
      if (index >= 0 && index < this.list.length) {
        this.list.removeByIndex(index);
      }
    } catch (e) {
      console.error('remove failed', e);
    }
  }

  getCapacity(): number {
    try {
      return this.list.getCapacity();
    } catch {
      return 0;
    }
  }

  getRaw() {
    return this.list;
  }
}
