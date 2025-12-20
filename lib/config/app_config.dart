class AppConfig {
  // Recording durations
  static const int enrollmentDurationSeconds = 15;
  static const int recordingDurationSeconds = 60 * 3;

  // Camera settings
  static const int cameraFps = 30;

  // UI Layout constraints for web/desktop
  static const double configScreenMaxWidth = 600;
  static const double recordingScreenMaxWidth = 800;

  // Enrollment dot behavior thresholds (0.0 to 1.0)
  static const double headStayFrontalThreshold = 0.1; // Stay looking straight for frontal capture

  // Clock overlay visual settings
  static const double clockRadiusScale = 0.6;
  static const double clockRadiusScaleMobile = 0.5; // Smaller for mobile
  static const double clockStrokeWidth = 4.0;
  static const double clockArrowLength = 20.0;
  static const double clockDotRadius = 12.0;
  static const double clockDotRadiusMobile = 8.0; // Smaller for mobile
  static const double clockDotToCircleProgress = 0.15;

  // Task instructions
  static const Map<String, String> taskInstructions = {
    'Task1': 'Wenn du in nächster Zeit etwas Neues lernen könntest – egal was –, was wäre das? Erkläre, warum du es lernen möchtest und wie du am besten anfangen würdest.',
    'Task2': 'Überlege dir eine Gewohnheit in deinem Alltag, die du gerne verbessern würdest. Beschreibe kurz, warum du diese verändern möchtest und wie du dabei vorgehen würdest.',
    'Task3': 'Erzähle von einer Situation, in der du kürzlich etwas Neues gelernt hast, und was dir dabei besonders aufgefallen ist.',
    'Task4': 'Wenn du einen Ratschlag an dein Ich aus der Vergangenheit schreiben könntest, welcher wäre das und warum?',
    'Task5': 'Bitte schreibe Satz für Satz von den Zetteln ab.'
  };

  /*
  static const Map<String, String> taskInstructions = {
  'Task1': 'If you could learn something new in the near future – anything at all – what would it be? Explain why you want to learn it and how you would get started.',
  'Task2': 'Think of a habit in your daily life that you would like to improve. Briefly describe why you want to change it and how you would go about it.',
  'Task3': 'Describe a situation in which you recently learned something new and what stood out to you during the experience.',
  'Task4': 'If you could write a piece of advice to your past self, what would it be and why?',
  'Task5': 'Please write the sentences from the papers down, one sentence at a time.'
};
   */

  static String getTaskInstruction(String task) {
    return taskInstructions[task] ?? 'Keine Aufgabenbeschreibung verfügbar.';
  }

  static String getFormattedDateTime() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';
  }
}
