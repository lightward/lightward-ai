// app/javascript/src/concerns/textarea.js

import TurndownService from 'turndown';

export const initTextarea = () => {
  // Subscribe to all textarea input events
  document.querySelectorAll('textarea').forEach((textarea) => {
    // Setup in anticipation of ESC behavior
    textarea.style.height = 'auto';

    textarea.addEventListener('keydown', function (event) {
      // ESC key
      if (event.key === 'Escape') {
        if (textarea.value.trim() === '') {
          if (textarea.style.height !== 'auto') {
            textarea.style.height = 'auto';
          } else {
            textarea.blur();
          }
        } else {
          textarea.select();

          // Reset height too
          textarea.style.height = 'auto';
          textarea.style.height = textarea.scrollHeight + 'px';
        }
      }
    });

    textarea.addEventListener('input', function () {
      // Expand the textarea as needed
      if (textarea.scrollHeight > textarea.clientHeight) {
        textarea.style.height = textarea.scrollHeight + 'px';
      }
    });

    // Handle paste event to convert HTML to Markdown
    textarea.addEventListener('paste', (event) => {
      const clipboardData = event.clipboardData || window.clipboardData;
      let htmlContent = '';

      if (clipboardData.types.includes('text/html')) {
        htmlContent = clipboardData.getData('text/html');
      }

      if (!htmlContent) {
        return;
      }

      event.preventDefault();

      // Initialize TurndownService with options
      const turndownService = new TurndownService({
        headingStyle: 'atx',
        codeBlockStyle: 'fenced',
        emDelimiter: '*',
        strongDelimiter: '**',
        bulletListMarker: '-',
      });

      // Custom rule to handle headings
      turndownService.addRule('customHeadings', {
        filter: ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'],
        replacement: function (content, node) {
          const hLevel = Number(node.nodeName.charAt(1));
          const hPrefix = '#'.repeat(hLevel) + ' ';
          const textContent = node.textContent.trim();
          return '\n\n' + hPrefix + textContent + '\n\n';
        },
      });

      // Add rules to handle inline styles like italic, bold, and underline
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

      // Add a rule to ignore empty links
      turndownService.addRule('ignoreEmptyLinks', {
        filter: function (node) {
          return (
            node.nodeName === 'A' &&
            (!node.textContent || node.textContent.trim() === '')
          );
        },
        replacement: function () {
          return ''; // Remove the link entirely
        },
      });

      // Convert HTML to Markdown
      let markdown = turndownService.turndown(htmlContent);

      // Replace horizontal rules
      markdown = markdown.replace(/^\\?-{2,}/gm, '* * *');

      // Replace '--' with '—' (em dash)
      markdown = markdown.replace(/--/g, '—');

      // Insert the Markdown at the cursor position
      const start = textarea.selectionStart;
      const end = textarea.selectionEnd;
      textarea.value =
        textarea.value.substring(0, start) +
        markdown +
        textarea.value.substring(end);
      textarea.setSelectionRange(
        start + markdown.length,
        start + markdown.length
      );

      // Trigger input event to resize textarea
      textarea.dispatchEvent(new Event('input'));
    });

    // Trigger input event to resize textarea
    textarea.dispatchEvent(new Event('input'));
  });
};
