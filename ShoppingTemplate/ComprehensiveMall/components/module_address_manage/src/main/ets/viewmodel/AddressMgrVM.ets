import { ViewModelState as State, LoadMode } from '../common/CommonConst';
import { Api } from '../http/Api';
import { AddressDTO } from '../model/AddressDTO';
import { AddressVM } from './AddressVM';

@ObservedV2
export class AddressMgrVM {
  @Trace
  public list: AddressVM[] = [];

  @Trace
  public state: State = State.UNINITIALIZED;

  @Trace
  public isLoading: boolean = false;

  public initialize(): void {
    if (
      (this.state === State.UNINITIALIZED ||
        this.state === State.INIT_FAILED) &&
      !this.isLoading
    ) {
      this.isLoading = true;
      this.state = State.UNINITIALIZED;
      this.loadAddressList(LoadMode.INIT);
    }
  }

  public create(
    dto: AddressDTO,
    onSuccess?: () => void,
    onError?: () => void,
  ): void {
    if (!this.isLoading) {
      this.isLoading = true;
      Api.createAddress(dto)
        .then(() => {
          this.loadAddressList(LoadMode.REFRESH, onSuccess, onError);
        })
        .catch(() => {
          this.isLoading = false;
          onError && onError();
        });
    }
  }

  public delete(
    id: string,
    onSuccess?: () => void,
    onError?: () => void,
  ): void {
    if (!this.isLoading) {
      this.isLoading = true;
      Api.deleteAddress(id)
        .then(() => {
          this.loadAddressList(LoadMode.REFRESH, onSuccess, onError);
        })
        .catch(() => {
          this.isLoading = false;
          onError && onError();
        });
    }
  }

  public update(
    dto: AddressDTO,
    onSuccess?: () => void,
    onError?: () => void,
  ): void {
    if (!this.isLoading) {
      this.isLoading = true;
      Api.updateAddress(dto)
        .then(() => {
          this.loadAddressList(LoadMode.REFRESH, onSuccess, onError);
        })
        .catch(() => {
          this.isLoading = false;
          onError && onError();
        });
    }
  }

  private loadAddressList(
    mode: LoadMode,
    onSuccess?: () => void,
    onError?: () => void,
  ): void {
    Api.listAddresses()
      .then((data: AddressDTO[]) => {
        this.list = data.map((dto) => {
          const address: AddressVM = new AddressVM();
          address.assignFromDTO(dto);
          return address;
        });
        this.state = State.READY;
        onSuccess && onSuccess();
      })
      .catch(() => {
        if (mode === LoadMode.INIT) {
          this.state = State.INIT_FAILED;
        }
        onError && onError();
      })
      .finally(() => (this.isLoading = false));
  }
}
