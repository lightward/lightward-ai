import { createConsumer } from '@rails/actioncable';

const consumer = createConsumer();

export class VoiceButtonComponent extends HTMLElement {
  constructor() {
    super();

    this.button = this.shadowRoot.querySelector('button');
    this.mediaRecorder = null;
    this.audioChunks = [];
    this.isRecording = false;
    this.subscription = null;
    this.targetTextarea = null;

    // Set initial state
    this.updateButtonState('ready');

    // Setup event listeners
    this.button.addEventListener('click', () => this.toggleRecording());

    // Find the target textarea (looking for the closest parent with text-input and then the textarea within)
    const textInputContainer = this.closest('#text-input, .text-input');
    if (textInputContainer) {
      this.targetTextarea = textInputContainer.querySelector('textarea');
    }
  }

  // Helper method to update button state
  updateButtonState(state) {
    // Remove all possible states
    this.button.classList.remove('ready', 'recording', 'transcribing');
    // Add the current state
    this.button.classList.add(state);
  }

  async toggleRecording() {
    if (this.isRecording) {
      this.stopRecording();
    } else {
      await this.startRecording();
    }
  }

  async startRecording() {
    try {
      // Request microphone access
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });

      this.audioChunks = [];
      this.mediaRecorder = new MediaRecorder(stream);

      this.mediaRecorder.addEventListener('dataavailable', (event) => {
        if (event.data.size > 0) {
          this.audioChunks.push(event.data);
        }
      });

      this.mediaRecorder.addEventListener('stop', () => {
        // Switch to transcribing state when recording stops
        this.updateButtonState('transcribing');
        this.processAudio();
        // Stop all audio tracks to release the microphone
        stream.getTracks().forEach((track) => track.stop());
      });

      // Start recording
      this.mediaRecorder.start();
      this.isRecording = true;

      // Update button state
      this.updateButtonState('recording');
    } catch (error) {
      console.error('Error accessing microphone:', error);
      alert(
        'Could not access your microphone. Please check permissions and try again.'
      );
      this.updateButtonState('ready');
    }
  }

  stopRecording() {
    if (this.mediaRecorder && this.isRecording) {
      this.mediaRecorder.stop();
      this.isRecording = false;
    }
  }

  async processAudio() {
    if (this.audioChunks.length === 0) {
      this.updateButtonState('ready');
      return;
    }

    // Create audio blob from chunks
    const audioBlob = new Blob(this.audioChunks, { type: 'audio/webm' });

    // Create form data to send to server
    const formData = new FormData();
    formData.append('audio', audioBlob, 'recording.webm');

    try {
      // Send to transcription endpoint
      const response = await fetch('/transcriptions', {
        method: 'POST',
        body: formData,
      });

      if (!response.ok) {
        throw new Error(`Server responded with ${response.status}`);
      }

      const data = await response.json();
      const transcription_id = data.transcription_id;

      if (transcription_id) {
        this.listenForTranscript(transcription_id);
      } else {
        throw new Error('No job UUID received');
      }
    } catch (error) {
      console.error('Error sending audio for transcription:', error);
      alert('Failed to send audio for transcription. Please try again.');
      this.updateButtonState('ready');
    }
  }

  listenForTranscript(transcription_id) {
    // Subscribe to ActionCable channel for the transcription job
    this.subscription = consumer.subscriptions.create(
      { channel: 'TranscriptionChannel', transcription_id: transcription_id },
      {
        connected: () => {
          console.log('Connected to transcription channel');
        },
        disconnected: () => {
          console.log('Disconnected from transcription channel');
        },
        received: (data) => {
          if (data.transcript) {
            this.handleTranscript(data.transcript);
          } else if (data.error) {
            console.error('Transcription error:', data.error);
            alert('Error during transcription: ' + data.error);
          }

          // Unsubscribe after receiving the result
          if (data.transcript || data.error) {
            this.subscription.unsubscribe();
            this.subscription = null;
            // Set back to ready state
            this.updateButtonState('ready');
          }
        },
      }
    );
  }

  handleTranscript(transcript) {
    // If we have a target textarea, insert the transcript there
    if (this.targetTextarea) {
      const currentText = this.targetTextarea.value;
      const cursorPos = this.targetTextarea.selectionStart;

      // Insert transcript at cursor position
      this.targetTextarea.value =
        currentText.substring(0, cursorPos) +
        transcript +
        currentText.substring(this.targetTextarea.selectionEnd);

      // Set cursor position after the inserted text
      this.targetTextarea.selectionStart = cursorPos + transcript.length;
      this.targetTextarea.selectionEnd = cursorPos + transcript.length;

      // Focus the textarea
      this.targetTextarea.focus();

      // Trigger input event to handle any listeners (like auto-resize)
      this.targetTextarea.dispatchEvent(new Event('input', { bubbles: true }));
    }
  }
}

customElements.define('voice-button', VoiceButtonComponent);
