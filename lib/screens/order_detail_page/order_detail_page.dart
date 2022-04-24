import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:textile/constants/app_assets.dart';
import 'package:textile/models/models.dart';
import 'package:textile/screens/order_detail_page/widgets/order_row_status_dialog.dart';
import 'package:textile/screens/widgets/circular_progress_indicator.dart';
import 'package:textile/screens/widgets/gap.dart';
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.loginBackground,
            fit: BoxFit.fill,
          ),
          SafeArea(
            child: FutureBuilder<Data<OrderDetailModel>>(
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppProgressIndicator();
                }
                if (snapshot.hasData && snapshot.data!.statusCode == 200) {
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    itemBuilder: (context, index) {
                      return _card(snapshot.data!.data!.orderDesign![index]);
                    },
                    itemCount: snapshot.data!.data!.orderDesign!.length,
                  );
                } else {
                  return const Center(
                    child: Text("Data not found"),
                  );
                }
              },
              future: Services.getOrderDetail(widget.order.id!),
            ),
          ),
        ],
      ),
    );
  }

  ///
  Widget _card(OrderDesignModel orderDesign) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 7.h),
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 10.w),
          alignment: Alignment.center,
          child: Text(
            "Design No.: ${orderDesign.designCode}(${orderDesign.rowNumber})",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Gap(10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          separatorBuilder: (_, index) => SizedBox(height: 10.h),
          itemBuilder: (_, index) {
            final row = orderDesign.rows![index];
            return GestureDetector(
              onTap: () => _changeStatus(row),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                color: Colors.white,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.h),
                        child: Text(
                          row.warpColorCode!,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      _divider(),
                      _tableRow(row1: row.remarks, row2: row.remarks),
                      _divider(),
                      _tableRow(row1: row.rate, row2: row.qty.toString()),
                      if (row.items != null && row.items!.isNotEmpty)
                        for (int i = 0; i < row.items!.length; i = i + 2) ...[
                          _divider(),
                          _tableRow(
                            row1: "F${i + 1} ${row.items![i].colorRemark}",
                            row2: "F${i + 2} ${row.items![i + 1].colorRemark}",
                          ),
                        ],
                    ],
                  ),
                ),
              ),
            );
          },
          itemCount: orderDesign.rows!.length,
        ),
      ],
    );
  }

  Widget _tableRow({String? row1, String? row2}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(5.h),
              alignment: Alignment.center,
              child: Text(
                "$row1",
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5.h),
              alignment: Alignment.center,
              child: Text(
                "$row2",
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Vertical divider
  Widget _verticalDivider() {
    return const VerticalDivider(
      width: 1,
      color: Colors.black,
      thickness: 1,
    );
  }

  /// Vertical divider
  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Colors.black,
    );
  }

  /// Change status of the row
  void _changeStatus(RowModel row) async {
    final data = await showCupertinoDialog(
      context: context,
      builder: (_) => OrderRowStatusDialog(row: row),
      barrierDismissible: true,
    );
    if (data is bool) {
      setState(() {});
    }
  }
}
