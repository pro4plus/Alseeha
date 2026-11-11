// نصوص عربية (بلهجة سودانية خفيفة) وإنجليزية.
class Strings {
  final bool isArabic;
  const Strings(this.isArabic);

  String get appTitle => isArabic ? 'السيجا السودانية' : 'Sudanese Seega';
  String get tagline => isArabic
      ? 'لعبة الحصار والدهاء من تراث السودان'
      : 'The game of siege and wit from Sudan';
  String get startGame => isArabic ? 'أبدأ اللعب' : 'Start Game';
  String get howToPlay => isArabic ? 'طريقة اللعب' : 'How to Play';
  String get aboutGame => isArabic ? 'عن اللعبة' : 'About the Game';
  String get playVsComputer =>
      isArabic ? 'العب ضد الكمبيوتر' : 'Play vs Computer';
  String get playVsFriend =>
      isArabic ? 'لاعبين على نفس الجهاز' : 'Two Players';
  String get chooseBoard =>
      isArabic ? 'اختر حجم اللوحة' : 'Choose Board Size';
  String get board5 => isArabic ? 'لوحة 5×5 — سريعة' : 'Board 5×5 — Quick';
  String get board7 => isArabic ? 'لوحة 7×7 — طويلة' : 'Board 7×7 — Long';
  String get chooseDifficulty =>
      isArabic ? 'اختر مستوى الكمبيوتر' : 'Choose Difficulty';
  String get easy => isArabic ? 'سهل' : 'Easy';
  String get medium => isArabic ? 'وسط' : 'Medium';
  String get hard => isArabic ? 'صعب' : 'Hard';
  String get easyDesc =>
      isArabic ? 'مناسب تتعلم عليه براحتك' : 'Relaxed — good to learn';
  String get mediumDesc =>
      isArabic ? 'بيعاقب الغلطات الواضحة' : 'Punishes clear mistakes';
  String get hardDesc =>
      isArabic ? 'ذكي شديد، فكّر قبل كل حركة' : 'Very smart — think ahead';
  String get chooseStones =>
      isArabic ? 'اختر الأحجار' : 'Choose Stones';
  String get player1Stone =>
      isArabic ? 'اختر حجر اللاعب 1' : 'Choose Player 1 Stone';
  String get player2Stone =>
      isArabic ? 'اختر حجر اللاعب 2' : 'Choose Player 2 Stone';
  String get computerStone =>
      isArabic ? 'اختر حجرك (الكمبيوتر ياخد التاني)' : 'Choose your stone';
  String get startPlaying => isArabic ? 'أبدأ اللعب' : 'Start Playing';
  String get placeStones =>
      isArabic ? 'ضع 3 أحجار في أي خانة فاضية (ما عدا الوسطى)' : 'Place 3 stones on any empty square (not the centre)';
  String get yourTurnPlace =>
      isArabic ? 'دورك: ضع 3 أحجار' : 'Your turn: place 3 stones';
  String get computerPlacing =>
      isArabic ? 'الكمبيوتر بيوزّع حجاره…' : 'Computer is placing…';
  String get computerThinking =>
      isArabic ? 'الكمبيوتر بيفكّر…' : 'Computer is thinking…';
  String get yourTurn => isArabic ? 'دورك' : 'Your turn';
  String get player1 => isArabic ? 'اللاعب 1' : 'Player 1';
  String get player2 => isArabic ? 'اللاعب 2' : 'Player 2';
  String get you => isArabic ? 'أنت' : 'You';
  String get computer => isArabic ? 'الكمبيوتر' : 'Computer';
  String get turn => isArabic ? 'الدور' : 'Turn';
  String get captured => isArabic ? 'أكلت' : 'Captured';
  String get remaining => isArabic ? 'باقي' : 'Left';
  String get hint => isArabic ? 'تلميح' : 'Hint';
  String get undo => isArabic ? 'تراجع' : 'Undo';
  String get newGame => isArabic ? 'لعبة جديدة' : 'New Game';
  String get home => isArabic ? 'الرئيسية' : 'Home';
  String get victory => isArabic ? 'مبروووك!' : 'Victory!';
  String get youWon => isArabic ? 'فزت! شغل نضيف والله' : 'You won! Well played';
  String get computerWon =>
      isArabic ? 'الكمبيوتر فاز، جرّب تاني' : 'Computer won — try again';
  String playerWon(String name) =>
      isArabic ? '$name فاز!' : '$name wins!';
  String get draw => isArabic ? 'تعادل!' : 'Draw!';
  String get backHome =>
      isArabic ? 'العودة للرئيسية' : 'Back to Home';
  String get playAgain => isArabic ? 'العب تاني' : 'Play Again';
  String get confirmExit => isArabic ? 'تأكيد' : 'Confirm';
  String get exitQuestion => isArabic
      ? 'متأكد داير تطلع من اللعبة؟'
      : 'Are you sure you want to leave the game?';
  String get yes => isArabic ? 'أيوا' : 'Yes';
  String get no => isArabic ? 'لا' : 'No';
  String get close => isArabic ? 'إغلاق' : 'Close';
  String get contactUs => isArabic ? 'اتصل بنا' : 'Contact Us';
  String get score => isArabic ? 'النتيجة' : 'Score';
  String get wins => isArabic ? 'فوز' : 'Wins';
  String get losses => isArabic ? 'خسارة' : 'Losses';
  String get draws => isArabic ? 'تعادل' : 'Draws';
  String get sound => isArabic ? 'الصوت' : 'Sound';
  String get howToPlayBody => isArabic
      ? '1) كل لاعب يوزّع حجاره: 3 أحجار في كل دور، في أي خانة فاضية ما عدا الخانة الوسطى — الوسطى تفضل فاضية لأن أول حركة في اللعبة تكون إليها.\n\n'
          '2) بعد التوزيع، حرّك حجر واحد خطوة واحدة أفقي أو عمودي لخانة فاضية، والوسطى مسموحة.\n\n'
          '3) الأكل: إذا حركت حجرك فحصرت حجر خصم بين حجرين من حجارتك (أفقي أو عمودي)، تأكله. الدخول بين حجرَي خصم ما بيأكلك.\n\n'
          '4) الخانة الوسطى ما عندها حماية خاصة: الحجر الفيها يؤكل كأي حجر تاني إذا حُصر.\n\n'
          '5) الفوز: من يأكل كل حجارة خصمه (يتركه بلا أي حجر) يفوز. وإذا لم يكن عندك أي حركة، يُمرَّر الدور للخصم.\n\n'
          'نصيحة: وزّع حجارتك متشابكة مع حجارة الخصم وقريبة من الوسطى — التكتل في زاوية يعطّل اللعبة.'
      : '1) Place stones: 3 per turn on any empty square except the centre — the centre stays empty because the first move of the game goes there.\n\n'
          '2) Then move one stone one step horizontally or vertically to an empty square (centre allowed).\n\n'
          '3) Capture: if your move sandwiches an enemy stone between two of yours (horizontal or vertical), it is eaten. Moving between two enemies is safe.\n\n'
          '4) The centre has no special protection: a stone on it is eaten like any other if sandwiched.\n\n'
          '5) Win by eating all of your opponent\'s stones. If you have no legal move, the turn passes to your opponent.\n\n'
          'Tip: spread your stones interleaved with your opponent\'s and near the centre — clustering in a corner stalls the game.';
  String get aboutBody => isArabic
      ? 'السيجا لعبة تراثية مشهورة في السودان ومصر، يلعبها الناس في الجلسات والقهاوي منذ زمن طويل. تعتمد على التخطيط والحصار، بلا حظ — الفوز فيها بالدهاء بس.\n\n'
          'هذه النسخة بطابع سوداني: ألوان النيل والرمل النوبي، مع لعب ضد الكمبيوتر بثلاثة مستويات.'
      : 'Seega is a traditional game beloved in Sudan and Egypt, played in gatherings and cafés for generations. Pure strategy, no luck — win by wit alone.\n\n'
          'This version has a Sudanese touch: Nile and Nubian sand colours, with a computer opponent in three levels.';
  String get invalidMove =>
      isArabic ? 'حركة ما بتنفع' : 'That move is not allowed';
  String get selectStoneFirst =>
      isArabic ? 'اضغط على حجرك أولاً' : 'Tap one of your stones first';
  String get placementDone =>
      isArabic ? 'التوزيع اكتمل — يلا نلعب!' : 'Placement done — let\'s play!';
  String get passTurn => isArabic
      ? 'ما عندك حركة — الدور مرّر للخصم'
      : 'No moves — turn passed to the opponent';
}
