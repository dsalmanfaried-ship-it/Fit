# FitMate AI — Flutter + GitHub Pages + Supabase

تطبيق لتسجيل مجموعات التمرين ومتابعة الأوزان والعدات وحجم التدريب، مع واجهة عربي/إنجليزي، إدخال صوتي، مؤقت راحة، وحفظ محلي. يعمل كتطبيق Android/iOS بعد توليد ملفات المنصة، وكـ Web App يمكن نشره تلقائياً على GitHub Pages.

## 1) تشغيل نسخة الويب على GitHub Pages

1. ارفع محتويات المشروع إلى مستودع GitHub، واجعل اسم الفرع `main` أو `master`.
2. من المستودع افتح **Settings → Pages → Build and deployment** واختر **GitHub Actions** كمصدر.
3. افتح **Settings → Secrets and variables → Actions** وأضف (اختياري للمزامنة السحابية):
   - `SUPABASE_URL`: رابط مشروع Supabase.
   - `SUPABASE_ANON_KEY`: مفتاح `anon/public` فقط.
4. ادفع أي commit إلى `main`؛ الـ workflow في `.github/workflows/deploy-pages.yml` سينفّذ `flutter pub get` و`flutter analyze` و`flutter test` ثم يبني وينشر الويب.
5. رابط الموقع يظهر في **Settings → Pages** بعد نجاح الـ workflow.

> لا تفتح `index.html` مباشرة من جهازك. Flutter Web يحتاج ناتج `flutter build web` وخادم HTTP. GitHub Actions يتولى البناء والنشر.

## 2) تشغيل محلياً

المتطلبات: Flutter stable وDart 3.3+.

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

لـ Android، أنشئ ملفات المنصة مرة واحدة إذا لم تكن موجودة:

```bash
flutter create --platforms=android .
flutter run
```

ولبناء APK:

```bash
flutter build apk --release
```

## 3) إعداد Supabase للمزامنة

1. أنشئ مشروعاً في Supabase.
2. من **Project Settings → API** انسخ Project URL و`anon/public` key.
3. نفّذ `supabase/schema.sql` من **SQL Editor**.
4. محلياً شغّل التطبيق بالمفاتيح:

```bash
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

5. على GitHub Pages أضف القيمتين كـ Actions Secrets كما في الخطوة الأولى، ثم أعد تشغيل الـ workflow.
6. من التطبيق أنشئ حساباً أو سجّل الدخول، وبعدها استخدم زر السحابة لرفع سجلات الجهاز.

**مهم:** لا تضع `service_role` key في التطبيق أو GitHub Pages؛ استخدم `anon/public` فقط مع سياسات RLS الموجودة في SQL.

## 4) التخزين والتوافق

- Android/iOS: قاعدة SQLite محلية.
- Web: تخزين محلي في المتصفح عبر `shared_preferences` (ويبني على Local Storage/التخزين الذي توفره المنصة). البيانات المحلية في المتصفح لا تنتقل تلقائياً بين الأجهزة أو المتصفحات؛ استخدم حساب Supabase والنسخ الاحتياطي.
- المزامنة الحالية ترفع سجلات الجهاز إلى Supabase. تنزيل السجلات السحابية ودمجها تلقائياً على جهاز جديد غير مفعّل بعد.
- التعرف الصوتي في الويب يعتمد دعم المتصفح لخدمة Web Speech؛ الأفضل تجربته على Chrome مع إذن الميكروفون وHTTPS. دعم `ar_EG` يختلف حسب المتصفح ونظام التشغيل.
- اسم الموسيقى/البودكاست ومدة الاستماع يتم إدخالهما يدوياً؛ التطبيق لا يلتقط صوت تطبيقات أخرى.

## 5) الأمان

جدول `workouts` محمي بسياسات Row Level Security في `supabase/schema.sql`. لا تعطّل RLS ولا تستخدم مفتاح `service_role` في تطبيق العميل.
