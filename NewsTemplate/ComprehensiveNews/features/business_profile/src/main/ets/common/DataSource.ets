import { CommonDataSource } from 'lib_common';
import { NewsModel, RequestListData, AuthorModel } from 'lib_news_api';

export class LayoutNewsDataSource extends CommonDataSource<RequestListData> {
}

export class NewsDataSource extends CommonDataSource<NewsModel> {
}

export class AuthorDataSource extends CommonDataSource<AuthorModel> {
}
