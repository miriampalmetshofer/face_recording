class AppConfig {
  // Recording durations
  static const int enrollmentDurationSeconds = 15;
  static const int recordingDurationSeconds = 10;

  // UI Layout constraints for web/desktop
  static const double configScreenMaxWidth = 600;
  static const double recordingScreenMaxWidth = 800;

  // Enrollment head turning instruction thresholds (0.0 to 1.0)
  static const double headTurnRightThreshold = 0.25;
  static const double headTurnLeftThreshold = 0.5;
  static const double headTurnUpThreshold = 0.75;
  // After headTurnUpThreshold, head turns down

  // Clock overlay visual settings
  static const double clockRadiusScale = 0.6;
  static const double clockRadiusScaleMobile = 0.5; // Smaller for mobile
  static const double clockStrokeWidth = 4.0;
  static const double clockHandStrokeWidth = 2.0;
  static const double clockArrowLength = 20.0;
  static const double clockInstructionFontSize = 24.0;
  static const double clockDotRadius = 12.0;
  static const double clockDotRadiusMobile = 8.0; // Smaller for mobile
  static const double clockDotToCircleProgress = 0.15;

  // Task instructions
  static const Map<String, String> taskInstructions = {
    'Task1': 'Wenn du in nächster Zeit etwas Neues lernen könntest – egal was –, was wäre das? Erkläre, warum du es lernen möchtest und wie du am besten anfangen würdest.',
    'Task2': 'Überlege dir eine Gewohnheit in deinem Alltag, die du gerne verbessern würdest. Beschreibe kurz, warum du diese verändern möchtest und wie du dabei vorgehen würdest.',
  };

  static String getTaskInstruction(String task) {
    return taskInstructions[task] ?? 'Keine Aufgabenbeschreibung verfügbar.';
  }

  static String getFormattedDateTime() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';
  }

  static String getSettingCode(String setting) {
    switch (setting) {
      case 'easy':
        return 'easy';
      case 'tricky angle':
        return 'tricky_angle';
      case 'tricky lighting':
        return 'tricky_lighting';
      default:
        return setting.replaceAll(' ', '_');
    }
  }
}
