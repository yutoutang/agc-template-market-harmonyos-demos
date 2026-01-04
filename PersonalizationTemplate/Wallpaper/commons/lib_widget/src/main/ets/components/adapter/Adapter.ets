export class Adapter<T> implements IDataSource {
  private data: T[] = []
  private listeners: DataChangeListener[] = []

  getData(index: number): T {
    return this.data[index]
  }

  totalCount(): number {
    return this.data.length
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) === -1) {
      this.listeners.push(listener)
    }
  }

  reloadData(list: T[]) {
    this.data = list
    this.listeners.forEach(listener => {
      listener.onDataReloaded()
    })
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this.listeners.indexOf(listener)
    if (index > -1) {
      this.listeners.splice(index, 1)
    }
  }
}