[Original URL: https://www.locksmith.guide/tutorials/more/locking-variants/javascript-dom-errors]

# Handling JavaScript DOM errors caused by variant locks

Locksmith enforces variant locks at the Liquid level, which can result in a different set of DOM elements being present than the theme expects. For example, a list of product images might be filtered down to omit images belonging to protected variants; this could result in a DOM error when the theme tries to address an image that Locksmith has prevented from appearing.

Find JavaScript errors by opening your web browser's developer tools, and watching the message console as you load and navigate your online store.

## Finding a solution

Solving this kind of problem usually involves some trial and error, all centered around making the theme's JavaScript more tolerant of elements being unexpectedly missing.

1. Start by locating the specific line of JavaScript that's raising the error. All error messages come with a filename. Match this filename to the relevant JavaScript asset in your Online Store theme. Look for line numbers at the end of the filename: theme.js:73 could mean that the error came from line 73 from that file.
2. Determine how that line of JavaScript is attempting to reference a DOM element on the page. For example, the line group.querySelector('option[value="'+ value +'"]').disabled = true; is attempting to address an \ element based on a product's option values. If Locksmith has filtered out that variant option, this DOM element might not exist.
3. Modify the relevant JavaScript to insulate it against the possibility of that DOM element being missing. Using the example from above, we could separate the querySelector call from the attribute update. assign optionElement = group.querySelector('option[value="'+ value +'"]') if (optionElement) { optionElement.disabled = true; } Or, we could wrap the entire thing in a try/catch block, logging the error if one was raised. try { group.querySelector('option[value="'+ value +'"]').disabled = true; } catch (error) { console.error(error); }

Last updated 2023-11-14T21:21:30Z