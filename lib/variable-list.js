const Variable = require('./variable')

class VariableList {
  constructor (snippet) {
    this.snippet = snippet
    this.list = {}
  }

  get length () {
    return Object.keys(this.list).length
  }
}
