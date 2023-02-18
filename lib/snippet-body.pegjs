// {
//   // Joins all consecutive strings in a collection without clobbering any
//   // non-string members.
//   function coalesce (parts) {
//     const result = [];
//     for (let i = 0; i < parts.length; i++) {
//       const part = parts[i];
//       const ri = result.length - 1;
//       if (typeof part === 'string' && typeof result[ri] === 'string') {
//         result[ri] = result[ri] + part;
//       } else {
//         result.push(part);
//       }
//     }
//     return result;
//   }
//
//   function flatten (parts) {
//     return parts.reduce(function (flat, rest) {
//       return flat.concat(Array.isArray(rest) ? flatten(rest) : rest);
//     }, []);
//   }
// }
//
// bodyContent = content:(tabStop / bodyContentText)* { return content; }
//
// innerBodyContent = content:(tabStop / variable / nonCloseBraceText)* {
//   return content
// }
//
// bodyContentText = text:(escaped / !tabStop !variable char:. { return char })+ {
//   return text.join('')
// }
//
// // bodyContentText = text:bodyContentChar+ { return text.join(''); }
// // bodyContentChar = escaped / !tabStop char:. { return char; }
//
// variable = simpleVariable / variableWithoutPlaceholder / variableWithPlaceholder / variableWithTransform
//
// simpleVariable = '$' name:variableName {
//   return { variable: name }
// }
//
// variableWithoutPlaceholder = '${' name:variableName '}' {
//   return { variable: name }
// }
//
// variableWithPlaceholder = '${' name:variableName ':' content:innerBodyContent '}' {
//   return { variable: name, content: content }
// }
//
// variableWithTransform = '{' name:variableName substitution:transform '}' {
//   return { variable: name, substitution: substitution }
// }
//
// variableName = first:[a-zA-Z_] rest:[a-zA-Z_0-9]* {
//   return first + rest.join('')
// }
//
// escaped = '\\' char:. { return char; }
// tabStop =  tabStopWithTransformation /  tabStopWithPlaceholder / tabStopWithoutPlaceholder / simpleTabStop
//
// simpleTabStop = '$' index:[0-9]+ {
//   return { index: parseInt(index.join("")), content: [] };
// }
// tabStopWithoutPlaceholder = '${' index:[0-9]+ '}' {
//   return { index: parseInt(index.join("")), content: [] };
// }
// tabStopWithPlaceholder = '${' index:[0-9]+ ':' content:placeholderContent '}' {
//   return { index: parseInt(index.join("")), content: content };
// }
// tabStopWithTransformation = '${' index:[0-9]+ substitution:transform '}' {
//   return {
//     index: parseInt(index.join(""), 10),
//     content: [],
//     substitution: substitution
//   };
// }
//
// placeholderContent = content:(tabStop / placeholderContentText / variable )* { return flatten(content); }
// placeholderContentText = text:placeholderContentChar+ { return coalesce(text); }
// placeholderContentChar = escaped / placeholderVariableReference / !tabStop !variable char:[^}] { return char; }
//
// placeholderVariableReference = '$' digit:[0-9]+ {
//   return { index: parseInt(digit.join(""), 10), content: [] };
// }
//
// // variable = '${' variableContent '}' {
// //   return ''; // we eat variables and do nothing with them for now
// // }
// // variableContent = content:(variable / variableContentText)* { return content; }
// // variableContentText = text:variableContentChar+ { return text.join(''); }
// // variableContentChar = !variable char:('\\}' / [^}]) { return char; }
//
// escapedForwardSlash = pair:'\\/' { return pair; }
//
// // A pattern and replacement for a transformed tab stop.
// transform = '/' regex:regexString '/' replace:replace '/' flags:flags {
//   return {find: new RegExp(regex, flags), replace: replace}
// }
//
// // transformationSubstitution = '/' find:(escapedForwardSlash / [^/])* '/' replace:formatString* '/' flags:[imy]* {
// //   let reFind = new RegExp(find.join(''), flags.join(''));
// //   return { find: reFind, replace: replace[0] };
// // }
//
// regexString = regex:(escaped / [^/])* {
//   return regex.join('')
// }
//
// flags = flags:[a-z]* { return flags.join('') }
//
// replace = foo:(format / replaceText)* {
//   console.log('replace?', coalesce(foo[0] || foo));
//   return coalesce(foo[0] || foo);
// }
//
// replaceText = replacetext:(!formatStringEscape char:escaped { return char } / !format char:[^/] { return char })+ {
//   console.log('replace!', replacetext);
//   return replacetext.join('')
// }
// ////
//
// format = simpleFormat / formatWithoutPlaceholder / formatWithCaseTransform / formatWithIf / formatWithIfElse / formatWithElse / formatEscape / formatWithIfElseAlt / formatWithIfAlt
//
//
// format = content:(formatStringEscape / formatStringReference / escapedForwardSlash / [^/])+ {
//   console.log('format?!?');
//   return content;
// }
// // Backreferencing a substitution. Different from a tab stop.
// formatStringReference = '$' digits:[0-9]+ {
//   return { backreference: parseInt(digits.join(''), 10) };
// };
// // One of the special control flags in a format string for case folding and
// // other tasks.
// formatStringEscape = '\\' flag:[ULulErn$] {
//   return { escape: flag };
// }
//
// nonCloseBraceText = text:(escaped / !tabStop !variable char:[^}] { return char })+ {
//   return text.join('')
// }

{
  function makeInteger(i) {
    return parseInt(i.join(''), 10);
  }

  function coalesce (parts) {
    const result = [];
    for (let i = 0; i < parts.length; i++) {
      const part = parts[i];
      const ri = result.length - 1;
      if (typeof part === 'string' && typeof result[ri] === 'string') {
        result[ri] = result[ri] + part;
      } else {
        result.push(part);
      }
    }
    return result;
  }

}

bodyContent = content:(tabstop / choice / variable / text)* { return content; }

innerBodyContent = content:(tabstop / choice / variable / nonCloseBraceText)* { return content; }

tabstop = simpleTabstop / tabstopWithoutPlaceholder / tabstopWithPlaceholder / tabstopWithTransform

simpleTabstop = '$' index:int {
  return {index: makeInteger(index), content: []}
}

tabstopWithoutPlaceholder = '${' index:int '}' {
  return {index: makeInteger(index), content: []}
}

tabstopWithPlaceholder = '${' index:int ':' content:innerBodyContent '}' {
  return {index: makeInteger(index), content: content}
}

tabstopWithTransform = '${' index:int substitution:transform '}' {
  return {
    index: makeInteger(index),
    content: [],
    substitution: substitution
  }
}

choice = '${' index:int '|' choice:choicecontents '|}' {
  const content = choice.length > 0 ? [choice[0]] : []
  return {index: makeInteger(index), choice: choice, content: content}
}

choicecontents = elem:choicetext rest:(',' val:choicetext { return val } )* {
  return [elem, ...rest]
}

choicetext = choicetext:(choiceEscaped / [^|,] / barred:('|' &[^}]) { return barred.join('') } )+ {
  return choicetext.join('')
}

transform = '/' regex:regexString '/' replace:replace '/' flags:flags {
  return {find: new RegExp(regex, flags), replace: replace}
}

regexString = regex:(escaped / [^/])* {
  return regex.join('')
}

replace = (format / replacetext)*

format = simpleFormat / formatWithoutPlaceholder / formatWithCaseTransform / formatWithIf / formatWithIfElse / formatWithElse / formatEscape / formatWithIfElseAlt / formatWithIfAlt

simpleFormat = '$' index:int {
  return {backreference: makeInteger(index)}
}

formatWithoutPlaceholder = '${' index:int '}' {
  return {backreference: makeInteger(index)}
}

formatWithCaseTransform = '${' index:int ':' caseTransform:caseTransform '}' {
  return {backreference: makeInteger(index), transform: caseTransform}
}

formatWithIf = '${' index:int ':+' iftext:(ifElseText / '') '}' {
  return {backreference: makeInteger(index), iftext: iftext}
}

formatWithIfAlt = '(?' index:int ':' iftext:(ifElseTextAlt / '') ')' {
  return {backreference: makeInteger(index), iftext: iftext}
}

formatWithElse = '${' index:int (':-' / ':') elsetext:(ifElseText / '') '}' {
  return {backreference: makeInteger(index), elsetext: elsetext}
}

formatWithIfElse = '${' index:int ':?' iftext:nonColonText ':' elsetext:(ifElseText / '') '}' {
  return {backreference: makeInteger(index), iftext: iftext, elsetext: elsetext}
}

formatWithIfElseAlt = '(?' index:int ':' iftext:nonColonText ':' elsetext:(ifElseTextAlt / '') ')' {
  return {backreference: makeInteger(index), iftext: iftext, elsetext: elsetext}
}

nonColonText = text:('\\:' { return ':' } / escaped / [^:])* {
  return text.join('')
}

formatEscape = '\\' flag:[ULulErn] {
  return {escape: flag}
}

caseTransform = '/' type:[a-zA-Z]* {
  return type.join('')
}

replacetext = replacetext:(!formatEscape char:escaped { return char } / !format char:[^/] { return char })+ {
  return replacetext.join('')
}

variable = simpleVariable / variableWithoutPlaceholder / variableWithPlaceholder / variableWithTransform

simpleVariable = '$' name:variableName {
  return {variable: name}
}

variableWithoutPlaceholder = '${' name:variableName '}' {
  return {variable: name}
}

variableWithPlaceholder = '${' name:variableName ':' content:innerBodyContent '}' {
  return {variable: name, content: content}
}

variableWithTransform = '${' name:variableName substitution:transform '}' {
  return {variable: name, substitution: substitution}
}

variableName = first:[a-zA-Z_] rest:[a-zA-Z_0-9]* {
  return first + rest.join('')
}

int = [0-9]+

escaped = '\\' char:. {
  switch (char) {
    case '$':
    case '\\':
    case '\x7D': // back brace; PEGjs would treat it as the JS scope end though
      return char
    default:
      return '\\' + char
  }
}

choiceEscaped = '\\' char:. {
  switch (char) {
    case '$':
    case '\\':
    case '\x7D':
    case '|':
    case ',':
      return char
    default:
      return '\\' + char
  }
}

flags = flags:[a-z]* {
  return flags.join('')
}

text = text:(escaped / !tabstop !variable !choice  char:. { return char })+ {
  return text.join('')
}

nonCloseBraceText = text:(escaped / !tabstop !variable !choice char:[^}] { return char })+ {
  return text.join('')
}

ifElseText = text:(escaped / char:[^}] { return char })+ {
  return text.join('')
}

ifElseTextAlt = text:(formatEscape / format / escaped / char:[^)] { return char })+ {
  return coalesce(text);
}
