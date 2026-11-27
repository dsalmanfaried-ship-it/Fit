# FitMate AI

مشروع Flutter لتسجيل التمارين، بواجهة عربية/إنجليزية وتخزين محلي ومزامنة اختيارية مع Supabase.

## النشر على GitHub Pages
1. ارفع محتويات هذا المجلد إلى جذر المستودع على الفرع `main`.
2. من Settings → Pages اختر GitHub Actions.
3. أضف Actions secrets باسم `SUPABASE_URL` و`SUPABASE_ANON_KEY` إذا أردت تفعيل تسجيل الدخول والمزامنة السحابية. استخدم مفتاح publishable/anon فقط، ولا تضع service_role.
4. راقب Actions؛ ينفذ workflow فحص Flutter والاختبارات ثم يبني `build/web` وينشره.

## تشغيل محلي
يتطلب Flutter stable وDart 3.3 أو أحدث:
```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## Supabase
نفّذ `supabase/schema.sql` في SQL Editor. سياسات RLS مفعّلة، والسياسات تُحذف وتُنشأ بأمان عند إعادة تشغيل الملف.

ملاحظة: لم يتم تنفيذ Flutter build في بيئة إعداد هذه الحزمة؛ يجب التأكد من نجاح GitHub Actions قبل اعتبار الموقع منشوراً ويعمل.
