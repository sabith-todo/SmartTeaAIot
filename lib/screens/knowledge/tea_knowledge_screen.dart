import 'package:flutter/material.dart';
import '../../core/localization/app_language.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';

class TeaDiseaseItem {
  final String id;
  final String enName;
  final String taName;
  final String scientificName;
  final String enCategory;
  final String taCategory;
  final String enSymptoms;
  final String taSymptoms;
  final String enManagement;
  final String taManagement;
  final String enRiskFactors;
  final String taRiskFactors;
  final bool isHealthy;

  const TeaDiseaseItem({
    required this.id,
    required this.enName,
    required this.taName,
    required this.scientificName,
    required this.enCategory,
    required this.taCategory,
    required this.enSymptoms,
    required this.taSymptoms,
    required this.enManagement,
    required this.taManagement,
    required this.enRiskFactors,
    required this.taRiskFactors,
    this.isHealthy = false,
  });
}

class TeaKnowledgeScreen extends StatefulWidget {
  const TeaKnowledgeScreen({super.key});

  @override
  State<TeaKnowledgeScreen> createState() => _TeaKnowledgeScreenState();
}

class _TeaKnowledgeScreenState extends State<TeaKnowledgeScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  static const List<TeaDiseaseItem> _diseases = [
    TeaDiseaseItem(
      id: 'blister_blight',
      enName: 'Blister Blight',
      taName: 'கொப்புள நோய் (பிளிஸ்டர் பிளைட்)',
      scientificName: 'Exobasidium vexans',
      enCategory: 'Fungal',
      taCategory: 'பூஞ்சை நோய்',
      enSymptoms:
          'Pale yellow translucent circular spots on tender young leaves. Underside turns into white velvet powdery blisters that rupture, leading to shoot dieback.',
      taSymptoms:
          'இளம் தளிர் இலைகளில் வெளிறிய மஞ்சள் நிற வட்ட புள்ளிகள் தோன்றும். இலையின் கீழ் பகுதியில் வெள்ளை நிற வெல்வெட் போன்ற கொப்புளங்கள் உருவாகி வெடித்து தளிர் அழுகும்.',
      enManagement:
          'Regulate shade tree canopy to increase sunlight. Maintain strict 7-day plucking rounds. Apply copper oxychloride before the onset of monsoon mists.',
      taManagement:
          'சூரிய ஒளி படும்படி நிழல் மரங்களை ஒழுங்குபடுத்தவும். 7 நாட்கள் இடைவெளியில் சீரான கொழுந்து பறிப்பை தொடரவும். மழைக்கால பனிக்கு முன் காப்பர் ஆக்சிகுளோரைடு தெளிக்கவும்.',
      enRiskFactors:
          'Continuous morning fog, relative humidity >85%, temperatures between 15-22°C, and deeply shaded valleys.',
      taRiskFactors:
          'தொடர்ச்சியான காலை பனிமூட்டம், 85% க்கும் அதிகமான காற்றின் ஈரப்பதம், 15-22°C வெப்பநிலை மற்றும் அடர்ந்த நிழல் பகுதிகள்.',
    ),
    TeaDiseaseItem(
      id: 'grey_blight',
      enName: 'Grey Blight',
      taName: 'சாம்பல் கருகல் நோய்',
      scientificName: 'Pestalotiopsis theae',
      enCategory: 'Fungal',
      taCategory: 'பூஞ்சை நோய்',
      enSymptoms:
          'Concentric grey-brown irregular patches expanding from leaf margins or mechanical injury sites, dotted with minute black fruiting bodies (acervuli).',
      taSymptoms:
          'இலைகளின் ஓரங்கள் அல்லது காயமடைந்த இடங்களில் சாம்பல்-பழுப்பு நிற வளைய வடிவ புள்ளிகள் தோன்றி விரிவடையும். அதில் நுண்ணிய கருப்பு புள்ளிகள் காணப்படும்.',
      enManagement:
          'Prevent physical damage to bushes during plucking and weeding. Prune affected branches and maintain adequate potash (K2O) fertilization.',
      taManagement:
          'கொழுந்து பறிக்கும் போது தேயிலை செடிகளுக்கு காயம் ஏற்படுவதை தவிர்க்கவும். காய்ந்த கிளைகளை நீக்கி போதிய பொட்டாஷ் உரமிடுதலை பராமரிக்கவும்.',
      enRiskFactors:
          'Sun scorch wounds, shearing injuries, weakened bushes, and heavy rainfall followed by warm sunny spells.',
      taRiskFactors:
          'சூரிய வெப்ப காயம், கத்தரிக்கும் போது ஏற்படும் காயங்கள், ஊட்டச்சத்து குறைந்த செடிகள் மற்றும் கனமழைக்கு பின் வரும் வெயில்.',
    ),
    TeaDiseaseItem(
      id: 'brown_blight',
      enName: 'Brown Blight',
      taName: 'பழுப்பு கருகல் நோய்',
      scientificName: 'Colletotrichum camelliae',
      enCategory: 'Fungal',
      taCategory: 'பூஞ்சை நோய்',
      enSymptoms:
          'Dark reddish-brown spots with yellowish halo on mature maintenance foliage. Lesions coalesce into broad scorched foliar patches.',
      taSymptoms:
          'முதிர்ந்த இலைகளில் மஞ்சள் வளையத்துடன் கூடிய அடர் சிவப்பு-பழுப்பு நிற புள்ளிகள் தோன்றும். பின்னர் புள்ளிகள் இணைந்து பெரிய கருகிய பகுதியாக மாறும்.',
      enManagement:
          'Improve soil drainage in waterlogged field blocks. Collect and compost fallen leaf debris. Maintain balanced N:K nutrition.',
      taManagement:
          'நீர் தேங்கும் தோட்ட பகுதிகளில் வடிகால் வசதியை மேம்படுத்தவும். கீழே விழுந்த இலைகளை அகற்றி உரம் தயாரிக்கவும். சமச்சீர் உர மேலாண்மை செய்யவும்.',
      enRiskFactors:
          'Poor soil aeration, root waterlogging, and delayed maintenance pruning.',
      taRiskFactors:
          'மண்ணில் காற்று புகாமை, வேர்களில் நீர் தேக்கம் மற்றும் தாமதமான கவாத்து செய்தல்.',
    ),
    TeaDiseaseItem(
      id: 'red_spider_mite',
      enName: 'Red Spider Mite',
      taName: 'சிவப்பு சிலந்தி பூச்சி',
      scientificName: 'Oligonychus coffeae',
      enCategory: 'Pest / Mite',
      taCategory: 'பூச்சி / உண்ணி',
      enSymptoms:
          'Upper surface of mature leaves turns rusty bronze or copper colored. Heavy infestations show fine webbing and severe leaf desiccation.',
      taSymptoms:
          'முதிர்ந்த இலைகளின் மேல் பரப்பு துருப்பிடித்த செப்பு நிறமாக மாறும். அதிக தாக்குதலின் போது மெல்லிய சிலந்தி வலைகள் மற்றும் இலை உதிர்தல் ஏற்படும்.',
      enManagement:
          'Wash road-side dusty foliage. Encourage natural phytoseiid predatory mites. Apply neem seed kernel extract (NSKE) during dry spells.',
      taManagement:
          'சாலை ஓரங்களில் புழுதி படிந்த இலைகளை தண்ணீரில் கழுவவும். இயற்கை இரைவிழுங்கி சிலந்திகளை பாதுகாக்கவும். வறண்ட காலங்களில் வேப்பெண்ணெய் கரைசல் தெளிக்கவும்.',
      enRiskFactors:
          'Extended dry warm periods, dusty field borders, and high sun exposure.',
      taRiskFactors:
          'நீண்ட வறண்ட வெயில் காலம், தூசி நிறைந்த பாதை ஓரங்கள் மற்றும் அதிக வெப்ப நிலை.',
    ),
    TeaDiseaseItem(
      id: 'black_rot',
      enName: 'Black Rot',
      taName: 'கரும் அழுகல் நோய்',
      scientificName: 'Corticium invisum',
      enCategory: 'Fungal',
      taCategory: 'பூஞ்சை நோய்',
      enSymptoms:
          'Young leaves turn dark brown-black and remain suspended from twigs by delicate white mycelial fungal cords without dropping immediately.',
      taSymptoms:
          'இளம் இலைகள் அடர் பழுப்பு-கருப்பு நிறமாக மாறி, உதிராமல் மெல்லிய வெள்ளை பூஞ்சை இழைகளால் கிளைகளிலேயே தொங்கிக்கொண்டிருக்கும்.',
      enManagement:
          'Center cleaning and frame sanitation during pruning. Ensure good air circulation through dense bushes. Apply copper sprays post-skiffing.',
      taManagement:
          'கவாத்து செய்யும் போது செடியின் மையப்பகுதியை சுத்தம் செய்து சுகாதாரத்தை பேணவும். காற்று சுழற்சியை அதிகரிக்கவும். கவாத்துக்கு பின் காப்பர் தெளிக்கவும்.',
      enRiskFactors:
          'Overgrown dense bushes, continuous humid mist, and poor canopy ventilation.',
      taRiskFactors:
          'அடர்த்தியாக வளர்ந்த தேயிலை செடிகள், தொடர் பனிமூட்டம் மற்றும் போதிய காற்று சுழற்சி இன்மை.',
    ),
    TeaDiseaseItem(
      id: 'healthy_tea',
      enName: 'Healthy Tea Shoot',
      taName: 'ஆரோக்கியமான தேயிலை தளிர்',
      scientificName: 'Camellia sinensis',
      enCategory: 'Healthy',
      taCategory: 'ஆரோக்கியமானது',
      enSymptoms:
          'Bright, succulent emerald green "two leaves and a bud" flush. Firm leaf texture, clean margins, and no visible necrotic lesions or mites.',
      taSymptoms:
          'பளபளப்பான மரகத பச்சை நிறத்தில் "இரண்டு இலைகள் மற்றும் ஒரு மொட்டு" கொழுந்து. உறுதியான அமைப்பு, தூய்மையான விளிம்புகள் மற்றும் புள்ளிகள் இல்லாமை.',
      enManagement:
          'Pluck precisely at 7-10 day intervals. Maintain soil organic mulch, compost tea waste, and monitor flush vigor weekly.',
      taManagement:
          '7-10 நாட்கள் இடைவெளியில் சரியான முறையில் கொழுந்து பறிக்கவும். மண்ணில் இயற்கை மூடாக்கு போடவும், வாராந்திர தளிர் வளர்ச்சியை கண்காணிக்கவும்.',
      enRiskFactors:
          'Optimal conditions: High altitude, diffused morning light, well-aerated acidic soil (pH 4.5-5.5).',
      taRiskFactors:
          'சாதகமான சூழல்: மலைப்பகுதி, காலை மிதமான வெயில், நல்ல காற்றோட்டமுள்ள அமிலத்தன்மை கொண்ட மண் (pH 4.5-5.5).',
      isHealthy: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final langCtrl = LanguageProvider.of(context);
    final lang = langCtrl.currentLanguage;

    final filtered = _diseases.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.enName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.taName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.scientificName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null ||
          item.enCategory == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.teaKnowledgeTitle(lang),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.forestGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.teaKnowledgeSubtitle(lang),
            style: const TextStyle(
              fontSize: 13.5,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 18),

          // Search Field
          TextField(
            key: const Key('tea_knowledge_search_input'),
            decoration: InputDecoration(
              hintText: lang == AppLanguage.ta
                  ? 'நோயின் பெயர் கொண்டு தேடுக...'
                  : 'Search diseases or pests...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.forestGreen),
              filled: true,
              fillColor: AppTheme.creamLight,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.creamDark),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.creamDark),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.forestGreen, width: 1.5),
              ),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),

          const SizedBox(height: 16),

          // Disease Cards List
          ...filtered.map((item) => _buildDiseaseCard(context, item, lang)),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDiseaseCard(
    BuildContext context,
    TeaDiseaseItem item,
    AppLanguage lang,
  ) {
    final title = lang == AppLanguage.ta ? item.taName : item.enName;
    final category = lang == AppLanguage.ta ? item.taCategory : item.enCategory;
    final symptoms = lang == AppLanguage.ta ? item.taSymptoms : item.enSymptoms;
    final management = lang == AppLanguage.ta ? item.taManagement : item.enManagement;
    final risk = lang == AppLanguage.ta ? item.taRiskFactors : item.enRiskFactors;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        key: Key('disease_tile_${item.id}'),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: item.isHealthy
                ? AppTheme.leafGreen.withValues(alpha: 0.3)
                : AppTheme.warningAmber.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            item.isHealthy ? Icons.eco : Icons.coronavirus_outlined,
            color: item.isHealthy ? AppTheme.forestGreen : AppTheme.warningAmber,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            color: AppTheme.forestGreen,
          ),
        ),
        subtitle: Text(
          '${item.scientificName} • $category',
          style: const TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: AppTheme.textMuted,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.visibility_outlined,
            label: AppStrings.labelSymptoms(lang),
            content: symptoms,
            accentColor: AppTheme.forestGreen,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.health_and_safety_outlined,
            label: AppStrings.labelManagement(lang),
            content: management,
            accentColor: AppTheme.leafGreenDark,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.cloud_outlined,
            label: AppStrings.labelRiskFactors(lang),
            content: risk,
            accentColor: AppTheme.warningAmber,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String content,
    required Color accentColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: accentColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 22.0),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
