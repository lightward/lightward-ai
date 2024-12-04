// app/javascript/src/concerns/textarea.js
import TurndownService from 'turndown';
import DOMPurify from 'dompurify';

export const initTextarea = () => {
  // Helper function to check for pre-wrap styles
  function hasPreWrapAncestor(node) {
    while (node && node !== node.ownerDocument.documentElement) {
      if (node.style && node.style.whiteSpace === 'pre-wrap') {
        return true;
      }
      node = node.parentElement;
    }
    return false;
  }

  // Function to preserve exact number of spaces
  function preserveSpaces(text) {
    return text.replace(/ /g, '&nbsp;');
  }

  // Function to preprocess HTML content
  function preprocessHTML(htmlContent) {
    const sanitizedHtml = DOMPurify.sanitize(htmlContent, {
      ALLOWED_TAGS: [
        'p',
        'span',
        'i',
        'em',
        'strong',
        'b',
        'br',
        'a',
        'u',
        'h1',
        'h2',
        'h3',
        'h4',
        'h5',
        'h6',
      ],
      ALLOWED_ATTR: ['style', 'class', 'href'],
      ALLOW_DATA_ATTR: false,
      ADD_TAGS: ['wbr'],
      FORBID_TAGS: ['script', 'style', 'iframe', 'form', 'input', 'textarea'],
      FORBID_ATTR: [
        'onload',
        'onclick',
        'onmouseover',
        'onmouseout',
        'onmousedown',
        'onmouseup',
      ],
      USE_PROFILES: { html: true }, // This preserves HTML styles
      ALLOW_ARIA_ATTR: true, // Sometimes needed for style preservation
    });

    const parser = new DOMParser();
    const doc = parser.parseFromString(sanitizedHtml, 'text/html');

    const allParagraphs = doc.querySelectorAll('p');
    const preWrapParagraphs = Array.from(allParagraphs).filter((p) =>
      hasPreWrapAncestor(p)
    );

    preWrapParagraphs.forEach((p) => {
      const childNodes = Array.from(p.childNodes);
      childNodes.forEach((node) => {
        if (node.nodeType === Node.TEXT_NODE) {
          const lines = node.textContent.split(/\r\n|\n|\r/);
          const fragment = doc.createDocumentFragment();

          lines.forEach((line, index) => {
            const leadingSpaces = line.match(/^[ ]*/)[0];
            const content = line.slice(leadingSpaces.length);

            if (leadingSpaces) {
              const spaceSpan = doc.createElement('span');
              spaceSpan.style.whiteSpace = 'pre';
              spaceSpan.innerHTML = preserveSpaces(leadingSpaces);
              fragment.appendChild(spaceSpan);
            }

            if (content) {
              fragment.appendChild(doc.createTextNode(content));
            }

            if (index < lines.length - 1) {
              fragment.appendChild(doc.createElement('br'));
            }
          });

          p.replaceChild(fragment, node);
        }
      });
    });

    return doc.body.innerHTML;
  }

  // Setup turndownService once, outside event handler
  const turndownService = new TurndownService({
    headingStyle: 'atx',
    codeBlockStyle: 'fenced',
    emDelimiter: '*',
    strongDelimiter: '**',
    bulletListMarker: '-',
    br: '\\\n',
  });

  // Add rule to preserve spaces
  turndownService.addRule('preserveSpaces', {
    filter: function (node) {
      return node.nodeName === 'SPAN' && node.style.whiteSpace === 'pre';
    },
    replacement: function (content) {
      return content;
    },
  });

  // Add custom line break handling
  turndownService.addRule('lineBreak', {
    filter: 'br',
    replacement: function (content, node, options) {
      return '\\\n';
    },
  });

  // Add all the custom rules
  turndownService.addRule('customHeadings', {
    filter: ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'],
    replacement: function (content, node) {
      const hLevel = Number(node.nodeName.charAt(1));
      const hPrefix = '#'.repeat(hLevel) + ' ';
      const textContent = node.textContent.trim();
      return '\n\n' + hPrefix + textContent + '\n\n';
    },
  });

  turndownService.addRule('italicText', {
    filter: function (node) {
      return (
        (node.nodeName === 'SPAN' && node.style.fontStyle === 'italic') ||
        node.nodeName === 'I' ||
        node.nodeName === 'EM'
      );
    },
    replacement: function (content) {
      return '*' + content + '*';
    },
  });

  turndownService.addRule('boldText', {
    filter: function (node) {
      return (
        (node.nodeName === 'SPAN' &&
          (node.style.fontWeight === 'bold' ||
            parseInt(node.style.fontWeight) >= 700)) ||
        node.nodeName === 'B' ||
        node.nodeName === 'STRONG'
      );
    },
    replacement: function (content) {
      return '**' + content + '**';
    },
  });

  turndownService.addRule('underlineText', {
    filter: function (node) {
      return (
        (node.nodeName === 'SPAN' &&
          node.style.textDecoration.includes('underline')) ||
        node.nodeName === 'U'
      );
    },
    replacement: function (content) {
      return '<u>' + content + '</u>';
    },
  });

  turndownService.addRule('ignoreEmptyLinks', {
    filter: function (node) {
      return (
        node.nodeName === 'A' &&
        (!node.textContent || node.textContent.trim() === '')
      );
    },
    replacement: function () {
      return '';
    },
  });

  document.querySelectorAll('textarea').forEach((textarea) => {
    textarea.style.height = 'auto';

    textarea.addEventListener('keydown', function (event) {
      if (event.key === 'Escape') {
        if (textarea.value.trim() === '') {
          if (textarea.style.height !== 'auto') {
            textarea.style.height = 'auto';
          } else {
            textarea.blur();
          }
        } else {
          textarea.select();
          textarea.style.height = 'auto';
          textarea.style.height = textarea.scrollHeight + 'px';
        }
      }
    });

    textarea.addEventListener('input', function () {
      if (textarea.scrollHeight > textarea.clientHeight) {
        textarea.style.height = textarea.scrollHeight + 'px';
      }
    });

    textarea.addEventListener('paste', (event) => {
      // Check for Cmd+Shift+V (Mac) or Ctrl+Shift+V (Windows)
      if (event.shiftKey && (event.metaKey || event.ctrlKey)) {
        // Let the browser handle the paste event normally
        return;
      }

      const clipboardData = event.clipboardData || window.clipboardData;
      const htmlContent = clipboardData.getData('text/html');

      // reasons to let default behavior handle the paste event
      if (!htmlContent) return;
      if (clipboardData.types.includes('application/vnd.code.copymetadata'))
        return;

      // Preprocess HTML for proper linebreak handling
      const processedHTML = preprocessHTML(htmlContent);

      // Convert HTML to Markdown
      let markdown = turndownService.turndown(processedHTML);

      // Apply post-processing
      markdown = markdown.replace(/^\\?-{2,}/gm, '* * *');
      markdown = markdown.replace(/--/g, '—');

      event.preventDefault();
      const start = textarea.selectionStart;

      // Insert the markdown
      document.execCommand('insertText', false, markdown);

      // Move cursor to end of inserted text
      const newPosition = start + markdown.length;
      textarea.setSelectionRange(newPosition, newPosition);

      // Trigger input event to resize textarea
      textarea.dispatchEvent(new Event('input'));
    });

    // Initial resize
    textarea.dispatchEvent(new Event('input'));
  });
};
