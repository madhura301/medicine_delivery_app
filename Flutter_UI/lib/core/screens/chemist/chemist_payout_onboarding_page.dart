import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pharmaish/core/services/chemist_payout_service.dart';
import 'package:pharmaish/core/services/medical_store_service.dart';
import 'package:pharmaish/shared/models/business_type.dart';
import 'package:pharmaish/shared/models/chemist_payout_models.dart';
import 'package:pharmaish/shared/widgets/app_snackbar.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/utils/storage.dart';

/// Phase-1 chemist onboarding surface:
///  1. Pay the one-time activation/onboarding fee (Razorpay Payment Link).
///  2. Submit bank details to create the Razorpay Route linked account (payout).
///
/// Pass [medicalStoreId] if known; otherwise it is resolved from the logged-in
/// user's email.
class ChemistPayoutOnboardingPage extends StatefulWidget {
  final String? medicalStoreId;

  const ChemistPayoutOnboardingPage({super.key, this.medicalStoreId});

  @override
  State<ChemistPayoutOnboardingPage> createState() =>
      _ChemistPayoutOnboardingPageState();
}

class _ChemistPayoutOnboardingPageState
    extends State<ChemistPayoutOnboardingPage> {
  static const Color _indigo = Color(0xFF5B4FE0);
  static const Color _green = Color(0xFF16A34A);

  final _bankFormKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _ownerPanController = TextEditingController();
  final _accountController = TextEditingController();
  final _reenterAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _holderController = TextEditingController();
  BusinessType _selectedBusinessType = BusinessType.privateLimited;

  String? _storeId;
  bool _loading = true;
  String? _error;

  ChemistActivationModel? _activation;
  ChemistPayoutStatusModel? _payout;

  bool _creatingLink = false;
  bool _submittingBank = false;
  bool _linkOpened = false;

  bool get _isActivated =>
      _activation?.isActivated == true || _payout?.activatedOn != null;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerPanController.dispose();
    _accountController.dispose();
    _reenterAccountController.dispose();
    _ifscController.dispose();
    _holderController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final storeId = widget.medicalStoreId ?? await _resolveStoreId();
      if (storeId == null || storeId.isEmpty) {
        setState(() {
          _error = 'Could not determine your pharmacy. Please re-login.';
          _loading = false;
        });
        return;
      }
      _storeId = storeId;
      await _refresh();
    } catch (e) {
      AppLogger.error('Payout bootstrap failed', e);
      setState(() {
        _error = 'Failed to load onboarding details.';
        _loading = false;
      });
    }
  }

  Future<String?> _resolveStoreId() async {
    final email = await StorageService.getUserEmail();
    if (email == null || email.isEmpty) return null;
    final store = await MedicalStoreService.getMedicalStoreByEmail(email: email);
    return store?['medicalStoreId']?.toString();
  }

  Future<void> _refresh() async {
    final storeId = _storeId;
    if (storeId == null) return;
    setState(() => _loading = true);
    try {
      final activation = await ChemistPayoutService.getActivationStatus(storeId);
      final payout = await ChemistPayoutService.getPayoutStatus(storeId);
      if (!mounted) return;
      setState(() {
        _activation = activation;
        _payout = payout;
        if (payout != null) {
          _businessNameController.text =
              payout.businessName ?? _businessNameController.text;
          _selectedBusinessType = payout.razorpayBusinessType ?? _selectedBusinessType;
          _ownerPanController.text = payout.ownerPanMasked ?? _ownerPanController.text;
          _ifscController.text = payout.bankIfscCode ?? _ifscController.text;
          _holderController.text =
              payout.bankAccountHolderName ?? _holderController.text;
        }
        _loading = false;
      });
    } on DioException catch (e) {
      AppLogger.error('Failed to refresh payout status', e);
      if (mounted) {
        setState(() => _loading = false);
        AppSnackBar.error(context, _dioMessage(e, 'Failed to load status.'));
      }
    }
  }

  // ── Activation fee ──────────────────────────────────────────────────────
  Future<void> _payActivationFee() async {
    final storeId = _storeId;
    if (storeId == null) return;

    // If we already have a link (reopen), just relaunch it — no API call.
    final existingUrl = _activation?.paymentLinkUrl;
    if (existingUrl != null && existingUrl.isNotEmpty) {
      await _openLink(existingUrl);
      return;
    }

    setState(() => _creatingLink = true);
    try {
      final activation =
          await ChemistPayoutService.createActivationLink(storeId);
      if (!mounted) return;
      setState(() => _activation = activation);

      final url = activation.paymentLinkUrl;
      if (url != null && url.isNotEmpty) {
        await _openLink(url);
      } else {
        if (mounted) {
          AppSnackBar.error(context, 'Payment link unavailable. Try again.');
        }
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to create activation link', e);
      if (mounted) {
        AppSnackBar.error(
            context, _dioMessage(e, 'Could not start the activation payment.'));
      }
    } finally {
      if (mounted) setState(() => _creatingLink = false);
    }
  }

  Future<void> _openLink(String url) async {
    try {
      final ok =
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (mounted) setState(() => _linkOpened = ok);
    } catch (e) {
      AppLogger.error('Failed to open payment link', e);
      if (mounted) AppSnackBar.error(context, 'Unable to open the payment link.');
    }
  }

  // ── Business + bank / payout submission ─────────────────────────────────
  Future<void> _submitBusinessAndBank() async {
    if (!_bankFormKey.currentState!.validate()) return;
    final storeId = _storeId;
    if (storeId == null) return;

    setState(() => _submittingBank = true);
    try {
      final account = _accountController.text.trim();
      final ifsc = _ifscController.text.trim().toUpperCase();
      final holder = _holderController.text.trim();

      // Business name/type are KYC fields fixed at onboarding time — Razorpay
      // doesn't support changing business_type after the linked account is
      // created, so they're only sent on the initial onboard call.
      final result = _payout?.isActive == true
          ? await ChemistPayoutService.updateBank(
              storeId: storeId,
              bankAccountNumber: account,
              bankIfscCode: ifsc,
              bankAccountHolderName: holder,
            )
          : await ChemistPayoutService.onboard(
              storeId: storeId,
              businessName: _businessNameController.text.trim(),
              razorpayBusinessType: _selectedBusinessType.value,
              ownerPan: _ownerPanController.text.trim().toUpperCase(),
              bankAccountNumber: account,
              bankIfscCode: ifsc,
              bankAccountHolderName: holder,
            );

      if (!mounted) return;
      setState(() => _payout = result);
      AppSnackBar.success(context, 'Business and bank details submitted successfully.');
    } on DioException catch (e) {
      AppLogger.error('Failed to submit business/bank details', e);
      if (mounted) {
        AppSnackBar.error(
            context, _dioMessage(e, 'Could not submit business/bank details.'));
      }
    } finally {
      if (mounted) setState(() => _submittingBank = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Payout & Activation'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loading ? null : _refresh,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _activation == null && _payout == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 56),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _bootstrap,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildActivationCard(),
          const SizedBox(height: 16),
          _buildBusinessAndBankCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Activation card ─────────────────────────────────────────────────────
  Widget _buildActivationCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.rocket_launch, 'Step 1 · Activation Fee'),
          const SizedBox(height: 12),
          if (_isActivated)
            _statusTile(
              Icons.check_circle,
              _green,
              'Activated',
              'Your pharmacy is activated.',
            )
          else ...[
            Text(
              _activation == null
                  ? 'One-time Platform Onboarding Fee: ₹14,999 + 18% GST.'
                  : 'Amount: ₹${_activation!.amount.toStringAsFixed(0)} + GST '
                      '₹${_activation!.gst.toStringAsFixed(0)}  =  '
                      '₹${_activation!.total.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _creatingLink ? null : _payActivationFee,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: _creatingLink
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.lock),
                label: Text(_linkOpened
                    ? 'Reopen Payment Link'
                    : 'Pay Onboarding Fee'),
              ),
            ),
            if (_linkOpened) ...[
              const SizedBox(height: 8),
              Text(
                'After paying in the browser, tap Refresh to update your status.',
                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ── Business + bank / payout card ───────────────────────────────────────
  Widget _buildBusinessAndBankCard() {
    // Razorpay doesn't support changing business_type after the linked account
    // is created, so these two fields become read-only once active.
    final businessLocked = _payout?.isActive == true;

    return _card(
      child: Form(
        key: _bankFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(Icons.assignment_ind, 'Step 2 · Business & Bank Details'),
            const SizedBox(height: 4),
            Text(
              'We create a Razorpay linked account so your medicine sales are '
              'settled to this bank account.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            if (_payout != null) _payoutStatusBadge(_payout!),
            const SizedBox(height: 12),
            TextFormField(
              controller: _businessNameController,
              readOnly: businessLocked,
              decoration: _inputDecoration('Business Name'),
              validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<BusinessType>(
              initialValue: _selectedBusinessType,
              decoration: _inputDecoration('Business Type'),
              items: BusinessType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: businessLocked
                  ? null
                  : (v) {
                      if (v != null) setState(() => _selectedBusinessType = v);
                    },
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ownerPanController,
              readOnly: businessLocked,
              textCapitalization: TextCapitalization.characters,
              decoration: _inputDecoration('Owner PAN',
                  hint: 'Individual PAN of the owner, e.g. AAAPA1234A'),
              validator: (v) {
                // Once locked, the field shows the masked value from the server
                // (e.g. XXXXXX234F) rather than a fresh entry — nothing new is
                // being submitted here, so skip format validation.
                if (businessLocked) return null;
                final t = (v ?? '').trim().toUpperCase();
                if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(t)) {
                  return 'Enter a valid PAN';
                }
                if (t[3] != 'P') {
                  return "Must be the owner's individual PAN (4th letter 'P')";
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ifscController,
              textCapitalization: TextCapitalization.characters,
              decoration:
                  _inputDecoration('Branch IFSC Code', hint: 'e.g. HDFC0001234'),
              validator: (v) {
                final t = (v ?? '').trim().toUpperCase();
                final ok = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(t);
                return ok ? null : 'Enter a valid IFSC code';
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _accountController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                'Account Number',
                hint: _payout?.bankAccountNumberMasked,
              ),
              validator: (v) {
                final t = (v ?? '').trim();
                if (t.length < 6) return 'Enter a valid account number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reenterAccountController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Re-Enter Account Number'),
              validator: (v) {
                if ((v ?? '').trim() != _accountController.text.trim()) {
                  return 'Account numbers do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _holderController,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration('Beneficiary Name'),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submittingBank ? null : _submitBusinessAndBank,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _submittingBank
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(_payout?.hasLinkedAccount == true
                        ? 'Update Details'
                        : 'Submit & Create Payout Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Small UI helpers ────────────────────────────────────────────────────
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: _indigo, size: 22),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _statusTile(IconData icon, Color color, String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: color)),
                Text(sub,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _payoutStatusBadge(ChemistPayoutStatusModel payout) {
    final status = payout.onboardingStatus;
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = _green;
        break;
      case 'rejected':
      case 'suspended':
        color = Colors.red;
        break;
      case 'needsclarification':
        color = Colors.orange;
        break;
      default:
        color = _indigo;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Payout status: $status',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          ],
        ),
        if ((payout.onboardingError ?? '').isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(payout.onboardingError!,
              style: const TextStyle(fontSize: 11.5, color: Colors.red)),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  String _dioMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map) {
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) return errors.first.toString();
      return data['message']?.toString() ?? data['error']?.toString() ?? fallback;
    }
    return fallback;
  }
}
