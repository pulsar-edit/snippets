# Snippets package

Expand snippets matching the current prefix with <kbd>tab</kbd> in Pulsar.

To add your own snippets, select the _Pulsar > Snippets..._ menu option if you're using macOS, or the _File > Snippets..._ menu option if you're using Windows, or the _Edit > Snippets..._ menu option if you are using Linux.

## Snippet Format

Snippets files are stored in a package's `snippets/` folder and also loaded from `~/.pulsar/snippets.cson`. They can be either `.json` or `.cson` file types.

```coffee
'.source.js':
  'console.log':
    'prefix': 'log'
    'command': 'insert-console-log'
    'body': 'console.log(${1:"crash"});$2'
```

The outermost keys are the selectors where these snippets should be active, prefixed with a period (`.`) (details below).

The next level of keys are the snippet names.

Under each snippet name is a `body` to insert when the snippet is triggered.

`$` followed by a number are the tabs stops which can be cycled between by pressing <kbd>Tab</kbd> once a snippet has been triggered.

The above example adds a `console.log` snippet to JavaScript files that would expand to:

```js
console.log("crash");
```

The string `"crash"` would be initially selected and pressing tab again would place the cursor after the `;`

A snippet must define **at least one** of the following keys:

### The ‘prefix’ key

If a `prefix` is defined, it specifies a string that can trigger the snippet: type the string in the editor and press <kbd>Tab</kbd>. In this example, typing `log` (as its own word) and then pressing <kbd>Tab</kbd> would replace `log` with the string `console.log("crash")` as described above.

Prefix completions can be suggested if partially typed thanks to the `autocomplete-snippets` package.

### The ‘command’ key

If a `command` is defined, it specifies a command name that can trigger the snippet. That command can be invoked from the command palette or mapped to a keyboard shortcut via your `keymap.cson`.

If you defined the `console.log` snippet described above in your own `snippets.cson`, it would be available in the command palette as “Snippets: Insert Console Log”, or could be referenced in a keymap file as `snippets:insert-console-log`.

If a package called `some-package` had defined that snippet, it would be available in the keymap as `some-package:insert-console-log`, or in the command palette as “Some Package: Insert Console Log”.

Invoking the command would insert the snippet at the cursor, replacing any text that may be selected.

### Optional parameters

These parameters are meant to provide extra information about your snippet to [autocomplete-plus](https://github.com/atom/autocomplete-plus/wiki/Provider-API).

* `leftLabel` will add text to the left part of the autocomplete results box.
* `leftLabelHTML` will overwrite what's in `leftLabel` and allow you to use a bit of CSS such as `color`.
* `rightLabelHTML`. By default, in the right part of the results box you will see the name of the snippet. When using `rightLabelHTML` the name of the snippet will no longer be displayed, and you will be able to use a bit of CSS.
* `description` will add text to a description box under the autocomplete results list.
* `descriptionMoreURL` URL to the documentation of the snippet.

![autocomplete-description](http://i.imgur.com/cvI2lOq.png)

Example:
```coffee
'.source.js':
  'console.log':
    'prefix': 'log'
    'body': 'console.log(${1:"crash"});$2'
    'description': 'Output data to the console'
    'rightLabelHTML': '<span style="color:#ff0">JS</span>'
```

### Determining the correct scope for a snippet

The outmost key of a snippet is the "scope" that you want the descendent snippets to be available in. The key should be prefixed with a period (`text.html.basic` => `.text.html.basic`). You can find out the correct scope by opening the Settings (<kbd>cmd-,</kbd> on macOS) and selecting the corresponding *Language [xxx]* package, e.g. for *Language Html*:

![Screenshot of Language Html settings](https://cloud.githubusercontent.com/assets/1038121/5137632/126beb66-70f2-11e4-839b-bc7e84103f67.png)

If it's difficult to determine the package handling the file type in question (for example, for `.md`-documents), you can also proceed as following. Put your cursor in a file in which you want the snippet to be available, open the [Command Palette](https://github.com/pulsar-edit/command-palette)
(<kbd>cmd-shift-p</kbd>), and run the `Editor: Log Cursor Scope` command. This will trigger a notification which will contain a list of scopes. The first scope that's listed is the scope for that language. Here are some examples: `source.coffee`, `text.plain`, `text.html.basic`.

### Snippet syntax

This package supports a subset of the features of TextMate snippets, [documented here](http://manual.macromates.com/en/snippets#transformations).

The following features are not yet supported:

* Variables
* Interpolated shell code
* Conditional insertions in transformations

### Multi-line Snippet Body

You can also use multi-line syntax using `"""` for larger templates:

```coffee
'.source.js':
  'if, else if, else':
    'prefix': 'ieie'
    'body': """
      if (${1:true}) {
        $2
      } else if (${3:false}) {
        $4
      } else {
        $5
      }
    """
```

### Escaping Characters

Including a literal closing brace inside the text provided by a snippet's tab stop will close that tab stop early. To prevent that, escape the brace with two backslashes, like so:

```coffee
'.source.js':
  'function':
    'prefix': 'funct'
    'body': """
      ${1:function () {
        statements;
      \\}
      this line is also included in the snippet tab;
      }
      """
```

### Multiple snippets for the same scope

Snippets for the same scope must be placed within the same key. See [this section of the Atom Flight Manual](https://pulsar-edit.dev/docs/atom-archive/using-atom/#configuring-with-cson) for more information.
