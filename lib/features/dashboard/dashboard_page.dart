import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_dashboard_template/features/dashboard/inventory.dart';
import 'package:gap/gap.dart';
import 'package:intersperse/intersperse.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../../widgets/widgets.dart';

class DashBoardPage extends StatelessWidget {
  const DashBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveBreakpoints.of(context);
    const summaryCards = [
      SummaryCard(title: 'Total Sales', value: '\$125,000'),
      SummaryCard(title: 'Total Users', value: '12,000'),
      SummaryCard(title: 'KPI Progress Rate', value: '52.3%'),
    ];

    return ContentView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Dashboard',
            description: 'A summary of key data and insights on your project.',
          ),
          const Gap(16),
          if (responsive.isMobile)
            ...summaryCards
          else
            Row(
              children: summaryCards
                  .map<Widget>((card) => Expanded(child: card))
                  .intersperse(const Gap(16))
                  .toList(),
            ),
          const Gap(16),
          const Expanded(
            child: _TableView(),
          ),
        ],
      ),
    );
  }
}

class _TableView extends StatelessWidget {
  const _TableView();

  Future<List<Inventory>> fetchInventories() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.map((doc) => Inventory.fromFirestore(doc)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final decoration = TableSpanDecoration(
      border: TableSpanBorder(
        trailing: BorderSide(color: theme.dividerColor),
      ),
    );

    return FutureBuilder<List<Inventory>>(
      future: fetchInventories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        final inventories = snapshot.data!;

        return Card(
          clipBehavior: Clip.antiAlias,
          child: TableView.builder(
            columnCount: Inventory.itemCount,
            rowCount: inventories.length + 1,
            pinnedRowCount: 1,
            pinnedColumnCount: 1,
            columnBuilder: (index) {
              return TableSpan(
                foregroundDecoration: index == 0 ? decoration : null,
                extent: const FractionalTableSpanExtent(1 / 8),
              );
            },
            rowBuilder: (index) {
              return TableSpan(
                foregroundDecoration: index == 0 ? decoration : null,
                extent: const FixedTableSpanExtent(50),
              );
            },
            cellBuilder: (context, vicinity) {
              final isStickyHeader = vicinity.xIndex == 0 || vicinity.yIndex == 0;
              var label = '';
              if (vicinity.yIndex == 0) {
                switch (vicinity.xIndex) {
                  case 0:
                    label = 'Email';
                    break;
                  case 1:
                    label = 'Full Name';
                    break;
                  case 2:
                    label = 'Password';
                    break;
                  case 3:
                    label = 'Phone';
                    break;
                }
              } else {
                final inventory = inventories[vicinity.yIndex - 1];
                switch (vicinity.xIndex) {
                  case 0:
                    label = inventory.email;
                    break;
                  case 1:
                    label = inventory.fullName;
                    break;
                  case 2:
                    label = inventory.password;
                    break;
                  case 3:
                    label = inventory.phone;
                    break;
                }
              }
              return TableViewCell(
                child: ColoredBox(
                  color: isStickyHeader ? Colors.transparent : colorScheme.surface,
                  child: Center(
                    child: FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontWeight: isStickyHeader ? FontWeight.w600 : null,
                            color: isStickyHeader ? null : colorScheme.outline,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
