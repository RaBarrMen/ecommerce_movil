import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/order_model.dart';
import '../../../providers/order_provider.dart';

class OrdersHistoryWidget extends StatelessWidget {
  const OrdersHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (_, provider, __) {
        if (provider.status == OrderStatus2.loading) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (provider.orders.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 56, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text(
                    'Aún no tienes pedidos',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          children: provider.orders
              .map((order) => _OrderTile(order: order))
              .toList(),
        );
      },
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});
  final OrderModel order;

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.paid:
        return AppColors.success;
      case OrderStatus.shipped:
        return AppColors.info;
      case OrderStatus.delivered:
        return AppColors.accent;
      case OrderStatus.cancelled:
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.paid:
        return 'Pagado';
      case OrderStatus.shipped:
        return 'Enviado';
      case OrderStatus.delivered:
        return 'Entregado';
      case OrderStatus.cancelled:
        return 'Cancelado';
      default:
        return 'Pendiente';
    }
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.receipt_outlined, color: color, size: 20),
        ),
        title: Text(
          '#${order.id.substring(0, 8).toUpperCase()}',
          style: theme.textTheme.bodyLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _formatDate(order.createdAt),
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
        trailing: Chip(
          label: Text(
            _statusLabel(order.status),
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          backgroundColor: color.withOpacity(0.1),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          visualDensity: VisualDensity.compact,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(item.productName,
                              style: theme.textTheme.bodyMedium),
                        ),
                        Text('x${item.quantity}',
                            style: theme.textTheme.bodyMedium),
                        const SizedBox(width: 12),
                        Text(
                          '\$${item.subtotal.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                      '\$${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
