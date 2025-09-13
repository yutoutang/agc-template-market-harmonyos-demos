import { Api } from '../http/Api';
import { AddressDTO } from '../model/AddressDTO';
import { ParsedAddressDTO } from '../model/ParsedAddressDTO';

export function getDefaultAddress(): Promise<AddressDTO | undefined> {
  return Api.listAddresses().then((list) =>
    list.find((item) => item.isDefault),
  );
}

export function parseAddressByText(text: string): Promise<ParsedAddressDTO> {
  return Api.parseAddressByText(text);
}
