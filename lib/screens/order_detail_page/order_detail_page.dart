import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:textile/constants/app_assets.dart';
import 'package:textile/models/models.dart';
import 'package:textile/screens/widgets/circular_progress_indicator.dart';
import 'package:textile/utils/services/rest_api.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({Key? key, required this.order}) : super(key: key);
  final OrderModel order;

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
  }

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
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppProgressIndicator();
              }
              if (snapshot.hasData && snapshot.data!.statusCode == 200) {
                return SizedBox();
                /*return ListView.separated(
                  padding:
                      EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                  separatorBuilder: (_, index) => SizedBox(height: 10.h),
                  itemBuilder: (_, index) {
                    return _card(
                        snapshot.data!.data!.orderDesign![index].rows!);
                  },
                  itemCount: snapshot.data!.data!.orderDesign!.length,
                );*/
              } else {
                return const Center(
                  child: Text("Data not found"),
                );
              }
            },
            future: Services.getOrderDetail(widget.order.id!),
          ),
        ),
      ),
    );
  }

  ///
  Widget _card(List<RowsModel> rows) {
    return ListView.builder(
      itemBuilder: (_, index) {
        return Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: SfDataGrid(
            source: OrderDataSource(row: rows[index]),
            columnWidthMode: ColumnWidthMode.fill,
            stackedHeaderRows: [
              StackedHeaderRow(
                cells: [
                  StackedHeaderCell(
                    columnNames: [
                      'column1',
                      'column2',
                    ],
                    child: Center(
                      child: Text("Warp Color.: ${rows[index].warpColor}"),
                    ),
                  )
                ],
              ),
            ],
            columns: <GridColumn>[],
          ),
        );
      },
      itemCount: rows.length,
    );
  }
}

/// An object to set the employee collection data source to the datagrid. This
/// is used to map the employee data to the datagrid widget.
class OrderDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  OrderDataSource({required RowsModel row}) {
    _orderData.add(DataGridRow(
      cells: [
        DataGridCell(columnName: 'column1', value: row.remark),
        DataGridCell(columnName: 'column2', value: row.particular),
      ],
    ));
    _orderData.add(DataGridRow(
      cells: [
        DataGridCell(columnName: 'column1', value: row.rate),
        DataGridCell(columnName: 'column2', value: row.qty),
      ],
    ));
    _orderData.addAll(row.items!.map((item) {
      return DataGridRow(
        cells: [
          DataGridCell(columnName: 'column1', value: item.colorCode),
          DataGridCell(columnName: 'column2', value: row.qty),
        ],
      );
    }).toList());
  }

  final List<DataGridRow> _orderData = [];

  @override
  List<DataGridRow> get rows => _orderData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }
}
