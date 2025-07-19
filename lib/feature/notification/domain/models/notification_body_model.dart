enum NotificationType{
  message,
  order,
  general,
  // ignore: constant_identifier_names
  order_request,
  block,
  unblock,
  // ignore: constant_identifier_names
  cash_collect,
  unassign,
  assign,
}

class NotificationBodyModel {
  NotificationType? notificationType;
  int? orderId;
  int? customerId;
  int? vendorId;
  String? type;
  int? conversationId;

  NotificationBodyModel({
    this.notificationType,
    this.orderId,
    this.customerId,
    this.vendorId,
    this.type,
    this.conversationId,
  });

  NotificationBodyModel.fromJson(Map<String, dynamic> json) {
    notificationType = convertToEnum(json['order_notification']);
    orderId = json['order_id'];
    customerId = json['customer_id'];
    vendorId = json['vendor_id'];
    type = json['type'];
    conversationId = json['conversation_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_notification'] = notificationType.toString();
    data['order_id'] = orderId;
    data['customer_id'] = customerId;
    data['vendor_id'] = vendorId;
    data['type'] = type;
    data['conversation_id'] = conversationId;
    return data;
  }

  NotificationType convertToEnum(String? enumString) {
    if(enumString == NotificationType.general.toString()) {
      return NotificationType.general;
    }else if(enumString == NotificationType.order.toString()) {
      return NotificationType.order;
    }else if(enumString == NotificationType.order_request.toString()) {
      return NotificationType.order_request;
    }else if(enumString == NotificationType.message.toString()) {
      return NotificationType.message;
    }else if(enumString == NotificationType.block.toString()) {
      return NotificationType.block;
    }else if(enumString == NotificationType.unblock.toString()) {
      return NotificationType.unblock;
    }else if(enumString == NotificationType.cash_collect.toString()) {
      return NotificationType.cash_collect;
    }else if(enumString == NotificationType.unassign.toString()) {
      return NotificationType.unassign;
    }
    return NotificationType.general;
  }
}