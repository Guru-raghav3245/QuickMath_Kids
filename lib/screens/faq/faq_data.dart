class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

final List<FAQItem> allFAQs = [
  FAQItem(
    question: "What is QuickMath Kids?",
    answer:
        "QuickMath Kids is an educational app that helps children practice basic math operations (addition, subtraction, multiplication, division, LCM, GCF) through interactive, audio-based quizzes.",
  ),
  FAQItem(
    question: "Who is this app designed for?",
    answer:
        "It’s ideal for kids aged 6-12 who are learning elementary math concepts, though it’s adaptable to various skill levels with customizable ranges.",
  ),
  FAQItem(
    question: "What are the main features?",
    answer:
        "The app offers audio questions via text-to-speech, customizable operations and ranges, flexible time limits, wrong answer tracking, quiz history, detailed results, PDF report sharing, dark mode, and offline use.",
  ),
  FAQItem(
    question: "Is QuickMath Kids free?",
    answer:
        "The app is free to download with a daily limit of 3 quizzes. A one-time payment of ₹300 unlocks Premium, which offers unlimited daily quizzes, advanced ranges, and custom voice settings.",
  ),
  FAQItem(
    question: "Is it safe for children?",
    answer:
        "Yes, the app is designed with safety in mind. It collects no personal data and is ad-free, making it suitable for kids.",
  ),
  FAQItem(
    question: "Can I set a time limit for practice?",
    answer:
        "Yes, use the scroll wheel on the home screen to set a limit from 1 to 60 minutes, or choose 'No time limit' to practice indefinitely.",
  ),
  FAQItem(
    question: "What happens if I answer a question wrong?",
    answer:
        "Wrong answers are saved in the 'Wrong Answers History' section (accessible from the drawer). You can review them and they’ll reappear in practice until mastered.",
  ),
  FAQItem(
    question: "Can I clear my wrong answers?",
    answer:
        "Yes, from the 'Wrong Answers History' screen, swipe to delete individual entries or use the clear button (with confirmation) to remove all.",
  ),
  FAQItem(
    question: "How do I share my quiz results?",
    answer:
        "After a quiz, tap 'Share Report' on the results screen to generate and share a PDF via messaging or social apps.",
  ),
  FAQItem(
    question: "Does the app work offline?",
    answer:
        "Yes, QuickMath Kids functions offline once installed—no internet required.",
  ),
  FAQItem(
    question: "What devices does it support?",
    answer:
        "Currently, it’s only available for Android devices via the Google Play Store.",
  ),
  FAQItem(
    question: "Can I switch to dark mode?",
    answer:
        "Yes, toggle dark mode from the drawer menu on the home screen for a comfortable viewing experience.",
  ),
  FAQItem(
    question: "How do I report a bug or suggest a feature?",
    answer:
        "Email us at master.guru.raghav@gmail.com with your feedback or suggestions.",
  ),
  FAQItem(
    question: "What languages are supported?",
    answer:
        "The app currently supports English only, with plans to add more languages in future updates.",
  ),
  FAQItem(
    question: "Can I track progress over time?",
    answer:
        "Yes! Premium users can access the 'Quiz History' screen to view past sessions, including scores and time taken. You can also rename or delete saved quizzes.",
  ),
  FAQItem(
    question: "What if I uninstall the app?",
    answer:
        "Uninstalling clears all data (like wrong answers and history) since there’s no cloud backup. Progress starts fresh upon reinstallation.",
  ),
  FAQItem(
    question: "Are there rewards for completing quizzes?",
    answer:
        "Not yet, but we’re considering adding badges or rewards in future updates to boost motivation.",
  ),
  FAQItem(
    question: "How can I contact support?",
    answer:
        "Reach out to us at master.guru.raghav@gmail.com for any assistance.",
  ),
  FAQItem(
    question: "How does the audio feature work?",
    answer:
        "The app uses text-to-speech to read math questions aloud. Tap the voice button during practice to hear the question, and tap again if you need it repeated.",
  ),
  FAQItem(
    question: "Can I pause or quit a quiz midway?",
    answer:
        "Yes, Premium users can pause a quiz to take a break. All users can 'Quit' to end the session early, though results are only saved if you finish normally.",
  ),
  FAQItem(
    question: "Why do some wrong answers reappear in practice?",
    answer:
        "The app prioritizes questions you’ve answered incorrectly before, pulling them from your 'Wrong Answers History' to help you master them.",
  ),
  FAQItem(
    question: "How accurate is the text-to-speech voice?",
    answer:
        "The voice is clear and reliable for English. You can also adjust the Pitch and Speech Rate in the Settings menu (Premium feature).",
  ),
  FAQItem(
    question: "Can I use the app on multiple devices?",
    answer:
        "Yes, but progress (like wrong answers) is stored locally. Your Premium purchase can be restored on any Android device using the same Google account.",
  ),
  FAQItem(
    question: "What happens when I master a wrong answer?",
    answer:
        "After answering a question correctly a few times (up to 3 sessions), it’s removed from your 'Wrong Answers History' to focus on new challenges.",
  ),
  FAQItem(
    question: "Can I practice only wrong answers?",
    answer:
        "Not directly, but wrong answers are automatically mixed into your practice sessions until you master them.",
  ),
  FAQItem(
    question: "How many questions are in a practice session?",
    answer:
        "There’s no fixed number—questions keep coming until you end the session manually or the time limit (if set) runs out.",
  ),
  FAQItem(
    question: "Can I adjust the volume or voice speed?",
    answer:
        "Yes! Go to 'Settings' in the drawer to adjust Volume, Pitch, and Speech Rate to customize the reading voice.",
  ),
  FAQItem(
    question: "What if the app crashes during a quiz?",
    answer:
        "If the app crashes, your current session won’t be saved. Restart the app and begin a new session from the home screen.",
  ),
  FAQItem(
    question: "Can I change the order of questions?",
    answer:
        "No, questions are generated randomly or pulled from your wrong answers history in a preset order to keep practice varied.",
  ),
  FAQItem(
    question: "Does the app use a lot of storage?",
    answer:
        "No, it’s lightweight. It stores only wrong answers and history locally, and temporary PDF reports are deleted after sharing.",
  ),
  FAQItem(
    question: "Can teachers use this app in class?",
    answer:
        "Yes, teachers can use it for individual or group practice. Share PDF reports to track student performance.",
  ),
  FAQItem(
    question: "Why does the timer count up sometimes?",
    answer:
        "If you select 'No time limit' on the home screen, the timer counts up to track your total practice time instead of counting down.",
  ),
  FAQItem(
    question: "Can I retry a quiz after finishing?",
    answer:
        "Not exactly—each session is new. Use the results to review, then start a fresh quiz with similar settings.",
  ),
  FAQItem(
    question: "What if my device runs out of battery mid-session?",
    answer:
        "The session won’t be saved if interrupted. Charge your device and start a new session when ready.",
  ),
  FAQItem(
    question: "Are there hints during practice?",
    answer:
        "Yes, a hint card appears during practice with general tips, though it doesn’t give specific answers to the current question.",
  ),
  FAQItem(
    question: "I bought Premium but it's not working. What do I do?",
    answer:
        "Go to the Purchase Screen and the app will automatically try to restore your purchase. Ensure you are logged into the same Google account used to buy it.",
  ),
  FAQItem(
    question: "I have a Promo Code. How do I use it?",
    answer:
        "Go to the 'Purchase Premium' screen and tap 'Redeem Promo Code'. Enter your code to unlock Premium features for free.",
  ),
  FAQItem(
    question: "How do I set practice reminders?",
    answer:
        "Open the 'Notifications' section in the drawer to schedule daily reminders so you never miss a practice session.",
  ),
];
