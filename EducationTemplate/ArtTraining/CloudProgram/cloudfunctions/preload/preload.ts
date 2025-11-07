import { DatabaseHelper } from './DatabaseHelper';

const TAG = '[preload]';

let myHandler = async function (event, context, callback, logger): Promise<void> {
  logger.info(event);
  const databaseHelper: DatabaseHelper = new DatabaseHelper(logger);

  try {
    const result = await databaseHelper.getStoreConfig();
    if (result) {
      callback({
        ret: {
          code: 0,
          message: TAG + 'request successful',
        },
        result,
      });
    } else {
      callback({
        ret: {
          code: 1,
          message: TAG + ' request failed',
        },
        data: null,
      });
    }
  } catch (err) {
    logger.error(TAG, ` func error: ${err.message}`);
    callback({
      ret: {
        code: 3,
        message: TAG + 'operation exception',
      },
    });
  }
};

export { myHandler };