import { FileTransferCallback } from '../model/FileTransferCallback';

export class FileSaveService {
  private callback: FileTransferCallback = {}
}

export const fileSaveService = new FileSaveService()