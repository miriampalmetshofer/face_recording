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
  static const double clockRadiusScale = 0.8; // Percentage of available radius
  static const double clockStrokeWidth = 4.0;
  static const double clockHandStrokeWidth = 2.0;
  static const double clockArrowLength = 20.0;
  static const double clockInstructionFontSize = 24.0;
}
