import TurndownService from 'turndown';

export const initTextarea = () => {
  // subscribe to all textarea input events
  document.querySelectorAll('textarea').forEach((textarea) => {
    // setup in anticipation of esc behavior
    textarea.style.height = 'auto';

    textarea.addEventListener('keydown', function (event) {
      // esc key
      if (event.key === 'Escape') {
        if (textarea.value.trim() === '') {
          if (textarea.style.height !== 'auto') {
            textarea.style.height = 'auto';
          } else {
            textarea.blur();
          }
        } else {
          textarea.select();

          // reset height too
          textarea.style.height = 'auto';
          textarea.style.height = textarea.scrollHeight + 'px';
        }
      }
    });

    textarea.addEventListener('input', function () {
      // expand the textarea as needed. it'll be reset when the user submits their message. it
      // doesn't auto-shrink, and that actually feels appropriate? we keep whatever space the
      // user has hollowed out for themselves, and we only reset it when they've decided they're
      // complete. :)
      if (textarea.scrollHeight > textarea.clientHeight) {
        textarea.style.height = textarea.scrollHeight + 'px';
      }
    });

    // Handle paste event to convert HTML to markdown
    textarea.addEventListener('paste', (event) => {
      event.preventDefault();
      const clipboardData = event.clipboardData || window.clipboardData;
      const html = clipboardData.getData('text/html');
      const plainText = clipboardData.getData('text/plain');

      const turndownService = new TurndownService({
        headingStyle: 'atx',
        emDelimiter: '*',
        codeBlockStyle: 'fenced',
      });
      const markdown = html ? turndownService.turndown(html) : plainText;

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
