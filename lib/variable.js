const path = require('path')

const ESCAPES = {
  u: (flags) => {
    flags.lowercaseNext = false
    flags.uppercaseNext = true
  },
  l: (flags) => {
    flags.uppercaseNext = false
    flags.lowercaseNext = true
  },
  U: (flags) => {
    flags.lowercaseAll = false
    flags.uppercaseAll = true
  },
  L: (flags) => {
    flags.uppercaseAll = false
    flags.lowercaseAll = true
  },
  E: (flags) => {
    flags.uppercaseAll = false
    flags.lowercaseAll = false
  },
  r: (flags, result) => {
    result.push('\\r')
  },
  n: (flags, result) => {
    result.push('\\n')
  },
  $: (flags, result) => {
    result.push('$')
  }
}

function transformText (str, flags) {
  if (flags.uppercaseAll) {
    return str.toUpperCase()
  } else if (flags.lowercaseAll) {
    return str.toLowerCase()
  } else if (flags.uppercaseNext) {
    flags.uppercaseNext = false
    return str.replace(/^./, s => s.toUpperCase())
  } else if (flags.lowercaseNext) {
    return str.replace(/^./, s => s.toLowerCase())
  }
  return str
}

function resolveClipboard () {
  return atom.clipboard.read()
}

const RESOLVERS = {
  'TM_SELECTED_TEXT' ({editor, selectionRange}) {
    if (!selectionRange || selectionRange.isEmpty()) return undefined
    return editor.getTextInBufferRange(selectionRange)
  },
  'CLIPBOARD': resolveClipboard,
  'TM_CLIPBOARD': resolveClipboard,
  'TM_CURRENT_LINE' ({editor, cursor}) {
    return editor.lineTextForBufferRow(cursor.getBufferRow())
  },
  'TM_CURRENT_WORD' ({editor, cursor}) {
    return editor.getTextInBufferRange(cursor.getCurrentWordBufferRange())
  },
  'TM_LINE_INDEX' ({cursor}) {
    return `${cursor.getBufferRow()}`
  },
  'TM_LINE_NUMBER' ({cursor}) {
    return `${cursor.getBufferRow() + 1}`
  },
  'TM_FILENAME' ({editor}) {
    return editor.getTitle()
  },
  'TM_FILENAME_BASE' ({editor}) {
    let fileName = editor.getTitle()
    if (!fileName) { return undefined }

    const index = fileName.lastIndexOf('.')
    if (index >= 0) {
      return fileName.slice(0, index)
    }
    return fileName
  },
  'TM_FILEPATH' ({editor}) {
    return editor.getPath()
  },
  'TM_DIRECTORY' ({editor}) {
    const filePath = editor.getPath()
    if (filePath === undefined) return undefined
    return path.dirname(filePath)
  }
}

function makeReplacer (replace) {
  return function replacer (...match) {
    let flags = {
      uppercaseAll: false,
      lowercaseAll: false,
      uppercaseNext: false,
      lowercaseNext: false
    }

    replace = [...replace]
    let result = []
    replace.forEach(token => {
      if (typeof token === 'string') {
        result.push(transformText(token, flags))
      } else if (token.escape) {
        ESCAPES[token.escape](flags, result)
      } else if (token.backreference) {
        let transformed = transformText(
          match[token.backreference],
          flags
        )
        result.push(transformed)
      }
    })
    return result.join('')
  }
}

class Variable {
  constructor ({point, snippet, variable: name, substitution}) {
    Object.assign(this, {point, snippet, name, substitution})
  }

  resolve (params) {
    let base = ''
    if (this.name in RESOLVERS) {
      base = RESOLVERS[this.name](params)
    }

    if (!this.substitution) {
      return base
    }

    let {find, replace} = this.substitution
    this.replacer ??= makeReplacer(replace)
    let matches = base.match(find)
    return base.replace(find, this.replacer)
  }
}

module.exports = Variable
