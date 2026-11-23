class AppConstants {
  static const String appName = 'PhotoKids Studio';
  static const int trashRetentionDays = 30;
  static const String defaultParentPin = '1234';

  // Supported Extensions
  static const List<String> supportedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'heic',
    'bmp',
  ];

  // Sticker Emojis (kid-friendly categories)
  static const Map<String, List<String>> stickerCategories = {
    'Tiere 🐶': ['🐶', '🐱', '🐰', '🐼', '🦊', '🐻', '🦁', '🦄', '🐸', '🐨', '🐧', '🦋'],
    'Herzen & Sterne 💖': ['💖', '💕', '⭐', '🌟', '✨', '🌈', '🔥', '🎈', '🎉', '💫'],
    'Blumen 🌸': ['🌸', '🌺', '🌻', '🌼', '🌷', '🌹', '🍀', '🌴', '🍄'],
    'Smileys 😊': ['😊', '😍', '🥳', '😎', '😜', '🤩', '😻', '😇', '🤠', '🤗'],
  };
}
