class MoodPair { final int id; final String label; const MoodPair(this.id, this.label); }

enum UIMood { happy, sad, angry, neutral }

extension UIMoodParsing on String {
  UIMood toUIMood() {
    switch (trim().toLowerCase()) {
      case 'happy':  return UIMood.happy;
      case 'sad':    return UIMood.sad;
      case 'angry':  return UIMood.angry;
      case 'neutral':return UIMood.neutral;
      default:       return UIMood.neutral; // fallback
    }
  }
}

MoodPair mapUIMood(UIMood ui) {
  switch (ui) {
    case UIMood.happy:  return const MoodPair(1, 'Happy');
    case UIMood.sad:    return const MoodPair(2, 'Sad');
    case UIMood.angry:  return const MoodPair(3, 'Angry');
    case UIMood.neutral:return const MoodPair(4, 'Neutral');
  }
}