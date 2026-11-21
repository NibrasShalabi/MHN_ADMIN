# الصور (Media)

## كيف بيشتغل النظام

```
الأدمن / التطبيق ──PUT/DELETE + Firebase ID token──▶ Worker (mhn-media) ──▶ R2 bucket (mhn-images)
الكل ──GET──────────────────────────────────────────▶ baseUrl/<path>  (r2.dev أو دومين)
```

- **Firestore بيخزّن المسار بس**، متل `products/abc/1712_0.webp`، وما بيخزّن رابط كامل.
  الرابط بيتركّب وقت العرض: `MediaConfig.url(path)` = `baseUrl/path`.
- قيمة بتبلّش بـ `http` بتنعرض متل ما هي. هيك أي رابط خارجي قديم بيضل شغّال.
- كل صورة بتنرفع باسم جديد (`<وقت>_<ترتيب>.webp`)، فالكاش ما بيعرض صورة قديمة أبداً.
  وصور المنتجات معها نسخة صغيرة `_thumb.webp` للكروت.

| الملف | شو بيعمل |
|---|---|
| `media_worker/worker.js` | الرفع والحذف، والتحقق من التوكن والصلاحيات |
| `lib/core/media/media_config.dart` | `baseUrl` و`uploadUrl`، وبتنقرا من `config/media` |
| `lib/core/media/media_uploader.dart` | **القطعة الوحيدة يلي بتعرف المزوّد** |
| `lib/core/media/image_encoder.dart` | الضغط لـ WebP بالمتصفح، والمقاسات (`ImageSpec`) |
| `lib/core/media/media_service.dart` | الرفع وحذف الصور يلي ما عاد في حدا يستعملها |

| النوع | المسار | الحقل بـ Firestore |
|---|---|---|
| منتج | `products/<id>/<stamp>_<i>.webp` + `_thumb` | `products.imageUrls` (أول وحدة هي الرئيسية) |
| بانر | `banners/<id>/<stamp>_0.webp` | `banners.imageUrl` |
| لوغو مورد وغلافو | `suppliers/<id>/<stamp>_0.webp` | `suppliers.logoUrl`، `suppliers.coverUrl` |
| صورة قسم | `categories/<id>/<stamp>_0.webp` | `categories.imageUrl` |
| باركود شام كاش | `payments/sham_cash/<stamp>_0.webp` | `config/payment_addresses.sham_cash_qr` |
| إيصال دفع | `receipts/<uid>/<orderId>.jpg` | `orders.receiptUrl` |

## الإعدادات: `config/media`
```
baseUrl:   https://pub-2d134d4fdf6440c1b779696af1a07dfd.r2.dev
uploadUrl: https://mhn-media.nibras-shalabi0.workers.dev
```
إذا المستند مش موجود، بيشتغلوا القيم الافتراضية المكتوبة بـ `MediaConfig`.
لازم يكون `media` بقائمة المستندات العامة بـ `firestore.rules`:
`id in ['loyaltyRules', 'stats', 'catalog', 'media']`.

## التبديل لدومين (مثلاً `img.example.com`)
1. Cloudflare ← R2 ← `mhn-images` ← Settings ← Custom Domains ← Connect Domain.
2. غيّر `config/media.baseUrl` للدومين الجديد. **ولا شي غير هيك**: ما في تعديل كود ولا نسخة جديدة.
3. سكّر رابط r2.dev من إعدادات الـ bucket.

## التبديل لمزوّد تاني (مثلاً Firebase Storage)
1. اكتب `FirebaseMediaUploader implements MediaUploader` (فيه دالتين: `put` و`delete`)،
   وسجّلو بـ `injector.dart` بدل `WorkerMediaUploader`.
2. انسخ الملفات بنفس المسارات (rclone):
   `rclone copy r2:mhn-images gcs:<bucket>`
3. غيّر `config/media.baseUrl` لرابط القراءة العام عند المزوّد الجديد.
المسارات المخزّنة بـ Firestore ما بتتغيّر.

## نسخة احتياطية
```
rclone sync r2:mhn-images ./mhn-images-backup
```
(لـ rclone بدك R2 API token للقراءة بس، بتعملو من R2 ← Manage API tokens. **لا تحطو بالكود أبداً.**)

## الـ Worker
- الكود موجود بـ `media_worker/worker.js`. بعد أي تعديل عليه: Cloudflare ← Workers ← `mhn-media` ← Edit code ← الصق ← Deploy.
- المتغيرات: `PROJECT_ID` (Text)، والربط: `BUCKET` → `mhn-images` (EU).
- مين بيحقلّو يكتب: الأدمن (claim `admin`) على `products/` و`banners/` و`categories/` و`suppliers/` و`payments/`.
  والزبون على `receipts/<uid>/` تبعو بس، مرة وحدة، وبحد أقصى 3MB.
