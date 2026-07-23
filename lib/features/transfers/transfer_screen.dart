import 'package:flutter/material.dart';
import '../../services/transfer_service.dart';

import 'package:cloud_functions/cloud_functions.dart';
import '../../core/design/app_spacing.dart';
import '../../core/theme/colors/app_colors.dart';
import '../../core/theme/components/app_cards.dart';
import '../../core/theme/typography/app_typography.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();

  final _payveraIdController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _loading = false;

  final _transferService = TransferService();

  @override
  void dispose() {
    _payveraIdController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Transfer'),
        content: Text(
          'Send ₦${_amountController.text} to ${_payveraIdController.text}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _loading = true;
    });

    try {
      final result = await _transferService.internalTransfer(
        receiverPayveraId: _payveraIdController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Transfer Successful'),
          content: Text('Reference:\n${result['reference']}'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      );

      if (!mounted) return;

      Navigator.pop(context);
    } on FirebaseFunctionsException catch (e) {
      debugPrint("========== FIREBASE FUNCTION ERROR ==========");
      debugPrint("Code: ${e.code}");
      debugPrint("Message: ${e.message}");
      debugPrint("Details: ${e.details}");
      debugPrint("=============================================");

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Transfer Failed'),
          content: Text('Code: ${e.code}\n\nMessage: ${e.message}'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Transfer Failed'),
          content: Text(e.toString()),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }

    // <-- ADD THIS BRACE
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Send Money')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screen,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Transfer via Payvera ID', style: AppTypography.headline),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Send money instantly to another Payvera user.',
                  style: AppTypography.subtitle,
                ),
                const SizedBox(height: AppSpacing.xxl),

                PayveraCard(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _payveraIdController,
                        decoration: const InputDecoration(
                          labelText: 'Receiver Payvera ID',
                          hintText: '@receiver',
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';

                          if (text.isEmpty) {
                            return 'Enter a Payvera ID';
                          }

                          if (!text.startsWith('@')) {
                            return 'Payvera ID must start with @';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          hintText: '500',
                        ),
                        validator: (value) {
                          final amount = double.tryParse(value?.trim() ?? '');

                          if (amount == null || amount <= 0) {
                            return 'Enter a valid amount';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                          hintText: 'Dinner, Rent, Gift...',
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading ? null : _continue,
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Continue'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
