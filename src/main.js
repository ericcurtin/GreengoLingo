/**
 * GreengoLingo - Premium Portuguese Language Learning Application
 * Main JavaScript Application
 */

// Check if we're running in Tauri
const isTauri = window.__TAURI__ !== undefined;

// Mock API for browser development (when not running in Tauri)
const mockApi = {
  lessons: [],
  progress: {
    currentLevel: 'A1.1',
    accuracy: 0,
    streak: 0,
    lessonsCompleted: 0,
    practiceTime: '0m',
    wordsLearned: 0
  },
  dialect: 'pt-pt',
  typingMode: 'lenient',
  darkMode: true,

  // Mock lesson data
  mockLessons: {
    'pt-pt': [
      {
        id: 'pt-pt-lesson-a1.1',
        title: 'First Steps: Greetings',
        description: 'By the end of this lesson, you will be able to greet anyone in Portuguese at any time of day.',
        level_code: 'A1.1',
        total_questions: 5,
        allows_challenge_out: true
      },
      {
        id: 'pt-pt-lesson-a1.2',
        title: 'At the Café',
        description: 'By the end of this lesson, you will be able to order a coffee and pay the bill politely.',
        level_code: 'A1.2',
        total_questions: 5,
        allows_challenge_out: true
      },
      {
        id: 'pt-pt-lesson-a1.3',
        title: 'Introducing Yourself',
        description: 'By the end of this lesson, you will be able to introduce yourself and your family.',
        level_code: 'A1.3',
        total_questions: 3,
        allows_challenge_out: true
      }
    ],
    'pt-br': [
      {
        id: 'pt-br-lesson-a1.1',
        title: 'First Steps: Greetings',
        description: 'By the end of this lesson, you will be able to greet anyone in Portuguese at any time of day.',
        level_code: 'A1.1',
        total_questions: 5,
        allows_challenge_out: true
      },
      {
        id: 'pt-br-lesson-a1.2',
        title: 'At the Café',
        description: 'By the end of this lesson, you will be able to order a coffee and pay the bill politely.',
        level_code: 'A1.2',
        total_questions: 5,
        allows_challenge_out: true
      },
      {
        id: 'pt-br-lesson-a1.3',
        title: 'Introducing Yourself',
        description: 'By the end of this lesson, you will be able to introduce yourself and your family.',
        level_code: 'A1.3',
        total_questions: 3,
        allows_challenge_out: true
      }
    ]
  },

  // Mock questions
  mockQuestions: {
    'pt-pt-lesson-a1.1': [
      {
        id: 'pt-pt-q1',
        question_type: 'MultipleChoice',
        prompt: "It's 9 AM. How do you greet someone?",
        context: { scenario: 'You meet your neighbor on your way to work in the morning.' },
        correct_answer: 'Bom dia',
        options: [
          { text: 'Bom dia', is_correct: true, explanation: "Correct! 'Bom dia' is used in the morning until noon." },
          { text: 'Boa tarde', is_correct: false, explanation: "'Boa tarde' is used in the afternoon, not morning." },
          { text: 'Boa noite', is_correct: false, explanation: "'Boa noite' is used in the evening/night." }
        ]
      },
      {
        id: 'pt-pt-q2',
        question_type: 'MultipleChoice',
        prompt: "It's 3 PM. What do you say?",
        context: { scenario: 'You enter a shop in the afternoon.' },
        correct_answer: 'Boa tarde',
        options: [
          { text: 'Bom dia', is_correct: false },
          { text: 'Boa tarde', is_correct: true },
          { text: 'Boa noite', is_correct: false }
        ]
      },
      {
        id: 'pt-pt-q3',
        question_type: 'Typing',
        prompt: "Translate: 'Good morning'",
        correct_answer: 'Bom dia',
        hint: "Remember: 'dia' is masculine, so we use 'Bom'"
      },
      {
        id: 'pt-pt-q4',
        question_type: 'Typing',
        prompt: "Translate: 'Good afternoon'",
        correct_answer: 'Boa tarde',
        hint: "Remember: 'tarde' is feminine, so we use 'Boa'"
      },
      {
        id: 'pt-pt-q5',
        question_type: 'Typing',
        prompt: "Translate: 'Hello'",
        correct_answer: 'Olá'
      }
    ],
    'pt-br-lesson-a1.1': [
      {
        id: 'pt-br-q1',
        question_type: 'MultipleChoice',
        prompt: "It's 9 AM. How do you greet someone?",
        context: { scenario: 'You meet your neighbor on your way to work in the morning.' },
        correct_answer: 'Bom dia',
        options: [
          { text: 'Bom dia', is_correct: true, explanation: "Correct! 'Bom dia' is used in the morning until noon." },
          { text: 'Boa tarde', is_correct: false, explanation: "'Boa tarde' is used in the afternoon, not morning." },
          { text: 'Boa noite', is_correct: false, explanation: "'Boa noite' is used in the evening/night." }
        ]
      },
      {
        id: 'pt-br-q2',
        question_type: 'MultipleChoice',
        prompt: "It's 3 PM. What do you say?",
        context: { scenario: 'You enter a shop in the afternoon.' },
        correct_answer: 'Boa tarde',
        options: [
          { text: 'Bom dia', is_correct: false },
          { text: 'Boa tarde', is_correct: true },
          { text: 'Boa noite', is_correct: false }
        ]
      },
      {
        id: 'pt-br-q3',
        question_type: 'Typing',
        prompt: "Translate: 'Good morning'",
        correct_answer: 'Bom dia',
        hint: "Remember: 'dia' is masculine, so we use 'Bom'"
      },
      {
        id: 'pt-br-q4',
        question_type: 'Typing',
        prompt: "Translate: 'Good afternoon'",
        correct_answer: 'Boa tarde',
        hint: "Remember: 'tarde' is feminine, so we use 'Boa'"
      },
      {
        id: 'pt-br-q5',
        question_type: 'Typing',
        prompt: "Translate: 'Hello'",
        correct_answer: 'Olá'
      }
    ]
  },

  // Mock cheat sheets
  mockCheatSheets: {
    'pt-pt-lesson-a1.1': [
      {
        title: 'Portuguese Greetings',
        explanation: "Portuguese has different greetings depending on the time of day. Unlike English, these are used very consistently in daily interactions.",
        examples: [
          { portuguese: 'Bom dia', english: 'Good morning', breakdown: "'Bom' (good) + 'dia' (day) - Used until noon" },
          { portuguese: 'Boa tarde', english: 'Good afternoon', breakdown: "'Boa' (good, feminine) + 'tarde' (afternoon) - Used from noon until sunset" },
          { portuguese: 'Boa noite', english: 'Good evening/night', breakdown: "'Boa' (good, feminine) + 'noite' (night) - Used after sunset" }
        ],
        common_mistakes: ["Don't use 'Bom noite' - noite is feminine, so it must be 'Boa noite'"],
        tips: ["Notice how 'Bom' changes to 'Boa' to match the gender of the noun: 'dia' (masculine) vs 'tarde/noite' (feminine)"]
      }
    ],
    'pt-br-lesson-a1.1': [
      {
        title: 'Portuguese Greetings',
        explanation: "Portuguese has different greetings depending on the time of day. Unlike English, these are used very consistently in daily interactions.",
        examples: [
          { portuguese: 'Bom dia', english: 'Good morning', breakdown: "'Bom' (good) + 'dia' (day) - Used until noon" },
          { portuguese: 'Boa tarde', english: 'Good afternoon', breakdown: "'Boa' (good, feminine) + 'tarde' (afternoon) - Used from noon until sunset" },
          { portuguese: 'Boa noite', english: 'Good evening/night', breakdown: "'Boa' (good, feminine) + 'noite' (night) - Used after sunset" }
        ],
        common_mistakes: ["Don't use 'Bom noite' - noite is feminine, so it must be 'Boa noite'"],
        tips: ["Notice how 'Bom' changes to 'Boa' to match the gender of the noun: 'dia' (masculine) vs 'tarde/noite' (feminine)"]
      }
    ]
  },

  dialectDifferences: [
    {
      category: 'You Form',
      description: "European Portuguese uses 'Tu' (informal) and 'Você' (formal), while Brazilian Portuguese primarily uses 'Você' for both.",
      european_example: 'Tu és muito simpático.',
      brazilian_example: 'Você é muito simpático.',
      english_translation: 'You are very nice.'
    },
    {
      category: 'Progressive Tense',
      description: "European Portuguese uses 'estar a + infinitive', while Brazilian Portuguese uses 'estar + gerund'.",
      european_example: 'Estou a comer.',
      brazilian_example: 'Estou comendo.',
      english_translation: 'I am eating.'
    },
    {
      category: 'Pronoun Placement',
      description: 'In European Portuguese, object pronouns usually follow the verb. In Brazilian Portuguese, they often precede it.',
      european_example: 'Amo-te.',
      brazilian_example: 'Te amo.',
      english_translation: 'I love you.'
    },
    {
      category: 'Vocabulary - Bus',
      description: 'Different words for common items.',
      european_example: 'Autocarro',
      brazilian_example: 'Ônibus',
      english_translation: 'Bus'
    },
    {
      category: 'Vocabulary - Train',
      description: 'Different words for common items.',
      european_example: 'Comboio',
      brazilian_example: 'Trem',
      english_translation: 'Train'
    }
  ]
};

// API wrapper that works in both Tauri and browser
const api = {
  async invoke(cmd, args = {}) {
    if (isTauri) {
      return await window.__TAURI__.core.invoke(cmd, args);
    }
    // Mock implementation for browser
    return this.mockInvoke(cmd, args);
  },

  mockInvoke(cmd, args) {
    switch (cmd) {
      case 'get_version':
        return '0.1.0';
      case 'get_app_name':
        return 'GreengoLingo';
      case 'get_progress_summary':
        return mockApi.progress;
      case 'get_current_dialect':
        return mockApi.dialect;
      case 'set_dialect':
        mockApi.dialect = args.dialect;
        return null;
      case 'get_lessons':
        return mockApi.mockLessons[mockApi.dialect] || [];
      case 'get_lessons_by_level':
        const lessons = mockApi.mockLessons[mockApi.dialect] || [];
        return lessons.filter(l => l.level_code.startsWith(args.level));
      case 'get_lesson':
        return JSON.stringify({ id: args.lesson_id });
      case 'get_lesson_questions':
        const questions = mockApi.mockQuestions[args.lesson_id] || [];
        return JSON.stringify(questions);
      case 'check_user_answer':
        const question = JSON.parse(args.question_json);
        let isCorrect = false;
        if (args.selected_option !== null && args.selected_option !== undefined) {
          isCorrect = question.options[args.selected_option]?.is_correct || false;
        } else {
          const userAnswer = args.answer_text.toLowerCase().trim();
          const correctAnswer = question.correct_answer.toLowerCase().trim();
          isCorrect = userAnswer === correctAnswer;
          
          // Check with accent leniency if in lenient mode
          if (!isCorrect && mockApi.typingMode === 'lenient') {
            const normalize = (s) => s.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
            isCorrect = normalize(userAnswer) === normalize(correctAnswer);
          }
        }
        return JSON.stringify({
          is_correct: isCorrect,
          correct_answer: question.correct_answer,
          user_answer: args.answer_text || question.options[args.selected_option]?.text || '',
          feedback: isCorrect ? 'Correct! Well done.' : `Incorrect. The correct answer is '${question.correct_answer}'.`,
          accent_issues_only: false,
          accent_mistakes: []
        });
      case 'record_answer':
        if (args.is_correct) {
          mockApi.progress.wordsLearned++;
        }
        return null;
      case 'toggle_dark_mode':
        mockApi.darkMode = !mockApi.darkMode;
        return mockApi.darkMode;
      case 'get_dark_mode':
        return mockApi.darkMode;
      case 'set_typing_mode':
        mockApi.typingMode = args.mode;
        return null;
      case 'get_typing_mode':
        return mockApi.typingMode;
      case 'get_dialect_differences':
        return JSON.stringify(mockApi.dialectDifferences);
      case 'initialize_user':
        mockApi.dialect = args.preferences.dialect;
        mockApi.typingMode = args.preferences.typing_mode;
        mockApi.darkMode = args.preferences.dark_mode;
        return null;
      case 'flag_question':
        console.log('Question flagged:', args.question_id);
        return null;
      default:
        console.warn('Unknown command:', cmd);
        return null;
    }
  }
};

// Application state
const state = {
  currentScreen: 'onboarding',
  selectedDialect: null,
  selectedTypingMode: 'lenient',
  currentLesson: null,
  currentQuestions: [],
  currentQuestionIndex: 0,
  selectedOption: null,
  showingCheatSheet: true,
  cheatSheets: []
};

// DOM Elements
const elements = {
  // Screens
  onboarding: document.getElementById('onboarding'),
  dashboard: document.getElementById('dashboard'),
  lesson: document.getElementById('lesson'),
  settings: document.getElementById('settings'),

  // Onboarding
  dialectCards: document.querySelectorAll('.dialect-card'),
  typingModeSelection: document.querySelector('.typing-mode-selection'),
  modeCards: document.querySelectorAll('.mode-card'),
  startLearningBtn: document.getElementById('startLearning'),

  // Dashboard
  currentLevel: document.getElementById('currentLevel'),
  accuracy: document.getElementById('accuracy'),
  streak: document.getElementById('streak'),
  wordsLearned: document.getElementById('wordsLearned'),
  levelTabs: document.querySelectorAll('.level-tab'),
  lessonsGrid: document.getElementById('lessonsGrid'),

  // Lesson
  backBtn: document.getElementById('backBtn'),
  lessonTitle: document.getElementById('lessonTitle'),
  progressIndicator: document.getElementById('progressIndicator'),
  cheatSheetPanel: document.getElementById('cheatSheetPanel'),
  cheatSheetContent: document.getElementById('cheatSheetContent'),
  closeCheatSheet: document.getElementById('closeCheatSheet'),
  questionPanel: document.getElementById('questionPanel'),
  questionContext: document.getElementById('questionContext'),
  questionPrompt: document.getElementById('questionPrompt'),
  optionsContainer: document.getElementById('optionsContainer'),
  typingContainer: document.getElementById('typingContainer'),
  answerInput: document.getElementById('answerInput'),
  submitAnswer: document.getElementById('submitAnswer'),
  showHint: document.getElementById('showHint'),
  feedbackPanel: document.getElementById('feedbackPanel'),
  feedbackContent: document.getElementById('feedbackContent'),
  nextQuestion: document.getElementById('nextQuestion'),
  flagQuestion: document.getElementById('flagQuestion'),

  // Settings
  settingsBtn: document.getElementById('settingsBtn'),
  settingsBackBtn: document.getElementById('settingsBackBtn'),
  dialectSelect: document.getElementById('dialectSelect'),
  typingModeSelect: document.getElementById('typingModeSelect'),
  darkModeToggle: document.getElementById('darkModeToggle'),
  darkModeBtn: document.getElementById('darkModeBtn'),
  viewDifferencesBtn: document.getElementById('viewDifferencesBtn'),

  // Modal
  dialectModal: document.getElementById('dialectModal'),
  dialectDifferences: document.getElementById('dialectDifferences'),
  closeModal: document.getElementById('closeModal'),

  // Footer
  appVersion: document.getElementById('appVersion'),

  // Character buttons
  charBtns: document.querySelectorAll('.char-btn')
};

// Screen navigation
function showScreen(screenName) {
  document.querySelectorAll('.screen').forEach(screen => {
    screen.classList.remove('active');
  });
  document.getElementById(screenName).classList.add('active');
  state.currentScreen = screenName;
}

// Initialize the app
async function initApp() {
  // Get version
  const version = await api.invoke('get_version');
  elements.appVersion.textContent = `v${version}`;

  // Check dark mode
  const darkMode = await api.invoke('get_dark_mode');
  document.body.classList.toggle('dark-mode', darkMode);
  elements.darkModeToggle.checked = darkMode;

  // Set up event listeners
  setupEventListeners();

  // Check if user has already onboarded (would use local storage in production)
  // For now, always show onboarding
  showScreen('onboarding');
}

// Setup event listeners
function setupEventListeners() {
  // Dialect selection
  elements.dialectCards.forEach(card => {
    card.addEventListener('click', () => {
      elements.dialectCards.forEach(c => c.classList.remove('selected'));
      card.classList.add('selected');
      state.selectedDialect = card.dataset.dialect;
      elements.typingModeSelection.style.display = 'block';
    });
  });

  // Typing mode selection
  elements.modeCards.forEach(card => {
    card.addEventListener('click', () => {
      elements.modeCards.forEach(c => c.classList.remove('active'));
      card.classList.add('active');
      state.selectedTypingMode = card.dataset.mode;
    });
  });

  // Start learning
  elements.startLearningBtn.addEventListener('click', async () => {
    if (!state.selectedDialect) {
      alert('Please select a dialect first');
      return;
    }

    await api.invoke('initialize_user', {
      preferences: {
        dialect: state.selectedDialect,
        typing_mode: state.selectedTypingMode,
        dark_mode: document.body.classList.contains('dark-mode')
      }
    });

    await loadDashboard();
    showScreen('dashboard');
  });

  // Level tabs
  elements.levelTabs.forEach(tab => {
    tab.addEventListener('click', async () => {
      elements.levelTabs.forEach(t => t.classList.remove('active'));
      tab.classList.add('active');
      await loadLessons(tab.dataset.level);
    });
  });

  // Back button
  elements.backBtn.addEventListener('click', () => {
    showScreen('dashboard');
    loadDashboard();
  });

  // Close cheat sheet
  elements.closeCheatSheet.addEventListener('click', () => {
    state.showingCheatSheet = false;
    elements.cheatSheetPanel.style.display = 'none';
    elements.questionPanel.style.display = 'block';
    showCurrentQuestion();
  });

  // Submit answer
  elements.submitAnswer.addEventListener('click', submitAnswer);

  // Answer input enter key
  elements.answerInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
      submitAnswer();
    }
  });

  // Show hint
  elements.showHint.addEventListener('click', () => {
    const question = state.currentQuestions[state.currentQuestionIndex];
    if (question.hint) {
      alert(question.hint);
    }
  });

  // Next question
  elements.nextQuestion.addEventListener('click', nextQuestion);

  // Flag question
  elements.flagQuestion.addEventListener('click', async () => {
    const question = state.currentQuestions[state.currentQuestionIndex];
    await api.invoke('flag_question', { question_id: question.id });
    alert('Question flagged for review. Thank you!');
  });

  // Character buttons
  elements.charBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      const char = btn.dataset.char;
      const input = elements.answerInput;
      const start = input.selectionStart;
      const end = input.selectionEnd;
      input.value = input.value.substring(0, start) + char + input.value.substring(end);
      input.focus();
      input.setSelectionRange(start + 1, start + 1);
    });
  });

  // Settings button
  elements.settingsBtn.addEventListener('click', async () => {
    await loadSettings();
    showScreen('settings');
  });

  // Settings back button
  elements.settingsBackBtn.addEventListener('click', () => {
    showScreen('dashboard');
  });

  // Dialect change
  elements.dialectSelect.addEventListener('change', async (e) => {
    await api.invoke('set_dialect', { dialect: e.target.value });
    state.selectedDialect = e.target.value;
    // Reload lessons when dialect changes
    await loadLessons('A1');
  });

  // Typing mode change
  elements.typingModeSelect.addEventListener('change', async (e) => {
    await api.invoke('set_typing_mode', { mode: e.target.value });
  });

  // Dark mode toggle
  elements.darkModeToggle.addEventListener('change', async () => {
    const isDark = await api.invoke('toggle_dark_mode');
    document.body.classList.toggle('dark-mode', isDark);
  });

  // Dark mode button in header
  elements.darkModeBtn.addEventListener('click', async () => {
    const isDark = await api.invoke('toggle_dark_mode');
    document.body.classList.toggle('dark-mode', isDark);
    elements.darkModeToggle.checked = isDark;
  });

  // View dialect differences
  elements.viewDifferencesBtn.addEventListener('click', async () => {
    await showDialectDifferences();
  });

  // Close modal
  elements.closeModal.addEventListener('click', () => {
    elements.dialectModal.style.display = 'none';
  });

  // Close modal on outside click
  elements.dialectModal.addEventListener('click', (e) => {
    if (e.target === elements.dialectModal) {
      elements.dialectModal.style.display = 'none';
    }
  });
}

// Load dashboard
async function loadDashboard() {
  const progress = await api.invoke('get_progress_summary');
  
  elements.currentLevel.textContent = progress.current_level || progress.currentLevel || 'A1.1';
  elements.accuracy.textContent = `${Math.round(progress.accuracy || 0)}%`;
  elements.streak.textContent = progress.streak || 0;
  elements.wordsLearned.textContent = progress.words_learned || progress.wordsLearned || 0;

  await loadLessons('A1');
}

// Load lessons for a level
async function loadLessons(level) {
  const lessons = await api.invoke('get_lessons_by_level', { level });
  
  elements.lessonsGrid.innerHTML = '';
  
  if (lessons.length === 0) {
    elements.lessonsGrid.innerHTML = `
      <div class="no-lessons">
        <p>No lessons available for this level yet.</p>
        <p class="hint">More content coming soon!</p>
      </div>
    `;
    return;
  }

  lessons.forEach(lesson => {
    const card = document.createElement('div');
    card.className = 'lesson-card';
    card.innerHTML = `
      <span class="level-badge">${lesson.level_code}</span>
      <h3>${lesson.title}</h3>
      <p>${lesson.description}</p>
      <span class="question-count">${lesson.total_questions} questions</span>
    `;
    card.addEventListener('click', () => startLesson(lesson));
    elements.lessonsGrid.appendChild(card);
  });
}

// Start a lesson
async function startLesson(lesson) {
  state.currentLesson = lesson;
  state.currentQuestionIndex = 0;
  state.showingCheatSheet = true;
  
  // Get questions
  const questionsJson = await api.invoke('get_lesson_questions', { lesson_id: lesson.id });
  state.currentQuestions = JSON.parse(questionsJson);

  // Get cheat sheets (mock for now)
  state.cheatSheets = mockApi.mockCheatSheets[lesson.id] || [];

  elements.lessonTitle.textContent = lesson.title;
  updateProgressIndicator();

  // Show cheat sheet first if available
  if (state.cheatSheets.length > 0) {
    showCheatSheet();
  } else {
    elements.cheatSheetPanel.style.display = 'none';
    elements.questionPanel.style.display = 'block';
    showCurrentQuestion();
  }

  elements.feedbackPanel.style.display = 'none';
  showScreen('lesson');
}

// Show cheat sheet
function showCheatSheet() {
  const cheatSheet = state.cheatSheets[0];
  
  let html = `
    <h3>${cheatSheet.title}</h3>
    <p>${cheatSheet.explanation}</p>
  `;

  if (cheatSheet.examples && cheatSheet.examples.length > 0) {
    html += '<div class="cheat-sheet-examples">';
    cheatSheet.examples.forEach(example => {
      html += `
        <div class="cheat-sheet-example">
          <span class="portuguese">${example.portuguese}</span>
          <span class="english">${example.english}</span>
          ${example.breakdown ? `<span class="breakdown">${example.breakdown}</span>` : ''}
        </div>
      `;
    });
    html += '</div>';
  }

  if (cheatSheet.common_mistakes && cheatSheet.common_mistakes.length > 0) {
    html += `
      <div class="cheat-sheet-mistakes">
        <h4>❌ Common Mistakes</h4>
        <ul>${cheatSheet.common_mistakes.map(m => `<li>${m}</li>`).join('')}</ul>
      </div>
    `;
  }

  if (cheatSheet.tips && cheatSheet.tips.length > 0) {
    html += `
      <div class="cheat-sheet-tips">
        <h4>💡 Tips</h4>
        <ul>${cheatSheet.tips.map(t => `<li>${t}</li>`).join('')}</ul>
      </div>
    `;
  }

  elements.cheatSheetContent.innerHTML = html;
  elements.cheatSheetPanel.style.display = 'block';
  elements.questionPanel.style.display = 'none';
}

// Show current question
function showCurrentQuestion() {
  const question = state.currentQuestions[state.currentQuestionIndex];
  if (!question) return;

  state.selectedOption = null;
  elements.answerInput.value = '';
  elements.answerInput.classList.remove('correct', 'incorrect');

  // Show context if available
  if (question.context) {
    elements.questionContext.textContent = question.context.scenario;
    elements.questionContext.style.display = 'block';
  } else {
    elements.questionContext.style.display = 'none';
  }

  // Show prompt
  elements.questionPrompt.textContent = question.prompt;

  // Show appropriate input type
  if (question.question_type === 'MultipleChoice') {
    elements.optionsContainer.style.display = 'flex';
    elements.typingContainer.style.display = 'none';
    
    elements.optionsContainer.innerHTML = '';
    question.options.forEach((option, index) => {
      const btn = document.createElement('button');
      btn.className = 'option-btn';
      btn.textContent = option.text;
      btn.addEventListener('click', () => selectOption(index));
      elements.optionsContainer.appendChild(btn);
    });
  } else {
    elements.optionsContainer.style.display = 'none';
    elements.typingContainer.style.display = 'block';
    elements.answerInput.focus();
  }

  // Show hint button if hint available
  elements.showHint.style.display = question.hint ? 'inline-block' : 'none';

  // Hide feedback
  elements.feedbackPanel.style.display = 'none';
  elements.questionPanel.style.display = 'block';
  
  updateProgressIndicator();
}

// Select an option
function selectOption(index) {
  state.selectedOption = index;
  const buttons = elements.optionsContainer.querySelectorAll('.option-btn');
  buttons.forEach((btn, i) => {
    btn.classList.toggle('selected', i === index);
  });
}

// Submit answer
async function submitAnswer() {
  const question = state.currentQuestions[state.currentQuestionIndex];
  
  let answerText = '';
  let selectedOption = null;

  if (question.question_type === 'MultipleChoice') {
    if (state.selectedOption === null) {
      alert('Please select an option');
      return;
    }
    selectedOption = state.selectedOption;
  } else {
    answerText = elements.answerInput.value.trim();
    if (!answerText) {
      alert('Please type your answer');
      return;
    }
  }

  const resultJson = await api.invoke('check_user_answer', {
    question_json: JSON.stringify(question),
    answer_text: answerText,
    selected_option: selectedOption
  });

  const result = JSON.parse(resultJson);

  // Record the answer
  await api.invoke('record_answer', {
    lesson_id: state.currentLesson.id,
    question_id: question.id,
    is_correct: result.is_correct
  });

  // Show feedback
  showFeedback(result, question);
}

// Show feedback
function showFeedback(result, question) {
  elements.questionPanel.style.display = 'none';
  elements.feedbackPanel.style.display = 'block';

  elements.feedbackContent.className = `feedback-content ${result.is_correct ? 'correct' : 'incorrect'}`;
  
  let html = `
    <h3>${result.is_correct ? '✓ Correct!' : '✗ Incorrect'}</h3>
    <p>${result.feedback}</p>
  `;

  if (!result.is_correct) {
    html += `<p class="correct-answer">Correct answer: ${result.correct_answer}</p>`;
  }

  if (question.explanation) {
    html += `<p class="explanation">${question.explanation}</p>`;
  }

  elements.feedbackContent.innerHTML = html;

  // Update option styling for multiple choice
  if (question.question_type === 'MultipleChoice') {
    const buttons = elements.optionsContainer.querySelectorAll('.option-btn');
    buttons.forEach((btn, index) => {
      if (question.options[index].is_correct) {
        btn.classList.add('correct');
      } else if (index === state.selectedOption) {
        btn.classList.add('incorrect');
      }
    });
  } else {
    // Update input styling for typing
    elements.answerInput.classList.add(result.is_correct ? 'correct' : 'incorrect');
  }
}

// Next question
function nextQuestion() {
  state.currentQuestionIndex++;
  
  if (state.currentQuestionIndex >= state.currentQuestions.length) {
    // Lesson complete
    showLessonComplete();
  } else {
    showCurrentQuestion();
  }
}

// Show lesson complete
function showLessonComplete() {
  elements.questionPanel.style.display = 'none';
  elements.feedbackPanel.style.display = 'block';
  
  elements.feedbackContent.className = 'feedback-content correct';
  elements.feedbackContent.innerHTML = `
    <h3>🎉 Lesson Complete!</h3>
    <p>Well done! You've completed "${state.currentLesson.title}".</p>
    <p>No hearts lost. No penalties. Just learning.</p>
  `;

  elements.nextQuestion.textContent = 'Back to Lessons';
  elements.nextQuestion.onclick = () => {
    elements.nextQuestion.textContent = 'Continue';
    elements.nextQuestion.onclick = nextQuestion;
    showScreen('dashboard');
    loadDashboard();
  };

  elements.flagQuestion.style.display = 'none';
}

// Update progress indicator
function updateProgressIndicator() {
  const current = state.currentQuestionIndex + 1;
  const total = state.currentQuestions.length;
  elements.progressIndicator.textContent = `${current}/${total}`;
}

// Load settings
async function loadSettings() {
  const dialect = await api.invoke('get_current_dialect');
  const typingMode = await api.invoke('get_typing_mode');
  const darkMode = await api.invoke('get_dark_mode');

  elements.dialectSelect.value = dialect;
  elements.typingModeSelect.value = typingMode;
  elements.darkModeToggle.checked = darkMode;
}

// Show dialect differences
async function showDialectDifferences() {
  const differencesJson = await api.invoke('get_dialect_differences');
  const differences = JSON.parse(differencesJson);

  let html = '';
  differences.forEach(diff => {
    html += `
      <div class="difference-card">
        <h3>${diff.category}</h3>
        <p>${diff.description}</p>
        <div class="difference-examples">
          <div class="example-box">
            <span class="label">🇵🇹 PT-PT</span>
            <span class="text">${diff.european_example}</span>
          </div>
          <div class="example-box">
            <span class="label">🇧🇷 PT-BR</span>
            <span class="text">${diff.brazilian_example}</span>
          </div>
        </div>
        <p style="margin-top: 1rem; font-style: italic; color: var(--text-muted);">
          English: ${diff.english_translation}
        </p>
      </div>
    `;
  });

  elements.dialectDifferences.innerHTML = html;
  elements.dialectModal.style.display = 'flex';
}

// Initialize the app when DOM is ready
document.addEventListener('DOMContentLoaded', initApp);
