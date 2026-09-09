/// Languages an invoice can be labelled with.
enum AppLanguage {
  english('English'),
  urdu('Urdu'),
  arabic('Arabic'),
  french('French'),
  spanish('Spanish');

  const AppLanguage(this.label);

  final String label;

  static AppLanguage fromLabel(String label) => values.firstWhere(
        (language) => language.label == label,
        orElse: () => AppLanguage.english,
      );
}
