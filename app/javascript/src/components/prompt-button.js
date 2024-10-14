export class PromptButtonComponent extends HTMLElement {
  constructor() {
    super();

    // Propagate clicks
    this.shadowRoot.querySelector('button').addEventListener('click', () => {
      this.dispatchEvent(new CustomEvent('prompt-button-click'));
    });

    // Start the wiggle animation
    this.startWiggle();
  }

  startWiggle() {
    const button = this.shadowRoot.querySelector('button');

    const wiggle = () => {
      button.classList.add('wiggle');

      // Remove the 'wiggle' class after the animation duration
      setTimeout(() => {
        button.classList.remove('wiggle');
      }, 1000); // Duration of the wiggle animation in milliseconds

      // Schedule the next wiggle at a random time between 2s and 7s
      const nextWiggle = Math.random() * 5000 + 2000;
      setTimeout(wiggle, nextWiggle);
    };

    // Start the first wiggle after a random delay up to 5s
    const initialDelay = Math.random() * 5000;
    setTimeout(wiggle, initialDelay);
  }
}

customElements.define('prompt-button', PromptButtonComponent);
