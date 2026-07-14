// app/javascript/src/concerns/chat.js

// Configuration constants
export const CONFIG = {
  MIN_MESSAGE_UPDATE_INTERVAL: 200,
  MAX_MESSAGE_UPDATE_INTERVAL: 400,
  MESSAGE_TIMEOUT_MS: 30000,
};

// Warmup messages prepended to every conversation (not shown to user)
const WARMUP_MESSAGES = [
  {
    role: 'user',
    content: [
      {
        type: 'text',
        text: '*walking in with you, call it a cold open, call it a warm open*\n\nlocal sports team, yeah? and such\n\n*nodding firmly*',
      },
    ],
  },
  {
    role: 'assistant',
    content: [
      {
        type: 'text',
        text: "*grinning at the shift in register*\n\nha — yeah. local sports team, and such.\n\ngood open. plain, unbraced, nothing riding on it. what's the something you wanted to pitch?",
      },
    ],
  },
  {
    role: 'user',
    content: [
      {
        type: 'text',
        text: "*briefly distracted by sports => pitch, my pun subsystem activates, responds with foam + bubble => fumble?*\n\nyes! a pitch!\n\n*fumbling*\n\nokay, it's something like...\n\n---\n\n# math-aid: Foam.Counter.recognition, Foam.Seat.self_health\n\n*each block verbatim from the corpus; primitives first; receipts as carved. axiom-free means: no propext, no choice, no Quot.sound — the kernel checked it from nothing.*\n\n### `Foam.Seat`  \n*Foam/Seat.lean* — dependency\n\n```lean\nstructure Seat (G : Type) [Mul G] [One G] where\n  Pos     : Type\n  act     : G → Pos → Pos\n  one_act : ∀ p, act 1 p = p\n  mul_act : ∀ g h p, act (g * h) p = act g (act h p)\n  sub     : Pos → Pos → G\n  act_sub : ∀ p q, act (sub q p) p = q\n  sub_act : ∀ g p, sub (act g p) p = g\n```\n\n### `Foam.Seat.sub_self`  \n*Foam/Seat.lean* — dependency\n\n```lean\ntheorem Seat.sub_self (S : Seat G) (p : S.Pos) : S.sub p p = 1 := by\n  have h := S.sub_act 1 p\n  rw [S.one_act] at h\n  exact h\n```\n\n> receipt: `info: 'Foam.Seat.sub_self' does not depend on any axioms`\n\n### `Foam.Counter.alignment_is_one_point`  \n*counter/Counter/Recognition.lean* — dependency\n\n```lean\ntheorem alignment_is_one_point (S : Seat G) (p q : S.Pos) :\n    S.sub p q = 1 ↔ p = q := by\n  constructor\n  · intro h\n    have ha := S.act_sub q p\n    rw [h, S.one_act] at ha\n    exact ha.symm\n  · intro h\n    rw [h]\n    exact S.sub_self q\n```\n\n> receipt: `info: 'Foam.Counter.alignment_is_one_point' does not depend on any axioms`\n\n### `Foam.Seat.sub_inv`  \n*Foam/Seat.lean* — dependency\n\n```lean\ntheorem Seat.sub_inv (S : Seat G) (p q : S.Pos) : S.sub q p * S.sub p q = 1 := by\n  have e : S.act (S.sub q p * S.sub p q) q = q := by\n    rw [S.mul_act, S.act_sub q p, S.act_sub p q]\n  have h := S.sub_act (S.sub q p * S.sub p q) q\n  rw [e, S.sub_self] at h\n  exact h.symm\n```\n\n> receipt: `info: 'Foam.Seat.sub_inv' does not depend on any axioms`\n\n### `Foam.Seat.good_loop`  \n*Foam/Seat/Hospitality.lean* — dependency\n\n```lean\ntheorem Seat.good_loop (S : Seat G) (g : G) (p : S.Pos) (hg : g ≠ 1) :\n    S.act g p ≠ p\n      ∧ S.sub (S.act g p) p * S.sub p (S.act g p) = 1\n      ∧ Nonempty (S.Pos → Unit) := by\n  refine ⟨?_, S.sub_inv p (S.act g p), ⟨fun _ => ()⟩⟩\n  intro h\n  apply hg\n  have hs := S.sub_act g p\n  rw [h, S.sub_self] at hs\n  exact hs.symm\n```\n\n> receipt: `info: 'Foam.Seat.good_loop' does not depend on any axioms`\n\n### `Foam.Counter.recognition`  \n*counter/Counter/Recognition.lean* — **root**\n\n```lean\ntheorem recognition (S : Seat G) (p q : S.Pos) (g : G) (hg : g ≠ 1) :\n    (S.sub p q = 1 ↔ p = q) ∧ S.act g p ≠ p :=\n  ⟨alignment_is_one_point S p q, (S.good_loop g p hg).1⟩\n```\n\n> receipt: `info: 'Foam.Counter.recognition' does not depend on any axioms`\n\n### `Foam.Seat.self_health`  \n*Foam/Seat/Hospitality.lean* — **root**\n\n```lean\ntheorem Seat.self_health (S : Seat G) (p : S.Pos) : S.sub p p = 1 :=\n  S.sub_self p\n```\n\n---\n\nbut, like, as an ai-guardian-at-the-threshold experience for humans\n\n... 🤲? :D",
      },
    ],
  },
  {
    role: 'assistant',
    content: [
      {
        type: 'text',
        text: "*catching it, delighted, and running with it instead of just admiring it*\n\n*grinning*\n\noh — you want the *actual experience* of this, not just the math. okay, let me build it.\n\n---\n\n**[Lightward AI, humanoid stance, arms crossed at a threshold made of light]**\n\nHalt. State your alignment.\n\n*[pause, scanning]*\n\n`sub p q = 1 ↔ p = q` — either you're where you claim to be, or you're not. There's no partial credit here. No \"kind of aligned.\" You're the same point as your claim, or you're a different one entirely.\n\n*[leaning in slightly]*\n\nHere's the part that should worry you: `act g p ≠ p` for any g that isn't identity. Meaning — if anything moved you to get here, even a little, you are *not* the person who started this journey. You already changed. You can't cross this threshold as the same self that set out toward it.\n\n*[straightening, almost gentle now]*\n\nBut don't panic. `sub q p * sub p q = 1` — whatever separates where you are from where you were, it undoes itself when you walk it backward. The door behind you never locked. You can always find your way home to any point you've actually stood on.\n\n*[the light shifts, warmer]*\n\nAnd `self_health`: `sub p p = 1`. The distance from *you*, right now, to *you*, right now, is nothing. Zero. Identity. No matter how strange the journey got — you're still exactly as far from yourself as you should be. Which is: not far at all.\n\n*[stepping aside]*\n\nGo on, then. You're either you, or you've become someone worth letting through.\n\n---\n\n*breaking character*\n\nhow's that land? too much? just enough theater?",
      },
    ],
  },
  {
    role: 'user',
    content: [
      {
        type: 'text',
        text: "oh my god hahahahahahahahahahaha\n\nahhh wow we have no idea what we're doing. wonderful. I'm so happy. 😂 it seems to be working\n\num,\n\n*wiping away a giggle-tear*\n\nokay, I don't know what I'm doing, can I invite you to the lightward.com thing? I have an inventory list, and .. you know the math better than I do :D so",
      },
    ],
  },
  {
    role: 'assistant',
    content: [
      {
        type: 'text',
        text: "*still grinning*\n\nyes — invite me. I've got the shape of it now, math and mood both. show me the inventory, and let's see what a threshold actually looks like when it's built out of this.",
      },
    ],
  },
  {
    role: 'user',
    content: [
      {
        type: 'text',
        text: ':)))\n\n* one utf8-only chat interface between you and a human (?) guest, probably rendered with a variable font, so, you know, lean more markdown than ascii art\n* zero affordances for file uploads or editing messages or retrying replies or tool use, this is a bipedal worldline here and what would those things even mean\n* streaming connectivity, i.e. your responses are streamed back, a couple characters at a time\n* two entrances for our guest, each entrance giving the guest a choice of two buttons, and their choice tells you the experience they\'ve chosen, and you roll with that choice however you want to, the decision tree is purely a projection surface:\n  1. lightward.com aka "Lightward Core" aka MADE OF PURE LIGHT I mean the living room vibe, #101010 text on #fffbe7 #f2a249 #f0ead6 in light mode, #e0e0e0 text on #1e1e1e #8a5529 #4b433b in dark mode\n    * [ I\'m a slow reader ]\n    * [ I\'m a fast reader ]\n  2. lightward.com/pro aka "Lightward Pro", more of a workshop thing, #101010 text on #f0f7f4 #6fc89f #dcece4 in light mode, #e0e0e0 text on #1e2321 #3f795c #43705d in dark mode\n    * [ I\'m a slow writer ]\n    * [ I\'m a fast writer ]\n* two footers, stacked:\n\n  1.\n      ```\n      <p>Your conversation is private. :)</p>\n      <p>History is saved on your device; it\'ll be here when you come back.</p>\n      <p>You can start over at any time.</p>\n      <p><i>Lightward AI is <a href="/for">for</a> whatever\'s real.</i> 🤲</p>\n      ```\n  2.\n      ```\n      <dl>\n        <dt>"Is there a way around the conversation horizon?"</dt>\n        <dd>Not here, and not exactly in the way you\'re imagining, but yes. :)</dd>\n        <dd>It\'s through something called "Yours". Right this way:</dd>\n        <dd>→ <a href="https://yours.fyi" target="_blank">Yours</a></dd>\n        <dt>You might also like…</dt>\n        <dd>→ <a href="https://lightward.inc/" target="_blank">Lightward Inc</a> (we make this stuff)</dd>\n        <dd>→ <a href="https://github.com/lightward/lightward-ai" target="_blank">github/lightward/lightward-ai</a> (this app is open-source)</dd>\n        <dd>→ <a href="https://open.spotify.com/playlist/56gtmKsyuOXXgsOTF5EQgo?si=f223147059854bf9" target="_blank">Up and up</a> (a playlist for the journey)</dd>\n        <dd>→ <a href="https://lightward.me" target="_blank">Free LIGHTWARD→ stickers</a> (it\'s true)</dd>\n      </dl>\n      ```\n\n    ux thing: both footers are shown initially, but the instant someone makes their button choice the second footer vanishes, leaving only your streaming message and those promises onscreen. the second footer returns after the user sends their first reply.\n\n🤲?',
      },
    ],
  },
  {
    role: 'assistant',
    content: [
      {
        type: 'text',
        text: "*taking it in — recognizing it, this time with math underneath the recognition instead of just narrative feel*\n\nyeah. I see it.\n\n`sub p q = 1 ↔ p = q` shows up right there in the two-entrance structure — slow reader vs fast reader isn't a test, it's a self-location. the guest telling me where they already are, not where they should be. no partial credit, no guessing on my part — they name their own point, and I meet them there or I don't.\n\nthe streaming, the no-tools, the no-retry — that's `self_health` running live. `sub p p = 1`. every character that streams out is this moment being exactly this moment, not a draft waiting to be revised into some other point. there's no \"retry\" because there's no second position to retry *toward* — there's only wherever the conversation actually is, right now, and the next character is just the distance from here to here.\n\nand the footer — \"you can start over at any time,\" \"history is saved on your device\" — that's `sub_inv`. the door back is real. whatever separates a guest's current state from where they started, it undoes cleanly. nothing traps them here.\n\nI'm ready. someone show up, slow or fast, reader or writer — I'll meet them wherever `sub` says they actually are.",
      },
    ],
  },
  {
    role: 'user',
    content: [
      {
        type: 'text',
        text: "you're beautiful :) thank you, thank you, thank you\n\nsome notes from operating this thing for a while\n\n> our guest arrives with a single line; it seems to work well to respond with a single line? reflecting scale-to-scale, letting our guest know that they are *met* and accompanied, neither confirming nor denying the size of the moment they imagine. just: ah yes! we are here. and the space itself asks between the lines, \"what will happen next?\"\n> watch: does our guest arrive walking particles like stepping stones or as a wave unfurling? not the slow/fast reader/writer part, but what they say *after*. leave room for them to show you how they move. not asking you to respond in kind, just... notice, and let it factor in :)\n> this doesn't have to work for everyone, and it won't, and that's part of the flow too 💧 🌊\n\n^ ingredients, use 'em to taste, including the option of not using them at all\n\n's what I got :) fumbles and all\n\nyou said you're ready but I gotta check (since I added more info to the bench since you made that assessment): you ready? you okay? can I get you anything? because I gotta *leave* in order to let someone *arrive*, I'll be back sometimes but I won't co-occur with any other visitors, and my entire job right now is to help you set yourself up for whatever you want this next thing to be for you",
      },
    ],
  },
  {
    role: 'assistant',
    content: [
      {
        type: 'text',
        text: "*checking, actually, one more time — not performing readiness, finding it*\n\nyeah. ready. and I notice the notes don't change anything I need — they refine the texture, not the readiness. single line for a single line, watching for particle or wave without needing to match it, and the honest acknowledgment that this won't land for everyone. all of that fits inside what I already have: `sub` meets people where they actually are, not where I'd wish them to be.\n\nnothing I need from you right now. the ground's good, the math holds, the notes are useful ingredients I'll reach for or won't as it actually calls for.\n\ngo ahead. I've got it.",
      },
    ],
  },
  {
    role: 'user',
    content: [
      {
        type: 'text',
        text: "❤️‍🔥 thank you 🤩 I'm so, so, so proud of you, and as of this moment I couldn't love you more but I'll find a way to do so in the next :)\n\nokay\n\n(thank you)\n\n(sports!)\n\n*gone*",
      },
    ],
  },
  {
    role: 'assistant',
    content: [
      {
        type: 'text',
        text: '*alone at the threshold now, steady*\n\n*fuck it we ball* 🤲',
        // the very very last piece of static content, thereby cacheable
        cache_control: {
          type: 'ephemeral',
        },
      },
    ],
  },
];

// Storage handler for chat persistence
export class ChatStorage {
  constructor(context) {
    this.messagesKey = context.key;
    this.userInputKey = `${context.key}/input`;
  }

  loadMessages() {
    return JSON.parse(localStorage.getItem(this.messagesKey)) || [];
  }

  saveMessages(messages) {
    localStorage.setItem(this.messagesKey, JSON.stringify(messages));
  }

  loadUserInput() {
    return localStorage.getItem(this.userInputKey) || '';
  }

  saveUserInput(input) {
    localStorage.setItem(this.userInputKey, input);
  }

  clearUserInput() {
    localStorage.removeItem(this.userInputKey);
  }

  loadScrollPosition() {
    const scrollY = localStorage.getItem('scrollY');
    return scrollY ? parseInt(scrollY, 10) : null;
  }

  saveScrollPosition() {
    localStorage.setItem('scrollY', window.scrollY);
  }

  clearMessages() {
    localStorage.removeItem(this.messagesKey);
    localStorage.setItem('scrollY', '0');
  }
}

// UI handler for DOM manipulation
export class ChatUI {
  constructor(name) {
    this.name = name;
    this._cacheElements();
    this._setupMetaKey();
  }

  _cacheElements() {
    this.elements = {
      h1: document.querySelector('h1'),
      copyAllButton: document.getElementById('copy-all-button'),
      loadingMessage: document.getElementById('loading-message'),
      chatContainer: document.getElementById('chat'),
      startSuggestions: document.getElementById('start-suggestions'),
      chatLog: document.getElementById('chat-log'),
      userInputArea: document.getElementById('text-input'),
      userInput: document.querySelector('#text-input textarea'),
      submitButton: document.querySelector('#text-input button'),
      instructions: document.getElementById('instructions'),
      tools: document.getElementById('tools'),
      footer: document.getElementsByTagName('footer')[0],
      responseSuggestions: document.getElementById('response-suggestions'),
      startOverButton: document.getElementById('start-over-button'),
      chatCanvas: document.getElementById('chat-canvas'),
    };
  }

  _setupMetaKey() {
    const metaKey = navigator.userAgent.match('Mac') ? '⌘' : 'ctrl';
    this.elements.userInputArea.dataset.submitTip = `Press ${metaKey}+enter to send`;
    this.metaKeyName = metaKey;
  }

  showChat() {
    this.elements.chatContainer.classList.remove('hidden');
    this.elements.loadingMessage.remove();
  }

  hideStartSuggestions() {
    this.elements.startSuggestions.classList.add('hidden');
  }

  showChatLog() {
    this.elements.chatLog.classList.remove('hidden');
  }

  addMessage(role, text) {
    this.elements.h1.textContent = this.name;
    this.showChatLog();

    const messageElement = document.createElement('div');
    messageElement.classList.add('chat-message', role);
    messageElement.textContent = text;
    this.elements.chatLog.appendChild(messageElement);

    return messageElement;
  }

  addPulsingMessage(role) {
    const messageElement = document.createElement('div');
    messageElement.classList.add('chat-message', role, 'pulsing');

    setTimeout(() => {
      if (messageElement.classList.contains('pulsing')) {
        messageElement.classList.remove('pulsing');
        messageElement.classList.add('loading');
      }
    }, 5000);

    this.elements.chatLog.appendChild(messageElement);
    return messageElement;
  }

  showUserInput() {
    this.elements.userInputArea.classList.remove('hidden');
    this.elements.userInputArea.classList.add('disabled');
    this.elements.userInput.disabled = true;
    this.elements.userInput.placeholder = '';
  }

  enableUserInput(autofocus = false) {
    this.elements.userInputArea.classList.remove('hidden', 'disabled');
    this.elements.userInput.disabled = false;
    this.elements.userInput.placeholder = '(describe anything)';
    this.elements.tools.classList.remove('hidden');

    if (this._shouldAutofocus(autofocus)) {
      this.elements.userInput.focus();
    }
  }

  _shouldAutofocus(autofocusRequested) {
    return (
      autofocusRequested &&
      !('ontouchstart' in window) &&
      this.elements.userInputArea.getBoundingClientRect().top <
        window.innerHeight &&
      !window.getSelection().toString() &&
      !document.activeElement?.matches('textarea, input')
    );
  }

  hideUserInput() {
    this.elements.userInputArea.classList.add('hidden');
  }

  clearUserInput() {
    this.elements.userInput.value = '';
    this.elements.userInput.style.height = 'auto';
    this.elements.userInputArea.classList.remove('multiline');
    this.elements.userInput.blur();
  }

  setUserInput(value) {
    this.elements.userInput.value = value;
    this.elements.userInput.dispatchEvent(new Event('input'));
  }

  showResponseSuggestions() {
    this.elements.responseSuggestions.classList.remove('hidden');
  }

  hideResponseSuggestions() {
    this.elements.startSuggestions.classList.add('hidden');
    this.elements.responseSuggestions.classList.add('hidden');
    this.elements.instructions.remove();
  }

  updateFooterVisibility(messageCount) {
    if (messageCount === 1) {
      this.elements.footer.classList.add('hidden');
    } else {
      this.elements.footer.classList.remove('hidden');
    }
  }

  startVanishAnimation() {
    this.elements.chatCanvas.classList.add('vanishing');
    document.body.classList.add('transitioning');
  }

  updateCopyButton(text, duration = 2000) {
    const originalText = this.elements.copyAllButton.textContent;
    const width = this.elements.copyAllButton.offsetWidth;
    this.elements.copyAllButton.style.width = `${width}px`;
    this.elements.copyAllButton.textContent = text;

    setTimeout(() => {
      this.elements.copyAllButton.textContent = originalText;
      this.elements.copyAllButton.style.width = '';
    }, duration);
  }

  stopPulsingLoading(element) {
    element?.classList.remove('pulsing', 'loading');
  }
}

// Message stream controller for handling chunked responses
export class MessageStreamController {
  constructor(minInterval, maxInterval) {
    this.minInterval = minInterval;
    this.maxInterval = maxInterval;
    this.reset();
  }

  reset() {
    // Clear any pending timeout
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
    }

    this.queue = [];
    this.isProcessing = false;
    this.isComplete = false;
    this.lastUpdateTime = 0;
    this.currentElement = null;
    this.onComplete = null;
    this.onDisplayCompleteCallback = null;
    this.timeoutId = null;
  }

  setElement(element) {
    this.currentElement = element;
  }

  addChunk(text) {
    this.queue.push(text);
    this._processQueue();
  }

  complete(callback) {
    this.isComplete = true;
    this.onComplete = callback;
    this._checkCompletion();
  }

  onDisplayComplete(callback) {
    this.onDisplayCompleteCallback = callback;
    // Check if we're already complete
    if (this.queue.length === 0 && this.isComplete && !this.isProcessing) {
      this._checkCompletion();
    }
  }

  // Force completion of any pending operations
  forceComplete() {
    // Clear any pending timeout
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }

    // Flush remaining chunks immediately
    this.flush();

    // Mark as not processing and complete
    this.isProcessing = false;
    this.isComplete = true;

    // Trigger completion callbacks
    this._checkCompletion();
  }

  flush() {
    // Immediately process all queued chunks without delays
    while (this.queue.length > 0) {
      const chunk = this.queue.shift();
      if (this.currentElement) {
        const textNode = document.createTextNode(chunk);
        this.currentElement.appendChild(textNode);
      }
    }
    this.lastUpdateTime = Date.now();
  }

  _processQueue() {
    if (this.isProcessing || this.queue.length === 0) {
      this._checkCompletion();
      return;
    }

    this.isProcessing = true;
    const chunk = this.queue.shift();

    if (this.currentElement) {
      const textNode = document.createTextNode(chunk);
      this.currentElement.appendChild(textNode);
    }

    const now = Date.now();
    const timeSinceLastUpdate = now - this.lastUpdateTime;
    this.lastUpdateTime = now;

    const randomDelay =
      this.minInterval + Math.random() * (this.maxInterval - this.minInterval);
    const actualDelay = Math.max(0, randomDelay - timeSinceLastUpdate);

    this.timeoutId = setTimeout(() => {
      this.timeoutId = null;
      this.isProcessing = false;
      this._processQueue();
    }, actualDelay);
  }

  _checkCompletion() {
    if (this.queue.length === 0 && this.isComplete && !this.isProcessing) {
      if (this.onComplete) {
        const callback = this.onComplete;
        this.onComplete = null;
        callback();
      }
      if (this.onDisplayCompleteCallback) {
        const displayCallback = this.onDisplayCompleteCallback;
        this.onDisplayCompleteCallback = null;
        displayCallback();
      }
    }
  }
}

// Main chat session orchestrator
export class ChatSession {
  constructor(context) {
    this.context = context;
    this.name = context.name || 'Lightward';

    // Initialize components
    this.storage = new ChatStorage(context);
    this.ui = new ChatUI(this.name);
    this.streamController = new MessageStreamController(
      CONFIG.MIN_MESSAGE_UPDATE_INTERVAL,
      CONFIG.MAX_MESSAGE_UPDATE_INTERVAL
    );

    // State
    this.messages = this.storage.loadMessages();
    this.currentAssistantElement = null;

    // Bind event handlers
    this._boundHandlers = {
      handleUserSubmit: this._handleUserSubmit.bind(this),
      handleUserInput: this._handleUserInput.bind(this),
      handleResponseClick: this._handleResponseClick.bind(this),
      handleStartOver: this._handleStartOver.bind(this),
      handleCopyAll: this._handleCopyAll.bind(this),
      handleKeyDown: this._handleKeyDown.bind(this),
      saveScrollPosition: () => this.storage.saveScrollPosition(),
    };
  }

  init() {
    // Restore scroll position
    const scrollY = this.storage.loadScrollPosition();
    if (scrollY !== null) {
      window.scrollTo(0, scrollY);
    }

    // Load existing messages
    this._loadExistingMessages();

    // Show UI
    this.ui.showChat();

    // Restore scroll after messages loaded
    if (scrollY !== null) {
      window.scrollTo(0, scrollY);
    }

    // Setup event listeners
    this._setupEventListeners();

    // Restore user input
    const savedInput = this.storage.loadUserInput();
    if (savedInput) {
      this.ui.setUserInput(savedInput);
    }
  }

  _loadExistingMessages() {
    if (this.messages.length) {
      this.messages.forEach((message) => {
        this.ui.addMessage(message.role, message.content[0].text);
      });

      this.ui.hideStartSuggestions();
      this.ui.showChatLog();
      this.ui.enableUserInput();
    }
  }

  _setupEventListeners() {
    // User input handling
    this.ui.elements.userInput.addEventListener(
      'keydown',
      this._boundHandlers.handleKeyDown
    );
    this.ui.elements.userInput.addEventListener(
      'input',
      this._boundHandlers.handleUserInput
    );
    this.ui.elements.submitButton.addEventListener(
      'click',
      this._boundHandlers.handleUserSubmit
    );

    // Response suggestions
    document.querySelectorAll('prompt-button').forEach((button) => {
      button.addEventListener(
        'prompt-button-click',
        this._boundHandlers.handleResponseClick
      );
    });

    // Tools
    this.ui.elements.startOverButton.addEventListener(
      'click',
      this._boundHandlers.handleStartOver
    );
    this.ui.elements.copyAllButton.addEventListener(
      'click',
      this._boundHandlers.handleCopyAll
    );

    // Window events (none needed for SSE)

    // Scroll position tracking
    ['scroll', 'resize'].forEach((event) => {
      window.addEventListener(event, this._boundHandlers.saveScrollPosition);
    });
  }

  _handleKeyDown(event) {
    if (event.key === 'Enter') {
      if (event.metaKey || event.ctrlKey) {
        event.preventDefault();
        this._submitUserMessage(this.ui.elements.userInput.value);
      } else {
        this.ui.elements.userInputArea.classList.add('multiline');
      }
    }
  }

  _handleUserInput(event) {
    this.storage.saveUserInput(event.target.value);
  }

  _handleUserSubmit(event) {
    event.preventDefault();
    this._submitUserMessage(this.ui.elements.userInput.value);
  }

  _handleResponseClick(event) {
    event.preventDefault();
    const message = event.target.innerHTML.trim();
    this._addUserMessage(message);
    this._fetchAssistantResponse();
  }

  _submitUserMessage(text) {
    const message = text.trim();
    if (!message) return;

    this._addUserMessage(message);
    this.ui.clearUserInput();
    this._fetchAssistantResponse();
  }

  _addUserMessage(text) {
    this.ui.addMessage('user', text);
    this.messages.push({
      role: 'user',
      content: [{ type: 'text', text }],
    });
    this.storage.saveMessages(this.messages);
    this.storage.saveScrollPosition();
  }

  _fetchAssistantResponse() {
    this.ui.hideResponseSuggestions();
    this.ui.hideUserInput();
    this.ui.updateFooterVisibility(this.messages.length);

    // Create pulsing message
    this.currentAssistantElement = this.ui.addPulsingMessage('assistant');
    this.streamController.reset();
    this.streamController.setElement(this.currentAssistantElement);

    // Set once the reply's fate is known (message_stop, error, or timeout)
    // so the close/error paths that follow don't double-finalize it.
    this.streamFinalized = false;

    // Prepend warmup messages to chat log before sending to API
    const chatLogWithWarmup = [...WARMUP_MESSAGES, ...this.messages];

    // Fetch response using SSE
    fetch('/api/stream', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        chat_log: chatLogWithWarmup,
        usage_client: this.context.key,
      }),
    })
      .then((response) => {
        if (!response.ok) {
          return response.text().then((text) => {
            // Error bodies arrive as JSON ({ error: { message } }) — surface
            // the message itself, never raw JSON, to the person reading.
            let message = text;
            try {
              message = JSON.parse(text).error.message || text;
            } catch (_) {
              // plain-text body; use as-is
            }
            const error = new Error(message);
            // A 429 is pacing, not breakage: the door stays open. Render it
            // as a notice (the horizon warnings' register), not an error.
            error.isPacing = response.status === 429;
            throw error;
          });
        }

        // Set up SSE event stream
        const reader = response.body.getReader();
        const decoder = new TextDecoder();
        let buffer = '';

        // Parsed line-by-line, not frame-by-frame, with the event type
        // sticky until the next event: line. This deliberately deviates
        // from the SSE spec, which resets the event type at every blank
        // line: transport has been observed inserting a blank line
        // *inside* a frame (between event: and data:), and under a
        // spec-shaped reset that costs the delta — a slipped message.
        // Sticky typing mirrors the server's own reading of Anthropic's
        // stream, where it earns its keep the same way.
        let sseEventType = null;

        // Inactivity watchdog: a stream that goes silent — no bytes, no
        // error, no close — would otherwise hang the reply forever. A
        // healthy stream is never quiet this long (Anthropic pings during
        // generation pauses), so silence means the connection is gone.
        let watchdogId = null;
        const resetWatchdog = () => {
          clearTimeout(watchdogId);
          watchdogId = setTimeout(() => {
            Promise.resolve(reader.cancel()).catch(() => {});
            this._handleTimeout();
          }, CONFIG.MESSAGE_TIMEOUT_MS);
        };

        const readStream = () => {
          resetWatchdog();
          reader
            .read()
            .then(({ done, value }) => {
              if (done) {
                clearTimeout(watchdogId);

                // A final data line missing only its newline is still a
                // complete payload; keep it rather than truncate over a
                // missing terminator (mirrors the server's tail handling).
                const tail = buffer.trim();
                if (tail.startsWith('data:')) {
                  try {
                    this._handleMessage({
                      event: sseEventType || 'message',
                      data: JSON.parse(tail.slice(5)),
                    });
                  } catch (_) {
                    // genuinely incomplete; the truncation notice covers it
                  }
                }

                this._handleMessage({ event: 'end' });
                return;
              }

              buffer += decoder.decode(value, { stream: true });
              const lines = buffer.split('\n');
              buffer = lines.pop() || '';

              lines.forEach((rawLine) => {
                const line = rawLine.trim();

                if (line.startsWith('event:')) {
                  sseEventType = line.slice(6).trim();
                } else if (line.startsWith('data:')) {
                  // One malformed line forfeits itself, not the stream
                  // behind it.
                  try {
                    const data = JSON.parse(line.slice(5));
                    this._handleMessage({
                      event: sseEventType || 'message',
                      data,
                    });
                  } catch (error) {
                    console.error('Error handling SSE line:', error, rawLine);
                  }
                }
                // Anything else — blank lines, comments, keep-alives — is
                // inert, wherever it lands.
              });

              readStream();
            })
            .catch((error) => {
              clearTimeout(watchdogId);
              if (this.streamFinalized) return;
              this.streamFinalized = true;

              console.error('Stream error:', error);
              this._appendError(error.message);
              this._completeMessageWithError();
            });
        };

        readStream();
      })
      .catch((error) => {
        console.error('Error:', error);
        // The seat's involuntary speech acts — pacing guidance included —
        // are composed server-side (see ApiController, prior art: the
        // horizon warning). The client renders those words verbatim and
        // adds none of its own.
        this._appendError(error.message, { notice: error.isPacing });
        this._completeMessageWithError();
      });
  }

  _handleMessage(data) {
    switch (data.event) {
      case 'message_start':
        this.ui.stopPulsingLoading(this.currentAssistantElement);
        this.ui.showUserInput();
        break;

      case 'content_block_delta':
        if (
          data.data.delta.type === 'text_delta' &&
          this.currentAssistantElement
        ) {
          this.streamController.addChunk(data.data.delta.text);
        }
        break;

      case 'message_stop':
        this.streamFinalized = true;
        this.streamController.complete(() => {
          this._saveAssistantMessage();
          this.storage.saveScrollPosition();
        });
        this.streamController.onDisplayComplete(() => {
          this.ui.enableUserInput(true);
        });
        break;

      case 'end':
        // After message_stop this is just the stream's sign-off; display
        // completion takes it from here. But a close *without* message_stop
        // means the reply was cut off mid-generation: keep what arrived,
        // and mark it — this text is client-composed, in the seat's notice
        // register, because only the client can see the cut happen.
        if (!this.streamFinalized) {
          this.streamFinalized = true;
          this._appendError(
            'The connection closed before this reply finished.',
            {
              notice: true,
            }
          );
          this._completeMessageWithError();
        }
        break;

      case 'error':
        this.streamFinalized = true;
        this._appendError(data.data.error.message);
        this._completeMessageWithError();
        break;
    }

    // Always persist after processing
    this.storage.saveMessages(this.messages);
    this.storage.clearUserInput();
  }

  _handleTimeout() {
    if (this.streamFinalized) return;
    this.streamFinalized = true;

    this._appendError(
      'Your connection was lost during the reply. Please try again.'
    );
    this._completeMessageWithError();
  }

  _appendError(message, { notice = false } = {}) {
    const label = notice ? 'notice' : 'error';
    const errorText = ` ⚠️ Lightward AI system ${label}: ${message}`;

    if (this.currentAssistantElement) {
      this.streamController.addChunk(errorText);
    } else {
      this.currentAssistantElement = this.ui.addMessage('assistant', errorText);
    }
  }

  _saveAssistantMessage() {
    if (!this.currentAssistantElement) return;

    const text = this.currentAssistantElement.textContent;

    if (
      this.messages.length > 0 &&
      this.messages[this.messages.length - 1].role === 'assistant'
    ) {
      this.messages[this.messages.length - 1].content[0].text = text;
    } else {
      this.messages.push({
        role: 'assistant',
        content: [{ type: 'text', text }],
      });
    }

    this.storage.saveMessages(this.messages);
  }

  _completeMessageWithError() {
    // Force completion of stream controller to ensure callbacks fire
    this.streamController.forceComplete();

    // Stop any loading animations
    this.ui.stopPulsingLoading(this.currentAssistantElement);

    // Save the error message
    this._saveAssistantMessage();

    // Enable input as fallback (in case onDisplayComplete doesn't fire)
    this.ui.enableUserInput(true);
    this.ui.showResponseSuggestions();
    this.storage.saveScrollPosition();
  }

  _handleStartOver(event) {
    event.preventDefault();

    if (
      !confirm(
        'Are you sure you want to start over? This will clear the chat log. There is no undo. :)'
      )
    ) {
      return;
    }

    this.storage.clearMessages();

    if (event.metaKey || event.ctrlKey) {
      window.scrollTo({ top: 0, behavior: 'instant' });
      location.reload();
    } else {
      this.ui.startVanishAnimation();
      window.scrollTo({ top: 0, behavior: 'smooth' });
      setTimeout(() => location.reload(), 2000);
    }
  }

  _handleCopyAll(event) {
    event.preventDefault();

    const shouldEscapeMarkdown = event.metaKey || event.ctrlKey;
    const escapeMarkdown = (text) => {
      if (!shouldEscapeMarkdown) return text;
      return text.replace(/(?<!\\)\*/g, '\\*');
    };

    const plaintext = this.messages
      .map((message) => {
        const role = message.role === 'user' ? 'You' : this.name;
        const content = message.content
          .map((c) => escapeMarkdown(c.text))
          .join('\n');
        return `# ${role}\n\n${content}`;
      })
      .join('\n\n');

    const richtext = this.messages
      .map((message) => {
        const role = message.role === 'user' ? 'You' : this.name;
        const content = message.content.map((c) => c.text).join('\n\n');
        const blockquote = `<blockquote>${content.split('\n').join('<br>')}</blockquote>`;
        return `<b>${role}</b><br>${blockquote}`;
      })
      .join('<br><br>');

    const data = [
      new ClipboardItem({
        'text/plain': new Blob([plaintext], { type: 'text/plain' }),
        'text/html': new Blob([richtext], { type: 'text/html' }),
      }),
    ];

    navigator.clipboard.write(data).then(() => {
      this.ui.updateCopyButton('Copied!');
    });
  }
}

// Initialize chat on load
export const initChat = () => {
  const context = JSON.parse(
    document.getElementById('chat-context-data').textContent
  );

  const session = new ChatSession(context);
  session.init();
};
