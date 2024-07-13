export class PromptButtonComponent extends HTMLElement {
  constructor() {
    super();

    // propagate clicks
    this.shadowRoot.querySelector('button').addEventListener('click', () => {
      this.dispatchEvent(new CustomEvent('prompt-button-click'));
    });
  }
}

customElements.define('prompt-button', PromptButtonComponent);
