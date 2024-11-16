import TurndownService from 'turndown';

export const initTextarea = () => {
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

    // Updated paste handler
    textarea.addEventListener('paste', (event) => {
      const clipboardData = event.clipboardData || window.clipboardData;
      const plainText = clipboardData.getData('text/plain');
      let htmlContent = '';

      if (clipboardData.types.includes('text/html')) {
        htmlContent = clipboardData.getData('text/html');
      }

      // If there's no HTML content, let the default paste behavior handle it
      if (!htmlContent) {
        return;
      }

      // Initialize TurndownService with options
      const turndownService = new TurndownService({
        headingStyle: 'atx',
        codeBlockStyle: 'fenced',
        emDelimiter: '*',
        strongDelimiter: '**',
        bulletListMarker: '-',
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
            (node.nodeName === 'SPAN' && node.style.fontWeight === 'bold') ||
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

      // Convert HTML to Markdown
      let markdown = turndownService.turndown(htmlContent);

      // Apply post-processing
      markdown = markdown.replace(/^\\?-{2,}/gm, '* * *');
      markdown = markdown.replace(/--/g, '—');

      // Function to normalize content for comparison
      const normalizeContent = (content) => {
        return content
          .trim()
          .replace(/\r\n/g, '\n') // Normalize line endings
          .replace(/\n+/g, '\n') // Normalize multiple newlines
          .replace(/\s+/g, ' ') // Normalize multiple spaces
          .replace(/\\([_*[\]])/g, '$1'); // Remove escape characters before _, *, [, and ]
      };

      // Compare the processed markdown with the plain text
      if (
        plainText &&
        normalizeContent(markdown) === normalizeContent(plainText)
      ) {
        // Use the plain text version if they're effectively the same
        markdown = plainText;
      }

      event.preventDefault();

      // Get the selected text range
      const start = textarea.selectionStart;
      const end = textarea.selectionEnd;

      // Focus the textarea (required for execCommand to work)
      textarea.focus();

      // If there's selected text, delete it first (will be undoable)
      if (start !== end) {
        document.execCommand('delete', false);
      }

      // Insert the new text (will be undoable)
      document.execCommand('insertText', false, markdown);

      // Trigger input event to resize textarea
      textarea.dispatchEvent(new Event('input'));
    });

    // Initial resize
    textarea.dispatchEvent(new Event('input'));
  });
};
