# FitMate AI — Flutter Android project

تطبيق لتسجيل التمارين والمجموعات والعدات والأوزان، مع إدخال صوتي عربي/إنجليزي، حفظ محلي، رسم بياني للتقدم، ومؤشرات بسيطة.

## المتطلبات
- Flutter stable حديث (Dart 3.3 أو أحدث)
- Android Studio أو VS Code مع Flutter extension
- جهاز Android أو Emulator

## تشغيل المشروع
هذا الأرشيف يحتوي على **مصدر تطبيق Flutter**. أنشئ ملفات Android الأصلية أولاً بواسطة Flutter ثم انسخ ملفات المشروع:

```bash
flutter create --platforms=android .
flutter pub get
flutter run
```

لو شغّلت `flutter create` داخل مجلد المشروع نفسه وكان سيستبدل ملفات موجودة، وافق على إنشاء ملفات المنصة فقط أو أنشئ مجلداً جديداً ثم انسخ `lib/` و`assets/` و`pubspec.yaml` و`analysis_options.yaml` إليه.

## صلاحيات الميكروفون
أضف داخل `android/app/src/main/AndroidManifest.xml` قبل وسم `<application>`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

داخل وسم `<application>` تأكد من وجود:
```xml
<queries>
    <intent>
        <action android:name="android.speech.RecognitionService"/>
    </intent>
</queries>
```

على Android 11+ قد تحتاج هذه queries حتى يكتشف التطبيق خدمة التعرف على الكلام. سيطلب التطبيق الإذن عند أول استخدام بحسب إصدار Android والمكتبة.

## المزايا الموجودة
- حفظ المجموعات محلياً باستخدام SQLite.
- إدخال اسم التمرين والعدات والوزن.
- تحويل الأرقام العربية إلى أرقام قابلة للقراءة في محلل الصوت.
- تسجيل صوتي تجريبي باستخدام `speech_to_text` (تعتمد الجودة واللغة المتاحة على خدمات الجهاز).
- حفظ اسم الموسيقى/البودكاست ومدته يدوياً، ومدة التمرين.
- رسم بياني لحجم التدريب ومؤشرات إجمالية.
- مؤقت راحة 90 ثانية.
- مكتبة تمارين أولية في `assets/exercises.json`.

## ملاحظات مهمة
- لا يسجل التطبيق صوت الموسيقى من تطبيقات أخرى ولا يتعرف تلقائياً على الأغنية؛ اسم المحتوى ومدته يُدخلان يدوياً.
- التحليلات الحالية قواعد محلية بسيطة وليست مدرباً طبياً أو نموذج AI متصلاً.
- جرّب `flutter analyze` و`flutter test` ثم `flutter build apk` على جهاز تطوير قبل النشر. لم يتم تضمين APK جاهز في هذا المصدر.
