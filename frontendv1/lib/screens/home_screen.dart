import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/balance_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/quick_log_bar.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/weekly_summary_card.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().refresh();
    });
  }

  Future<void> _delete(Transaction txn) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<TransactionProvider>().removeTransaction(txn.id);
      messenger.showSnackBar(
        SnackBar(content: Text('Deleted "${txn.name}"')),
      );
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not delete transaction')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final txnProvider = context.watch<TransactionProvider>();
    final user = auth.user;
    if (user == null) {
      // Auth was just cleared; AuthGate is about to swap us out.
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nexus Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<TransactionProvider>().refresh(),
        color: AppColors.deepSea,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    BalanceCard(
                      nickname: user.nickname,
                      balance: user.currentBalance,
                    ),
                    const SizedBox(height: 12),
                    WeeklySummaryCard(summary: txnProvider.weekly),
                  ],
                ),
              ),
            ),
            if (txnProvider.loading && txnProvider.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (txnProvider.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No expenses logged yet',
                  subtitle:
                      'Type something like "Coffee 5" below to start tracking.',
                ),
              )
            else
              SliverList.builder(
                itemCount: txnProvider.groups.length,
                itemBuilder: (context, groupIndex) {
                  final group = txnProvider.groups[groupIndex];
                  return _GroupSection(group: group, onDelete: _delete);
                },
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
      bottomNavigationBar: const QuickLogBar(),
    );
  }
}

class _GroupSection extends StatelessWidget {
  final TransactionGroup group;
  final Future<void> Function(Transaction) onDelete;

  const _GroupSection({required this.group, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
            child: Text(
              group.label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < group.transactions.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                  Slidable(
                    key: ValueKey(group.transactions[i].id),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 0.28,
                      children: [
                        SlidableAction(
                          onPressed: (_) => onDelete(group.transactions[i]),
                          backgroundColor: AppColors.expense,
                          foregroundColor: Colors.white,
                          icon: Icons.delete_outline_rounded,
                          label: 'Delete',
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ],
                    ),
                    child: TransactionTile(
                      transaction: group.transactions[i],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
