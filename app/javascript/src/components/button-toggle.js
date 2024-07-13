export class ButtonToggle extends HTMLElement {
  constructor() {
    super();

    const button = this.shadowRoot.querySelector('button');
    button.addEventListener('click', async (event) => {
      const id = this.dataset.buttonId;
      const isArchived = this.dataset.isArchived === 'true';

      try {
        const response = await fetch(
          `/buttons/${id}/${isArchived ? 'unarchive' : 'archive'}`,
          {
            method: 'POST',
          }
        );

        if (response.ok) {
          console.log('Button archived/unarchived successfully');

          // disable button, update text
          button.innerText = isArchived ? 'Restored' : 'Archived';
          button.setAttribute('disabled', '');
          button.part.add('button-disabled');
        } else {
          console.error('Failed to archive/unarchive button');
        }
      } catch (error) {
        console.error(
          'An error occurred while archiving/unarchiving button:',
          error
        );
      }
    });
  }
}

customElements.define('button-toggle', ButtonToggle);
