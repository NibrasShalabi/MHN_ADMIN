import '../../../orders/domain/entities/order.dart';

/// A value a template can show. Written as `{key}` inside the text.
enum MessageVar {
  orderId('orderId', 'رقم الطلب'),
  points('points', 'النقاط'),
  reason('reason', 'السبب'),
  product('product', 'المنتج'),
  note('note', 'ملاحظة الأدمن'),
  reply('reply', 'نص الرد');

  final String key;
  final String label;
  const MessageVar(this.key, this.label);

  String get token => '{$key}';
}

/// Every moment the customer gets a message, with the default wording used
/// until the admin edits it. `type` is what the client app groups by.
enum MessageEvent {
  orderConfirmed('order_confirmed', 'order_update', 'تأكيد الطلب',
      'تم تأكيد طلبك — {orderId}', 'استلمنا دفعتك وطلبك صار مؤكد.\n{note}', [MessageVar.orderId, MessageVar.note]),
  orderPreparing('order_preparing', 'order_update', 'قيد التجهيز',
      'طلبك قيد التجهيز — {orderId}', 'عم نجهّز طلبك هلأ.\n{note}', [MessageVar.orderId, MessageVar.note]),
  orderOnTheWay('order_on_the_way', 'order_update', 'بالطريق',
      'طلبك بالطريق — {orderId}', 'طلبك طلع للتوصيل ورح يوصلك قريباً.\n{note}', [MessageVar.orderId, MessageVar.note]),
  orderDelivered('order_delivered', 'order_update', 'تم التسليم',
      'تم تسليم طلبك — {orderId}', 'شكراً لتسوّقك معنا!\nانضافلك {points} نقطة.\n{note}',
      [MessageVar.orderId, MessageVar.points, MessageVar.note]),
  orderDelayed('order_delayed', 'order_update', 'تأخير الطلب',
      'تأخير بطلبك — {orderId}', 'نعتذر، صار تأخير بطلبك.\n{note}', [MessageVar.orderId, MessageVar.note]),
  orderCancelled('order_cancelled', 'order_update', 'إلغاء الطلب',
      'تم إلغاء طلبك — {orderId}', 'تم إلغاء الطلب.\nرجعنالك {points} نقطة.\n{note}',
      [MessageVar.orderId, MessageVar.points, MessageVar.note]),
  paymentVerified('payment_verified', 'order_update', 'تأكيد الدفع',
      'تم تأكيد الدفع — {orderId}', 'استلمنا دفعتك بنجاح.', [MessageVar.orderId]),
  paymentRejected('payment_rejected', 'order_update', 'رفض الدفع',
      'تم رفض الدفع — {orderId}', '{reason}\nافتح الطلب وأعد إرسال الدفع.', [MessageVar.orderId, MessageVar.reason]),
  suggestionApproved('suggestion_approved', 'suggestion', 'قبول اقتراح',
      'تم قبول اقتراحك', 'شكراً لاقتراح "{product}".\nانضافلك {points} نقطة.', [MessageVar.product, MessageVar.points]),
  suggestionRejected('suggestion_rejected', 'suggestion', 'رفض اقتراح',
      'تم رفض اقتراحك', 'اقتراح "{product}" ما انقبل.\nالسبب: {reason}', [MessageVar.product, MessageVar.reason]),
  supportReply('support_reply', 'support_reply', 'رد الدعم الفني',
      'رد من الدعم الفني', '{reply}', [MessageVar.reply]);

  final String key;
  final String type;
  final String label;
  final String defaultTitle;
  final String defaultBody;
  final List<MessageVar> vars;

  const MessageEvent(this.key, this.type, this.label, this.defaultTitle, this.defaultBody, this.vars);

  /// A placeholder the body can't lose — without it the message says nothing.
  MessageVar? get requiredVar => this == supportReply ? MessageVar.reply : null;

  /// The message an order status sends; pending has none.
  static MessageEvent? forStatus(OrderStatus status) => switch (status) {
        OrderStatus.pending => null,
        OrderStatus.confirmed => orderConfirmed,
        OrderStatus.preparing => orderPreparing,
        OrderStatus.onTheWay => orderOnTheWay,
        OrderStatus.delivered => orderDelivered,
        OrderStatus.delayed => orderDelayed,
        OrderStatus.cancelled => orderCancelled,
      };

  static MessageEvent? forPayment(PaymentStatus status) => switch (status) {
        PaymentStatus.pending => null,
        PaymentStatus.verified => paymentVerified,
        PaymentStatus.rejected => paymentRejected,
      };
}
