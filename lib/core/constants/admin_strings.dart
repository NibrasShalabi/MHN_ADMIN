/// All dashboard text — single source of truth, same rule as the app.
class AdminStrings {
  AdminStrings._();

  static const String appName = 'MHN Shopping — لوحة التحكم';
  static const String brandShort = 'MHN';
  static const String sectionNotReady = 'هذا القسم قيد الإنشاء';

  // ==================== عام ====================
  static const String save = 'حفظ';
  static const String cancel = 'إلغاء';
  static const String delete = 'حذف';
  static const String edit = 'تعديل';
  static const String add = 'إضافة';
  static const String search = 'بحث';
  static const String none = 'بدون';
  static const String selectAll = 'تحديد الكل';
  static const String clearAll = 'إلغاء الكل';
  static const String confirm = 'تأكيد';
  static const String loading = 'جاري التحميل...';
  static const String noData = 'لا توجد بيانات';
  static const String somethingWentWrong = 'حدث خطأ، حاول لاحقاً';
  static const String requiredField = 'هذا الحقل مطلوب';
  static const String saved = 'تم الحفظ';
  static const String deleted = 'تم الحذف';
  static const String deleteConfirm = 'هل أنت متأكد من الحذف؟ لا يمكن التراجع.';

  // ==================== التنقّل ====================
  static const String navDashboard = 'الرئيسية';
  static const String navProducts = 'المنتجات';
  static const String navCategories = 'الأقسام والفلاتر';
  static const String navOrders = 'الطلبات';
  static const String navSuggestions = 'اقتراحات المنتجات';
  static const String navSupport = 'الدعم';
  static const String navFitness = 'قسم الرياضة';
  static const String navLoyalty = 'متجر الولاء';
  static const String navPresets = 'القوالب';
  static const String navContent = 'محتوى من نحن';
  static const String navAnalytics = 'الإحصائيات';

  // ==================== المنتجات ====================
  static const String products = 'المنتجات';
  static const String addProduct = 'إضافة منتج';
  static const String editProduct = 'تعديل منتج';
  static const String productName = 'اسم المنتج';
  static const String productCategory = 'القسم';
  static const String productFilter = 'الفلتر';
  static const String productPrice = 'السعر';
  static const String productStock = 'المخزون';
  static const String productDescription = 'الوصف';
  static const String productIngredients = 'المكوّنات';
  static const String productBenefits = 'الفوائد';
  static const String productUsage = 'طريقة الاستخدام';
  static const String productImages = 'الصور';
  static const String productIsNew = 'وضع علامة "جديد"';
  static const String productOrderable = 'قابل للطلب';
  static const String productOrderableHint =
      'أزل التحديد للمستحضرات التي يصفها المختص — يظهر سعرها دون زر شراء';
  static const String basicInfo = 'المعلومات الأساسية';
  static const String pricingAndStock = 'السعر والمخزون';
  static const String details = 'التفاصيل';
  static const String searchProducts = 'ابحث باسم المنتج';
  static const String noProducts = 'لا توجد منتجات';
  static const String allCategories = 'كل الأقسام';

  // ==================== المقاسات والألوان ====================
  static const String variants = 'المقاسات والألوان';
  static const String sizeSet = 'مجموعة المقاسات';
  static const String sizeSetHint = 'اتركها فارغة للمنتجات بلا مقاسات';
  static const String availableSizes = 'المقاسات المتوفرة';
  static const String availableSizesHint = 'أزل ما هو غير متوفر من هذه القطعة';
  static const String availableColors = 'الألوان المتوفرة';
  static const String availableColorsHint = 'من لوحة الألوان المعتمدة';
  static const String sizeGuide = 'دليل المقاسات';
  static const String sizeGuideHint =
      'جدول محفوظ يظهر للعميل عند الضغط على أيقونة الدليل';
  static const String sizeColumn = 'المقاس';

  // ==================== الأقسام ====================
  static const String categories = 'الأقسام';
  static const String addCategory = 'إضافة قسم';
  static const String editCategory = 'تعديل قسم';
  static const String categoryName = 'اسم القسم';
  static const String categoryScope = 'مكان الظهور';
  static const String scopeStore = 'المتجر';
  static const String scopeFitness = 'قسم الرياضة';
  static const String scopeLoyalty = 'متجر الولاء';
  static const String filters = 'الفلاتر';
  static const String addFilter = 'إضافة فلتر';
  static const String filterName = 'اسم الفلتر';
  static const String productsCount = 'عدد المنتجات';

  // ==================== الطلبات ====================
  static const String orders = 'الطلبات';
  static const String orderNumber = 'رقم الطلب';
  static const String customer = 'العميل';
  static const String orderDate = 'التاريخ';
  static const String orderTotal = 'الإجمالي';
  static const String orderStatus = 'الحالة';
  static const String orderItems = 'المنتجات';
  static const String changeStatus = 'تغيير الحالة';
  static const String expectedDelivery = 'وقت التسليم المتوقع';
  static const String statusNote = 'سبب التأخير / الإلغاء';
  static const String messageCustomer = 'إرسال رسالة للعميل';
  static const String statusPending = 'قيد الانتظار';
  static const String statusConfirmed = 'تم التأكيد';
  static const String statusPreparing = 'قيد التحضير';
  static const String statusOutForDelivery = 'في الطريق';
  static const String statusDelivered = 'تم التسليم';
  static const String statusDelayed = 'مؤجّل';
  static const String statusCancelled = 'ملغى';

  // ==================== الاقتراحات ====================
  static const String suggestions = 'اقتراحات المنتجات';
  static const String suggestedBy = 'المقترِح';
  static const String suggestionLink = 'الرابط';
  static const String openLink = 'فتح الرابط';
  static const String openLinkWarning =
      'سيُفتح رابط أرسله مستخدم. تأكد من الموقع قبل المتابعة:';
  static const String approve = 'موافقة';
  static const String reject = 'رفض';
  static const String statusUnderReview = 'قيد المراجعة';
  static const String statusApproved = 'مقبول';
  static const String statusRejected = 'مرفوض';

  // ==================== الدعم ====================
  static const String support = 'الدعم';
  static const String supportTopic = 'النوع';
  static const String supportBody = 'الرسالة';
  static const String topicComplaint = 'شكوى';
  static const String topicSuggestion = 'اقتراح';
  static const String topicBug = 'مشكلة تقنية';
  static const String topicOther = 'أخرى';
  static const String markResolved = 'تعليم كمعالَج';
  static const String resolved = 'معالَج';
  static const String open = 'مفتوح';

  // ==================== القوالب ====================
  static const String presets = 'القوالب';
  static const String presetsIntro =
      'عرّف المقاسات والألوان وأدلة المقاسات مرة واحدة، ثم اخترها عند إضافة أي منتج.';
  static const String sizeSets = 'مجموعات المقاسات';
  static const String colorPalette = 'لوحة الألوان';
  static const String sizeGuides = 'أدلة المقاسات';
  static const String addSizeSet = 'إضافة مجموعة';
  static const String addColor = 'إضافة لون';
  static const String addSizeGuide = 'إضافة دليل';
  static const String presetName = 'الاسم';
  static const String sizesCommaSeparated = 'المقاسات (افصل بينها بفاصلة)';
  static const String colorName = 'اسم اللون';
  static const String colorHex = 'قيمة اللون (HEX)';

  // ==================== قسم الرياضة ====================
  static const String fitnessPrograms = 'البرامج';
  static const String programFields = 'حقول الفورم';
  static const String addField = 'إضافة حقل';
  static const String fieldLabel = 'اسم الحقل';
  static const String fieldType = 'نوع الحقل';
  static const String fieldRequired = 'إجباري';
  static const String fieldOptions = 'الخيارات (افصل بينها بفاصلة)';
  static const String typeText = 'نص';
  static const String typeMultiline = 'نص طويل';
  static const String typeNumber = 'رقم';
  static const String typeDropdown = 'قائمة';
  static const String typeBoolean = 'نعم / لا';
  static const String typeMultiChoice = 'اختيار متعدد';
  static const String coachWhatsapp = 'واتساب المختص';
  static const String submissions = 'البيانات الواصلة';
  static const String healthDataRestricted =
      'بيانات صحية — الوصول مقصور على المختص المشرف.';

  // ==================== محتوى من نحن ====================
  static const String aboutContent = 'محتوى من نحن';
  static const String aboutMission = 'رسالتنا';
  static const String aboutGoals = 'أهدافنا';
  static const String aboutSource = 'مصدر بضائعنا';


  // ==================== الإحصائيات ====================
  static const String analytics = 'الإحصائيات';
  static const String totalOrders = 'إجمالي الطلبات';
  static const String completedOrders = 'الطلبات المكتملة';
  static const String cancelledOrders = 'الطلبات الملغاة';
  static const String totalUsers = 'المستخدمون';
  static const String topCategories = 'الأقسام الأكثر زيارة';
  static const String topProducts = 'المنتجات الأكثر طلباً';


// ===========================
  static const String ordersPendingTab = 'قيد الانتظار';
  static const String ordersOngoingTab = 'الطلبات الجارية';
  static const String sortBy = 'الترتيب';
  static const String sortNewestFirst = 'الأحدث أولاً';
  static const String sortOldestFirst = 'الأقدم أولاً';

  //==========================
  static const String customerPhone = 'رقم الزبون';
  static const String address = 'العنوان';
  static const String payment = 'الدفع';
  static const String paymentCash = 'عند الاستلام';
  static const String paymentBank = 'تحويل بنكي';
  static const String paymentNotSet = 'لم يُحدد بعد';



  static const String deliveryFee = 'التوصيل';

  static const String addImages = 'إضافة صور';
  static const String noImages = 'لا توجد صور';

  static const String copyLink = 'نسخ الرابط';
  static const String linkCopied = 'تم نسخ الرابط';
  static const String approveMessage = 'تم توفير المنتج الذي اقترحته';
  static const String rejectReason = 'سبب الرفض';



  static const String sentBy = 'المرسل';
  static const String supportReply = 'الرد';
  static const String sendReply = 'إرسال الرد';


  static const String basicHealthFields = 'إضافة الحقول الصحية الأساسية';
  static const String fieldsCount = 'عدد الحقول';
  static const String suggestedProgramsAfterSubmit = 'البرامج المقترحة بعد الإرسال';
  static const String programIntro = 'النبذة';
  static const String livePreview = 'معاينة حية';
  static const String submissionDate = 'التاريخ';
  static const String submissionProgram = 'البرنامج';
  static const String submissionAnswers = 'الإجابات';
  static const String openWhatsapp = 'فتح واتساب';
  static const String reorderHint = 'اسحب لإعادة الترتيب';


  static const String addProgram = 'إضافة برنامج';
  static const String editProgram = 'تعديل برنامج';
  static const String programTitle = 'اسم البرنامج';
  static const String submittedBy = 'المرسلة';
  static const String copyWhatsapp = 'نسخ رابط واتساب';
  static const String supplements = 'المستحضرات';


  static const String addColumn = 'إضافة عمود';
  static const String columnName = 'اسم العمود';
  static const String usedByProducts = 'مستخدم بـ';
  static const String productsWord = 'منتج';
  static const String cannotDeletePreset = 'لا يمكن الحذف — هذا القالب مستخدم بمنتجات حالياً.';
  static const String rows = 'الصفوف';
  static const String addRow = 'إضافة صف';
  static const String colorPreview = 'معاينة';


  static const String editSizeSet = 'تعديل مجموعة المقاسات';
  static const String editColor = 'تعديل اللون';
  static const String editSizeGuide = 'تعديل دليل المقاسات';
  static const String columnsHeader = 'الأعمدة';




// الولاء
  static const String loyaltyGifts = 'هدايا الولاء';
  static const String loyaltyRules = 'قواعد الاحتساب';
  static const String pointsLedger = 'سجل النقاط';
  static const String pointsPerPurchase = 'نقاط لكل عملية شراء';
  static const String purchasePointsType = 'طريقة الاحتساب';
  static const String pointsFixed = 'رقم ثابت';
  static const String pointsPercentage = 'نسبة من قيمة الطلب';
  static const String appRatingPoints = 'نقاط تقييم التطبيق';
  static const String suggestionPoints = 'نقاط اقتراح منتج مقبول';
  static const String pointsExpiry = 'صلاحية النقاط';
  static const String expiryMonths = 'عدد الأشهر';
  static const String noExpiry = 'بدون انتهاء';
  static const String minRedemption = 'حد أدنى للاستبدال';
  static const String ruleEnabled = 'مفعّلة';
  static const String searchByUser = 'ابحث باسم المستخدم';
  static const String pointsBalance = 'الرصيد';
  static const String addCorrection = 'إضافة تصحيح';
  static const String correctionReason = 'سبب التصحيح';
  static const String correctionPoints = 'عدد النقاط (سالب للخصم)';
  static const String pointsWord = 'نقطة';
  static const String transactionReason = 'السبب';
  static const String transactionDate = 'التاريخ';
  static const String costInPoints = 'التكلفة بالنقاط';


  static const String aboutHeroTitle = 'العنوان الرئيسي';
  static const String aboutHeroSubtitle = 'السطر التعريفي';
  static const String aboutGoalsIntro = 'الأهداف';
  static const String addGoal = 'إضافة هدف';
  static const String goalTitle = 'عنوان الهدف';
  static const String goalDescription = 'وصف الهدف';
  static const String goalIcon = 'الأيقونة';
  static const String contactText = 'نص التواصل';



  static const String periodToday = 'اليوم';
  static const String period7Days = '7 أيام';
  static const String period30Days = '30 يوم';
  static const String periodCustom = 'مخصص';
  static const String revenue = 'الإيراد';
  static const String ordersOverTime = 'الطلبات عبر الزمن';
  static const String orderStatusDistribution = 'توزيع حالات الطلبات';
  static const String viewsWord = 'مشاهدة';


  static const String needsAttention = 'يحتاج انتباهك';
  static const String pendingOrdersCard = 'طلبات قيد الانتظار';
  static const String unreviewedSuggestions = 'اقتراحات غير مراجَعة';
  static const String openSupportMessages = 'رسائل دعم مفتوحة';
  static const String outOfStockProducts = 'منتجات نفد مخزونها';
  static const String fitnessSubmissionsCard = 'بيانات فيتنس واصلة';
  static const String todayOrders = 'طلبات اليوم';
  static const String todayRevenue = 'إيراد اليوم';
  static const String approxUsers = 'المستخدمون (تقريبي)';
  static const String recentOrders = 'آخر الطلبات';
  static const String quickActions = 'اختصارات';
  static const String viewAll = 'عرض الكل';















}


