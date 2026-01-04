import util from '@ohos.util';

class IResourceMgr {
  public resolveUri(uri: ResourceStr | undefined | null): ResourceStr {
    try {
      if (typeof uri === 'string') {
        if (uri.startsWith('app://dev')) {
          return $rawfile(uri.slice(6)) ?? '';
        } else if (uri.startsWith('app://prod')) {
          return $rawfile(uri.slice(6));
        } else if (!uri.startsWith('http://') && !uri.startsWith('https://')) {
          return uri;
        } else {
          return uri;
        }
      } else if (!uri) {
        return '';
      } else {
        return uri;
      }
    } catch (e) {
      return '';
    }
  }

  public readResourceAsString(
    path: string,
    encoding: string = 'utf-8',
  ): string {
    try {
      const result: Uint8Array =
        getContext(this).resourceManager.getRawFileContentSync(path);
      const decode: util.TextDecoder = util.TextDecoder.create(encoding, {
        fatal: false,
        ignoreBOM: false,
      });
      return decode.decodeToString(result, { stream: false });
    } catch (e) {
      return '';
    }
  }
}

export const iResourceMgr: IResourceMgr = new IResourceMgr();
