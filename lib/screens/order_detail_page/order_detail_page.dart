import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:textile/constants/app_assets.dart';
import 'package:textile/models/models.dart';
import 'package:textile/models/order_model.dart';
import 'package:textile/utils/services/rest_api.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({Key? key, required this.order}) : super(key: key);
  final OrderModel order;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.loginBackground),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<Data<OrderDetailModel>>(
            builder: (context, snapshot) {
              return ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                separatorBuilder: (_, index) => SizedBox(height: 10.h),
                itemBuilder: (_, index) {
                  return _card();
                },
                itemCount: 12,
              );
            },
            future: Services.getOrderDetail(widget.order.id!),
          ),
        ),
      ),
    );
  }

  ///
  Widget _card() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
    );
  }
}
