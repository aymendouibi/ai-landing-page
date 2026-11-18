import 'package:get/get.dart';
import 'languages/ar_sa.dart';
import 'languages/de_de.dart';
import 'languages/en_us.dart';
import 'languages/es_es.dart';
import 'languages/fr_fr.dart';
import 'languages/ja_jp.dart';
import 'languages/pt_br.dart';
import 'languages/zh_cn.dart';

export 'languages/ar_sa.dart';
export 'languages/de_de.dart';
export 'languages/en_us.dart';
export 'languages/es_es.dart';
export 'languages/fr_fr.dart';
export 'languages/ja_jp.dart';
export 'languages/pt_br.dart';
export 'languages/zh_cn.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUS,
    'es_ES': esES,
    'fr_FR': frFR,
    'de_DE': deDE,
    'ar_SA': arSA,
    'zh_CN': zhCN,
    'ja_JP': jaJP,
    'pt_BR': ptBR,
  };
}
