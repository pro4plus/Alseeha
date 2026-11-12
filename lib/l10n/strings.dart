// نصوص عربية (بلهجة سودانية خفيفة) وإنجليزية.
class Strings {
  final bool isArabic;
  const Strings(this.isArabic);

  String get homeTitle => isArabic ? 'السيجا' : 'Seega';
  String get homeSubtitle => isArabic
      ? 'السودانية · لعبة الحصار والدهاء'
      : 'Sudanese · The game of siege and wit';
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
      isArabic ? 'لاعبان على جهاز واحد' : 'Two players on one device';
  String get threeLevels =>
      isArabic ? '٣ مستويات — سهل، وسط، صعب' : '3 levels — easy, medium, hard';
  String get sameDevice =>
      isArabic ? 'نفس الجهاز، وجهاً لوجه' : 'Same device, face to face';
  String get chooseBoard =>
      isArabic ? 'اختر حجم اللوحة' : 'Choose Board Size';
  String get board5 => isArabic ? 'لوحة 5×5 — سريعة' : 'Board 5×5 — Quick';
  String get board7 => isArabic ? 'لوحة 7×7 — طويلة' : 'Board 7×7 — Long';
  String get board5Short => isArabic ? '5×5 سريعة' : '5×5 Quick';
  String get board7Short => isArabic ? '7×7 طويلة' : '7×7 Long';
  String get quick => isArabic ? 'سريعة' : 'Quick';
  String get long => isArabic ? 'طويلة' : 'Long';
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
  String get chooseYourStoneFirst =>
      isArabic ? 'اختر حجرك أولاً' : 'Choose your stone first';
  String get chooseOpponentStoneFirst => isArabic
      ? 'اختر حجر الخصم'
      : 'Choose the opponent\u2019s stone';
  String get chooseStoneP1First =>
      isArabic ? 'اختر حجر اللاعب 1' : 'Choose Player 1\u2019s stone';
  String get chooseStoneP2First =>
      isArabic ? 'اختر حجر اللاعب 2' : 'Choose Player 2\u2019s stone';
  String get startPlaying => isArabic ? 'أبدأ اللعب' : 'Start Playing';
  String get placeStones =>
      isArabic ? 'ضع 3 أحجار في أي خانة فاضية (ما عدا الوسطى)' : 'Place 3 stones on any empty square (not the centre)';
  String get placeThree => isArabic ? 'ضع 3 أحجار' : 'Place 3 stones';
  String get yourTurnPlace =>
      isArabic ? 'دورك: ضع 3 أحجار' : 'Your turn: place 3 stones';
  String get computerPlacing =>
      isArabic ? 'الكمبيوتر بيوزّع حجاره…' : 'Computer is placing…';
  String get computerThinking =>
      isArabic ? 'الكمبيوتر بيفكّر…' : 'Computer is thinking…';
  String get yourTurn => isArabic ? 'دورك' : 'Your turn';
  String get turnBadge => isArabic ? 'الدور' : 'Turn';
  String get player1 => isArabic ? 'اللاعب 1' : 'Player 1';
  String get player2 => isArabic ? 'اللاعب 2' : 'Player 2';
  String get you => isArabic ? 'أنت' : 'You';
  String get computer => isArabic ? 'الكمبيوتر' : 'Computer';
  String get turn => isArabic ? 'الدور' : 'Turn';
  String get captured => isArabic ? 'أكلت' : 'Captured';
  String get remaining => isArabic ? 'باقي' : 'Left';

  // ---- شاشات v4 ----
  String get sitToPlay => isArabic ? 'اجلس للعب' : 'Sit Down to Play';
  String get againstWho => isArabic ? 'ضد مَن؟' : 'Against whom?';
  String get elderYoung => isArabic ? 'ود البلد' : 'Wad Elbalad';
  String get elderTeacher => isArabic ? 'الأستاذ' : 'The Teacher';
  String get elderElder => isArabic ? 'الشيخ' : 'The Sheikh';
  String get boardSection => isArabic ? 'اللوحة' : 'Board';
  String get yourPebble => isArabic ? 'حجرك' : 'Your stone';
  String computerTakes(String pebble) =>
      isArabic ? 'الكمبيوتر ياخد $pebble' : 'Computer takes $pebble';
  String get letsGo => isArabic ? 'يلا' : 'Let\u2019s go';
  String get playVsComputerCaption => isArabic
      ? 'اجلس قبالة الشيخ وجرّب حظك'
      : 'Sit across from the Sheikh and try your luck';
  String get playVsFriendCaption => isArabic
      ? 'تحدّ صديقك وجهاً لوجه'
      : 'Challenge a friend face to face';
  String get tiktokLink => isArabic ? 'تيك توك @nubax' : 'TikTok @nubax';
  String get turnLineChoose => isArabic
      ? 'دورك: اختر حجراً ثم وجهته'
      : 'Your turn: choose a stone, then its destination';
  String turnOf(String name) =>
      isArabic ? 'الدور: $name' : 'Turn: $name';
  String get playAgainCaption =>
      isArabic ? 'نفس الإعدادات' : 'Same settings';
  String get hint => isArabic ? 'تلميح' : 'Hint';
  String get undo => isArabic ? 'تراجع' : 'Undo';
  String get menu => isArabic ? 'القائمة' : 'Menu';
  String get newGame => isArabic ? 'لعبة جديدة' : 'New Game';
  String get home => isArabic ? 'الرئيسية' : 'Home';
  String get victory => isArabic ? 'مبروووك!' : 'Victory!';
  String get youWon => isArabic ? 'فزت! شغل نضيف والله' : 'You won! Well played';
  String get computerWon =>
      isArabic ? 'الكمبيوتر فاز، جرّب تاني' : 'Computer won — try again';
  String get youLost =>
      isArabic ? 'خسرت هالمرة' : 'You lost this time';
  String get tryAgainLine => isArabic
      ? 'ما مشكلة — المرة الجاية ليك، ركّز على الوسطى'
      : 'No worries — next time is yours. Watch the centre.';
  String get drawLine => isArabic
      ? 'تعادل — متساويين في الدهاء'
      : 'A draw — evenly matched in wit.';
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
  String get volume => isArabic ? 'مستوى الصوت' : 'Volume';
  String get haptics => isArabic ? 'الاهتزاز' : 'Haptics';
  String get language => isArabic ? 'اللغة' : 'Language';
  String get arabic => isArabic ? 'العربية' : 'Arabic';
  String get english => isArabic ? 'الإنجليزية' : 'English';
  String get settings => isArabic ? 'الإعدادات' : 'Settings';
  String get pause => isArabic ? 'إيقاف مؤقت' : 'Paused';
  String get resume => isArabic ? 'واصل اللعب' : 'Resume';
  String get restart => isArabic ? 'أعد اللعب' : 'Restart';
  String get leaveGame => isArabic ? 'اطلع من اللعبة' : 'Leave game';
  String get soundOn => isArabic ? 'الصوت شغال' : 'Sound on';
  String get soundOff => isArabic ? 'الصوت مقفول' : 'Sound off';
  String get letsPlay => isArabic ? 'يلا نلعب!' : 'Let\u2019s play!';
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
      isArabic ? 'التوزيع اكمل — يلا نلعب!' : 'Placement done — let\u2019s play!';
  String get passTurn => isArabic
      ? 'ما عندك حركة — الدور مرّر للخصم'
      : 'No moves — turn passed to the opponent';

  // ---- صفحات طريقة اللعب (3 صفحات) ----
  String get howPage1Title => isArabic ? '١. التوزيع' : '1. Placement';
  String get howPage1Body => isArabic
      ? 'كل لاعب يضع 3 أحجار في كل دور، في أي خانة فاضية ما عدا الخانة الوسطى. الوسطى تفضل فاضية لأن أول حركة في اللعبة تكون إليها.'
      : 'Each player places 3 stones per turn on any empty square except the centre. The centre stays empty because the first move of the game goes there.';
  String get howPage2Title => isArabic ? '٢. الحركة' : '2. Movement';
  String get howPage2Body => isArabic
      ? 'بعد اكتمال التوزيع، حرّك حجراً واحداً خطوة واحدة أفقياً أو عمودياً إلى خانة فاضية. الوسطى مسموحة كوجهة.'
      : 'After placement, move one stone a single step horizontally or vertically to an empty square. The centre is allowed as a destination.';
  String get howPage3Title => isArabic ? '٣. الأكل والفوز' : '3. Capture & win';
  String get howPage3Body => isArabic
      ? 'إذا حصرت حجر خصم بين حجرين من حجارتك تأكله. الوسطى بلا حماية. من يترك خصمه بلا أي حجر يفوز، ومن بلا حركة يُمرَّر دوره.'
      : 'If you sandwich an enemy stone between two of yours, it is eaten. The centre has no protection. Leave your opponent with no stones to win; a player with no move passes the turn.';

  // ---- تسميات الوصول للوحة (لقرّاء الشاشة) ----
  String tileLabel(int row, int col) =>
      isArabic ? 'صف ${row + 1}، عمود ${col + 1}' : 'Row ${row + 1}, column ${col + 1}';
  String get tileEmpty => isArabic ? 'خانة فاضية' : 'Empty square';
  String get tileYourStone => isArabic ? 'حجرك' : 'Your stone';
  String get tileOpponentStone => isArabic ? 'حجر الخصم' : 'Opponent stone';
  String get tileCentre => isArabic ? 'الخانة الوسطى' : 'Centre square';
}
