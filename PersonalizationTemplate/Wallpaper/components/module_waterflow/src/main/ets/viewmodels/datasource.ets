export class ListDataSource<T> implements IDataSource {
  private originArray: T[] = []
  private listeners: DataChangeListener[] = []

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) === -1) {
      this.listeners.push(listener)
    }
  }

  totalCount(): number {
    return this.originArray.length
  }

  getData(index: number): T {
    return this.originArray[index]
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this.listeners.indexOf(listener)
    if (index > -1) {
      this.listeners.splice(index, 1)
    }
  }

  reloadData(list: T[]) {
    this.originArray = list
    this.listeners.forEach(listener => {
      listener.onDataReloaded()
    })
  }
}