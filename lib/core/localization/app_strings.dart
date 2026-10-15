import 'app_language.dart';

class AppStrings {
  AppStrings._();

  static String t(AppLanguage lang, {required String en, required String ta}) {
    return lang == AppLanguage.ta ? ta : en;
  }

  // App & Navigation
  static String appTitle(AppLanguage lang) =>
      t(lang, en: 'SmartTea AIoT', ta: 'ஸ்மார்ட் டீ AIoT');

  static String appSubtitle(AppLanguage lang) =>
      t(lang, en: 'Smart Tea Cultivation & Advisory', ta: 'நுண்ணறிவு தேயிலை சாகுபடி மற்றும் வழிகாட்டி');

  static String navHome(AppLanguage lang) =>
      t(lang, en: 'Home', ta: 'முகப்பு');

  static String navAnalysis(AppLanguage lang) =>
      t(lang, en: 'Leaf Analysis', ta: 'இலை ஆய்வு');

  static String navKnowledge(AppLanguage lang) =>
      t(lang, en: 'Tea Knowledge', ta: 'தேயிலை அறிவு');

  static String navHistory(AppLanguage lang) =>
      t(lang, en: 'History', ta: 'வரலாறு');

  static String navSettings(AppLanguage lang) =>
      t(lang, en: 'Settings', ta: 'அமைப்புகள்');

  // Home Dashboard
  static String farmerGreeting(AppLanguage lang) =>
      t(lang, en: 'Vanakkam, Planter!', ta: 'வணக்கம், விவசாயி!');

  static String estateOverview(AppLanguage lang) =>
      t(lang, en: 'Highland Tea Estate Overview', ta: 'மலைத்தோட்ட தேயிலை மேலோட்டம்');

  static String foundationBadge(AppLanguage lang) =>
      t(lang, en: 'Milestone 1 • Foundation App Active', ta: 'மைல்ஸ்டோன் 1 • அடிப்படை செயலி இயங்குகிறது');

  static String quickActionsTitle(AppLanguage lang) =>
      t(lang, en: 'Quick Farm Actions', ta: 'விரைவு நடவடிக்கைகள்');

  static String actionScanLeaf(AppLanguage lang) =>
      t(lang, en: 'Screen Leaf Disease', ta: 'இலை நோய் ஆய்வு');

  static String actionScanLeafDesc(AppLanguage lang) =>
      t(lang, en: 'Upload or capture a tea leaf photo for inspection', ta: 'ஆய்வுக்காக தேயிலை புகைப்படத்தை பதிவேற்றவும்');

  static String actionDiseaseGuide(AppLanguage lang) =>
      t(lang, en: 'Disease & Pest Guide', ta: 'நோய் மற்றும் பூச்சி வழிகாட்டி');

  static String actionDiseaseGuideDesc(AppLanguage lang) =>
      t(lang, en: 'Field identification for Blister Blight, Grey Blight & more', ta: 'கொப்புள நோய், சாம்பல் கருகல் பற்றிய வழிகாட்டல்');

  static String actionInspectionLogs(AppLanguage lang) =>
      t(lang, en: 'Recent Scans', ta: 'சமீபத்திய ஆய்வுகள்');

  static String actionInspectionLogsDesc(AppLanguage lang) =>
      t(lang, en: 'View captured leaf inspection records', ta: 'சேமிக்கப்பட்ட இலை ஆய்வு பதிவுகளை காண்க');

  // Telemetry Mock/Preview Notice
  static String microclimateTitle(AppLanguage lang) =>
      t(lang, en: 'Field Microclimate Status', ta: 'தோட்ட நுண் காலநிலை நிலை');

  static String telemetryNotice(AppLanguage lang) =>
      t(lang, en: 'Hardware Telemetry • Connected in Milestone 4', ta: 'சென்சார் இணைப்பு • மைல்ஸ்டோன் 4 இல் வரும்');

  static String soilMoisture(AppLanguage lang) =>
      t(lang, en: 'Soil Moisture', ta: 'மண் ஈரப்பதம்');

  static String canopyTemp(AppLanguage lang) =>
      t(lang, en: 'Canopy Temp', ta: 'தாவர வெப்பநிலை');

  static String relativeHumidity(AppLanguage lang) =>
      t(lang, en: 'Relative Humidity', ta: 'ஒப்பீட்டு ஈரப்பதம்');

  static String dailyAdvisoryTitle(AppLanguage lang) =>
      t(lang, en: "Today's Agronomic Advisory", ta: 'இன்றைய வேளாண் வழிகாட்டல்');

  static String dailyAdvisoryBody(AppLanguage lang) => t(
        lang,
        en: 'Maintain 7-to-10 day plucking intervals for "two leaves and a bud". High morning humidity increases fungal spore release; inspect shaded depressions for early Blister Blight blisters.',
        ta: '"இரண்டு இலைகள் மற்றும் ஒரு மொட்டு" கொழுந்து பறிப்பை 7-10 நாட்களுக்கு ஒருமுறை மேற்கொள்ளவும். காலை நேர ஈரப்பதம் பூஞ்சை பரவலை அதிகரிக்கும்; நிழல் உள்ள பகுதிகளில் கொப்புள நோயை கண்காணிக்கவும்.',
      );

  // Leaf Analysis Screen
  static String leafAnalysisTitle(AppLanguage lang) =>
      t(lang, en: 'Leaf Disease Screening', ta: 'இலை நோய் பரிசோதனை');

  static String leafAnalysisSubtitle(AppLanguage lang) => t(
        lang,
        en: 'Capture or select a high-resolution photo of the affected tea leaf for inspection.',
        ta: 'பரிசோதனைக்காக பாதிக்கப்பட்ட தேயிலையின் தெளிவான புகைப்படத்தை எடுக்கவும் அல்லது தேர்ந்தெடுக்கவும்.',
      );

  static String uploadPrompt(AppLanguage lang) =>
      t(lang, en: 'No leaf photo selected yet', ta: 'இன்னும் இலை புகைப்படம் தேர்ந்தெடுக்கப்படவில்லை');

  static String uploadHint(AppLanguage lang) => t(
        lang,
        en: 'Tap below to capture with Camera or pick from Gallery',
        ta: 'கேமரா மூலம் எடுக்க அல்லது கேலரியிலிருந்து தேர்வு செய்ய கீழே அழுத்தவும்',
      );

  static String btnCamera(AppLanguage lang) =>
      t(lang, en: 'Take Photo', ta: 'கேமரா மூலம் எடு');

  static String btnGallery(AppLanguage lang) =>
      t(lang, en: 'Choose from Gallery', ta: 'கேலரியில் இருந்து எடு');

  static String btnRemoveImage(AppLanguage lang) =>
      t(lang, en: 'Remove Leaf Photo', ta: 'படத்தை நீக்கு');

  static String btnChangeImage(AppLanguage lang) =>
      t(lang, en: 'Pick Another Photo', ta: 'வேறு படம் எடு');

  static String btnAnalyze(AppLanguage lang) =>
      t(lang, en: 'Screen Leaf Health', ta: 'இலையை ஆய்வு செய்');

  static String imageSelectedBadge(AppLanguage lang) =>
      t(lang, en: 'Leaf photo ready for inspection', ta: 'இலை புகைப்படம் ஆய்வுக்கு தயார்');

  static String cancelledMsg(AppLanguage lang) =>
      t(lang, en: 'Image selection was cancelled', ta: 'படம் தேர்வு ரத்து செய்யப்பட்டது');

  static String removedMsg(AppLanguage lang) =>
      t(lang, en: 'Leaf image has been removed', ta: 'இலை புகைப்படம் நீக்கப்பட்டது');

  // CRITICAL REQUIREMENT: Clear disclaimer that disease prediction is unavailable
  static String aiModelOfflineTitle(AppLanguage lang) =>
      t(lang, en: 'AI Model Status: Offline / Pending Integration', ta: 'AI மாதிரி நிலை: ஆஃப்லைன் / இணைப்பு நிலுவையில் உள்ளது');

  static String aiModelOfflineDisclaimer(AppLanguage lang) => t(
        lang,
        en: 'Disease classification and AI inferences are currently UNAVAILABLE. A custom deep learning model (ResNet/ViT) is being prepared and will be deployed in Milestone 3. This application does not display fake or simulated AI diagnosis results.',
        ta: 'நோய் கண்டறிதல் மற்றும் AI கணிப்புகள் தற்போது கிடைக்கவில்லை. தனிப்பயன் ஆழ்ந்த கற்றல் மாதிரி (ResNet/ViT) உருவாக்கப்பட்டு வருகிறது மற்றும் மைல்ஸ்டோன் 3 இல் இணைக்கப்படும். இந்த செயலி எந்தவொரு போலி அல்லது பாசாங்கு AI முடிவுகளையும் காட்டாது.',
      );

  static String dialogModelUnavailableTitle(AppLanguage lang) =>
      t(lang, en: 'AI Prediction Unavailable', ta: 'AI கணிப்பு கிடைக்கவில்லை');

  static String dialogModelUnavailableBody(AppLanguage lang) => t(
        lang,
        en: 'No machine learning inference model is connected in Milestone 1 (Foundation).\n\nReal automated diagnosis will be enabled in Milestone 3 once model training and backend integration are complete.\n\nIn the meantime, you can consult the "Tea Knowledge" tab for verified agronomic disease descriptions and field management practices.',
        ta: 'மைல்ஸ்டோன் 1 (அடிப்படை) இல் எந்த இயந்திர கற்றல் மாதிரியும் இணைக்கப்படவில்லை.\n\nமாதிரி பயிற்சி மற்றும் பின்தள இணைப்பு முடிந்ததும் மைல்ஸ்டோன் 3 இல் உண்மையான தானியங்கி கண்டறிதல் செயல்படுத்தப்படும்.\n\nஅதுவரை, சரிபார்க்கப்பட்ட வேளாண்மை நோய் விளக்கங்கள் மற்றும் கள மேலாண்மை நடைமுறைகளுக்கு "தேயிலை அறிவு" பகுதியை பார்வையிடலாம்.',
      );

  static String dialogBtnOk(AppLanguage lang) =>
      t(lang, en: 'Understood', ta: 'புரிந்துகொண்டேன்');

  static String dialogBtnViewKnowledge(AppLanguage lang) =>
      t(lang, en: 'Open Tea Knowledge', ta: 'தேயிலை அறிவை பார்க்க');

  // Tea Knowledge Screen
  static String teaKnowledgeTitle(AppLanguage lang) =>
      t(lang, en: 'Tea Agronomy & Disease Guide', ta: 'தேயிலை வேளாண்மை மற்றும் நோய் வழிகாட்டி');

  static String teaKnowledgeSubtitle(AppLanguage lang) => t(
        lang,
        en: 'Verified field identification and cultural practices for major tea plant diseases.',
        ta: 'முக்கிய தேயிலை தாவர நோய்களுக்கான சரிபார்க்கப்பட்ட கள அடையாளம் மற்றும் மேலாண்மை நடைமுறைகள்.',
      );

  static String labelSymptoms(AppLanguage lang) =>
      t(lang, en: 'Visible Symptoms', ta: 'காணக்கூடிய அறிகுறிகள்');

  static String labelManagement(AppLanguage lang) =>
      t(lang, en: 'Cultural & Organic Management', ta: 'கள மேலாண்மை மற்றும் தீர்வு');

  static String labelRiskFactors(AppLanguage lang) =>
      t(lang, en: 'Favorable Conditions', ta: 'நோய் பரவும் சூழல்');

  // History Screen
  static String historyTitle(AppLanguage lang) =>
      t(lang, en: 'Inspection History', ta: 'ஆய்வு வரலாறு');

  static String historySubtitle(AppLanguage lang) => t(
        lang,
        en: 'Logged field captures and screening status records.',
        ta: 'பதிவு செய்யப்பட்ட தோட்ட படங்கள் மற்றும் ஆய்வு நிலை பதிவுகள்.',
      );

  static String historyNotice(AppLanguage lang) => t(
        lang,
        en: 'Local log storage is active. Automatic cloud synchronization will be integrated in Milestone 2 with the Python backend.',
        ta: 'உள்ளூர் பதிவு சேமிப்பு இயங்குகிறது. பைதான் பின்தளத்துடன் தானியங்கி கிளவுட் ஒத்திசைவு மைல்ஸ்டோன் 2 இல் இணைக்கப்படும்.',
      );

  static String statusPendingModel(AppLanguage lang) =>
      t(lang, en: 'Pending Model Integration (M3)', ta: 'மாதிரி இணைப்பு நிலுவை (M3)');

  static String btnClearHistory(AppLanguage lang) =>
      t(lang, en: 'Clear History', ta: 'வரலாற்றை அழி');

  // Settings Screen
  static String settingsTitle(AppLanguage lang) =>
      t(lang, en: 'Application Settings', ta: 'செயலி அமைப்புகள்');

  static String sectionLanguage(AppLanguage lang) =>
      t(lang, en: 'Language & Region', ta: 'மொழி மற்றும் பிராந்தியம்');

  static String languageSelection(AppLanguage lang) =>
      t(lang, en: 'Select Display Language', ta: 'காட்சி மொழியைத் தேர்ந்தெடுக்கவும்');

  static String sectionRoadmap(AppLanguage lang) =>
      t(lang, en: 'Project Incremental Roadmap', ta: 'திட்டத்தின் கட்டமைப்பு வரைபடம்');

  static String sectionTheme(AppLanguage lang) =>
      t(lang, en: 'Farmer UI Palette', ta: 'விவசாயி வண்ணத் திட்டம்');

  static String sectionAbout(AppLanguage lang) =>
      t(lang, en: 'About SmartTea AIoT', ta: 'ஸ்மார்ட் டீ AIoT பற்றி');

  static String aboutDescription(AppLanguage lang) => t(
        lang,
        en: 'SmartTea AIoT is an AIoT-driven tea farming decision-support system built for smallholder tea growers in South Asia. Milestone 1 establishes a rock-solid, bilingual, responsive Flutter foundation without deceptive mock AI results.',
        ta: 'ஸ்மார்ட் டீ AIoT என்பது தெற்காசிய சிறு தேயிலை விவசாயிகளுக்காக உருவாக்கப்பட்ட ஒரு AIoT ஆதரவு அமைப்பாகும். மைல்ஸ்டோன் 1 ஏமாற்றும் போலி AI முடிவுகள் இல்லாமல் உறுதியான, இருமொழி, பதிலளிக்கக்கூடிய Flutter அடித்தளத்தை நிறுவுகிறது.',
      );

  static String strictAiPolicy(AppLanguage lang) => t(
        lang,
        en: 'Integrity Policy: AI inferences remain disabled until a real trained computer vision model is integrated.',
        ta: 'நேர்மை கொள்கை: உண்மையான பயிற்சி பெற்ற கணினி பார்வை மாதிரி இணைக்கப்படும் வரை AI கணிப்புகள் முடக்கப்பட்டுள்ளன.',
      );
}
