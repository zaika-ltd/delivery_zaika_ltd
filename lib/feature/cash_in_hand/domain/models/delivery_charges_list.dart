class DeliveryChargesListModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<DeliveryCharges>? deliveryCharges;

  DeliveryChargesListModel({this.totalSize, this.limit, this.offset, this.deliveryCharges});

  DeliveryChargesListModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['transactions'] != null) {
      deliveryCharges = <DeliveryCharges>[];
      json['transactions'].forEach((v) {
        deliveryCharges!.add(DeliveryCharges.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    if (deliveryCharges != null) {
      data['transactions'] = deliveryCharges!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DeliveryCharges {
  int? sl;
  int? orderId;
  double? deliveryFeeEarned;
  String? date;
  String? time;

  DeliveryCharges({
    this.sl,
     this.orderId,
    this.deliveryFeeEarned,
    this.date,
    this.time,
  });

  DeliveryCharges.fromJson(Map<String, dynamic> json) {
    sl = json['sl'];
    orderId=json['order_id'];

    deliveryFeeEarned = json['delivery_fee_earned']?.toDouble();

    date = json['date'];

    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sl'] = sl;
    data['order_id'] = orderId;
    data['delivery_fee_earned'] = deliveryFeeEarned;
    data['date'] =date;
    data['time'] = time;
    return data;
  }
}