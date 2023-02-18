const {Point, Range} = require('atom')
const TabStopList = require('./tab-stop-list')
const Variable = require('./variable')

function tabStopsReferencedWithinTabStopContent (segment) {
  const results = []
  for (const item of segment) {
    if (item.index) {
      results.push(item.index, ...tabStopsReferencedWithinTabStopContent(item.content))
    }
  }
  return new Set(results)
}

module.exports = class Snippet {
  constructor (attrs) {

    let {name, prefix, command, bodyText, description, packageName, descriptionMoreURL, rightLabelHTML, leftLabel, leftLabelHTML, bodyTree, selector} = attrs

    this.name = name
    this.prefix = prefix
    this.command = command
    this.packageName = packageName
    this.bodyText = bodyText
    this.description = description
    this.descriptionMoreURL = descriptionMoreURL
    this.rightLabelHTML = rightLabelHTML
    this.leftLabel = leftLabel
    this.leftLabelHTML = leftLabelHTML
    this.selector = selector
    this.tabStopList = new TabStopList(this)
    this.body = this.extractTabStops(bodyTree)
    this.variables = []

    if (packageName && command) {
      this.commandName = `${packageName}:${command}`
    }
  }

  extractTokens (bodyTree) {
    const bodyText = []
    let row = 0, column = 0

    let extract = bodyTree => {
      for (let segment of bodyTree) {
        if (segment.index != null) {
          // Tabstop.
          let {index, content, substitution} = segment
          // Ensure tabstop `$0` is always last.
          if (index === 0) { index = Infinity }

          const start = [row, column]
          extract(content)

          const referencedTabStops = tabStopsReferencedWithinTabStopContent(content)

          const range = new Range(start, [row, column])

          const tabStop = this.tabStopList.findOrCreate({
            index, snippet: this
          })

          tabStop.addInsertion({
            range,
            substitution,
            references: [...referencedTabStops]
          })
        } else if (segment.variable != null) {
          // Variable.
          let point = new Point([row, column])
          this.variables.push(
            new Variable({...segment, point})
          )
        } else if (typeof segment === 'string') {
          bodyText.push(segment)
          let segmentLines = segment.split('\n')
          column += segmentLines.shift().length
          while ((nextLine = segmentLines.shift()) != null) {
            row += 1
            column = nextLine.length
          }
        }
      }
    }

  }

  extractTabStops (bodyTree) {
    const bodyText = []
    let row = 0
    let column = 0

    // recursive helper function; mutates vars above
    let extractTabStops = bodyTree => {
      for (const segment of bodyTree) {
        if (segment.index != null) {
          let {index, content, substitution} = segment
          // Ensure tabstop `$0` is always last.
          if (index === 0) { index = Infinity }

          const start = [row, column]
          extractTabStops(content)

          const referencedTabStops = tabStopsReferencedWithinTabStopContent(content)

          const range = new Range(start, [row, column])
          const tabStop = this.tabStopList.findOrCreate({
            index,
            snippet: this
          })
          tabStop.addInsertion({
            range,
            substitution,
            references: Array.from(referencedTabStops)
          })
        } else if (typeof segment === 'string') {
          bodyText.push(segment)
          var segmentLines = segment.split('\n')
          column += segmentLines.shift().length
          let nextLine
          while ((nextLine = segmentLines.shift()) != null) {
            row += 1
            column = nextLine.length
          }
        }
      }
    }

    extractTabStops(bodyTree)
    this.lineCount = row + 1
    this.insertions = this.tabStopList.getInsertions()

    return bodyText.join('')
  }
}
