import { Chunk, Chunks } from 'lib_common'

@ComponentV2
export struct Highlight {
  /**
   * 高亮关键字
   */
  @Param keywords: string[] = []
  /**
   * 源文本
   */
  @Param sourceString: string = ''
  /**
   * 文字颜色 默认 sys.color.font_primary
   */
  @Param textColor: ResourceColor = $r('sys.color.font_secondary')
  /**
   * 高亮文字颜色 默认 sys.color.font_primary
   */
  @Param highLightColor: ResourceColor = $r('sys.color.font_primary')
  /**
   * 文字大小
   */
  @Param textFontSize: string | number = 16
  /**
   * 高亮文本weight
   */
  @Param textFontWeight: FontWeight = FontWeight.Regular
  /**
   * 高亮文字大小
   */
  @Param highLightFontSize: string | number = 16
  /**
   * 最大行数
   */
  @Param maxLines?: number = undefined
  /**
   * 超出隐藏
   */
  @Param overflow: TextOverflow = TextOverflow.None

  @Computed
  get highlightChunks(): Chunk[] {
    let chunks = this.keywords.filter((keyword: string) => keyword).reduce<Chunks>((chunks, keyword: string) => {
      keyword = keyword.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
      const regex = new RegExp(keyword, 'g')
      let match: RegExpExecArray | null
      while ((match = regex.exec(this.sourceString))) {
        const start = match.index
        const end = regex.lastIndex
        if (start >= end) {
          regex.lastIndex++
          continue
        }
        chunks.push({
          start,
          end,
          highlight: true
        })
      }
      return chunks
    }, [])

    chunks = chunks
      .sort((a, b) => a.start - b.start)
      .reduce<Chunks>((chunks, currentChunk) => {
        const prevChunk = chunks[chunks.length - 1]
        if (!prevChunk || currentChunk.start > prevChunk.end) {
          const unHighlightStart = prevChunk ? prevChunk.end : 0
          const unHighlightEnd = currentChunk.start
          if (unHighlightStart !== unHighlightEnd) {
            chunks.push({
              start: unHighlightStart,
              end: unHighlightEnd,
              highlight: false
            })
          }
          chunks.push(currentChunk)
        } else {
          prevChunk.end = Math.max(prevChunk.end, currentChunk.end)
        }
        return chunks
      }, [])
    const lastChunk = chunks[chunks.length - 1]
    if (!lastChunk) {
      chunks.push({
        start: 0,
        end: this.sourceString.length,
        highlight: false
      })
    }
    if (lastChunk && lastChunk.end < this.sourceString.length) {
      chunks.push({
        start: lastChunk.end,
        end: this.sourceString.length,
        highlight: false
      })
    }
    return chunks
  }

  build() {
    Text() {
      ForEach(this.highlightChunks, (item: Chunk) => {
        if (item.highlight) {
          Span(this.sourceString.slice(item.start, item.end))
            .fontColor(this.highLightColor)
            .fontSize(this.highLightFontSize)
        } else {
          Span(this.sourceString.slice(item.start, item.end))
        }
      }, (item: Chunk) => JSON.stringify(item))
    }
    .fontSize(this.textFontSize)
    .fontColor(this.textColor)
    .maxLines(this.maxLines)
    .fontWeight(this.textFontWeight)
    .textOverflow({ overflow: this.overflow })
  }
}