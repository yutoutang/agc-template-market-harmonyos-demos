import { RouterModule } from 'commonlib'
import { CommentListView } from 'module_store_comments'

@Builder
export function CommentListPageBuilder() {
  CommentListPage()
}

@ComponentV2
export struct CommentListPage {
  build() {
    NavDestination() {
      CommentListView({
        stack: RouterModule.stack,
      })
    }
    .title('客人说')
  }
}