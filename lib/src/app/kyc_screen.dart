part of 'brickclub_app.dart';

class KycStatusCard extends StatelessWidget {
  const KycStatusCard({
    super.key,
    required this.kyc,
    required this.onStartKyc,
    this.compact = false,
    this.showAction = true,
  });

  final KycProfile kyc;
  final VoidCallback onStartKyc;
  final bool compact;
  final bool showAction;

  @override
  Widget build(BuildContext context) {
    final isApproved = kyc.status == KycStatus.approved;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isApproved
                    ? Icons.verified_rounded
                    : Icons.verified_user_outlined,
                color: isApproved ? AppColors.success : AppColors.gold,
                size: 30,
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KYC ${kyc.label}', style: AppText.cardHeadingSmall),
                    SizedBox(height: 4),
                    Text(_statusCopy(kyc), style: AppText.body),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          ProgressLine(value: kyc.completionRatio.clamp(0, 1), height: 6),
          if (!compact) ...[
            SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _KycChip('Email', kyc.emailVerified),
                _KycChip('Phone', kyc.phoneVerified),
                _KycChip('Identity', kyc.status == KycStatus.approved),
              ],
            ),
          ],
          if (showAction) ...[
            SizedBox(height: 16),
            PrimaryButton(
              key: const ValueKey('kyc-status-cta'),
              label: isApproved ? 'View KYC details' : 'Complete KYC',
              height: 44,
              onPressed: onStartKyc,
            ),
          ],
        ],
      ),
    );
  }

  String _statusCopy(KycProfile kyc) {
    return switch (kyc.status) {
      KycStatus.approved => 'Financial actions are unlocked.',
      KycStatus.submitted => 'Your documents are under review.',
      KycStatus.rejected =>
        kyc.rejectionReason ?? 'Review the request and resubmit.',
      _ => 'Required before purchases and wallet changes.',
    };
  }
}

class _KycChip extends StatelessWidget {
  const _KycChip(this.label, this.complete);

  final String label;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return ChoicePill(
      label: '$label ${complete ? 'OK' : 'Needed'}',
      selected: complete,
    );
  }
}

class KycScreen extends StatefulWidget {
  const KycScreen({super.key, required this.repository});

  final KycRepository repository;

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final phoneCodeController = TextEditingController();
  final imagePicker = ImagePicker();
  DateTime? dateOfBirth;
  KycDocumentFile? governmentId;
  KycDocumentFile? selfie;
  KycDocumentFile? addressProof;
  bool sendingEmail = false;
  bool sendingPhone = false;
  bool submitting = false;
  String? kycMessage;

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    phoneCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PhoneFrame(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: detailAppBar(context, 'Verify identity'),
        body: StreamBuilder<KycProfile>(
          stream: widget.repository.watchProfile(),
          builder: (context, snapshot) {
            final kyc =
                snapshot.data ??
                const KycProfile(
                  status: KycStatus.notStarted,
                  emailVerified: false,
                  phoneVerified: false,
                );
            _hydrateOnce(kyc);
            return Form(
              key: formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KycStatusCard(
                      kyc: kyc,
                      onStartKyc: () {},
                      compact: true,
                      showAction: false,
                    ),
                    if (kycMessage != null) ...[
                      SizedBox(height: 14),
                      _KycMessageBanner(message: kycMessage!),
                    ],
                    SizedBox(height: 18),
                    const FieldLabel('Full legal name'),
                    SizedBox(height: 8),
                    AppTextField(
                      controller: fullNameController,
                      hintText: 'Name exactly as shown on your ID',
                    ),
                    SizedBox(height: 16),
                    const FieldLabel('Date of birth'),
                    SizedBox(height: 8),
                    _PickerTile(
                      key: const ValueKey('kyc-dob'),
                      icon: Icons.calendar_month_outlined,
                      title: dateOfBirth == null
                          ? 'Select date'
                          : DateFormat.yMMMd().format(dateOfBirth!),
                      onTap: _pickDateOfBirth,
                    ),
                    SizedBox(height: 16),
                    const FieldLabel('Government ID or passport'),
                    SizedBox(height: 8),
                    _PickerTile(
                      key: const ValueKey('kyc-government-id'),
                      icon: Icons.badge_outlined,
                      title: governmentId?.name ?? 'Upload ID document',
                      onTap: () => _pickFile((file) => governmentId = file),
                    ),
                    SizedBox(height: 16),
                    const FieldLabel('Selfie / face verification'),
                    SizedBox(height: 8),
                    _PickerTile(
                      key: const ValueKey('kyc-selfie'),
                      icon: Icons.face_retouching_natural_outlined,
                      title: selfie?.name ?? 'Capture selfie',
                      onTap: _pickSelfie,
                    ),
                    SizedBox(height: 16),
                    const FieldLabel('Physical address proof'),
                    SizedBox(height: 8),
                    _PickerTile(
                      key: const ValueKey('kyc-address-proof'),
                      icon: Icons.home_work_outlined,
                      title:
                          addressProof?.name ?? 'Upload utility bill or lease',
                      onTap: () => _pickFile((file) => addressProof = file),
                    ),
                    SizedBox(height: 16),
                    const FieldLabel('Phone verification'),
                    SizedBox(height: 8),
                    AppTextField(
                      key: const ValueKey('kyc-phone'),
                      controller: phoneController,
                      hintText: '+256774224734',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_iphone_rounded,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.telephoneNumber],
                    ),
                    SizedBox(height: 10),
                    SecondaryButton(
                      key: const ValueKey('send-phone-code'),
                      label: sendingPhone ? 'Sending...' : 'Send code',
                      onPressed: sendingPhone ? null : _sendPhoneCode,
                    ),
                    SizedBox(height: 10),
                    AppTextField(
                      key: const ValueKey('kyc-phone-code'),
                      controller: phoneCodeController,
                      hintText: 'Verification code',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.sms_outlined,
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(height: 16),
                    const FieldLabel('Email verification'),
                    SizedBox(height: 8),
                    _VerificationRow(
                      label: kyc.emailVerified
                          ? 'Email verified'
                          : 'Email not verified',
                      verified: kyc.emailVerified,
                      action: sendingEmail ? 'Sending...' : 'Send email',
                      onAction: sendingEmail || kyc.emailVerified
                          ? null
                          : _sendEmailVerification,
                    ),
                    SizedBox(height: 26),
                    PrimaryButton(
                      key: const ValueKey('submit-kyc'),
                      label: submitting ? 'Submitting...' : 'Submit for review',
                      onPressed: submitting ? null : _submit,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Phone codes appear in the Firebase Auth emulator. Development emails appear in Mailpit.',
                      style: AppText.disclosure,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  var hydrated = false;

  void _hydrateOnce(KycProfile kyc) {
    if (hydrated) return;
    fullNameController.text = kyc.fullLegalName ?? fullNameController.text;
    phoneController.text = kyc.phoneNumber ?? phoneController.text;
    dateOfBirth = kyc.dateOfBirth;
    hydrated = true;
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? DateTime(now.year - 25),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.gold,
            surface: AppColors.panel,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => dateOfBirth = picked);
    }
  }

  Future<void> _pickFile(ValueChanged<KycDocumentFile> onPicked) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    final file = result?.files.single;
    if (file?.bytes == null) return;
    setState(() {
      onPicked(
        KycDocumentFile(
          name: file!.name,
          bytes: file.bytes!,
          contentType: _contentTypeFor(file.name),
        ),
      );
    });
  }

  Future<void> _pickSelfie() async {
    final source = kIsWeb ? ImageSource.gallery : ImageSource.camera;
    final image = await imagePicker.pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 84,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() {
      selfie = KycDocumentFile(
        name: image.name,
        bytes: bytes,
        contentType: image.mimeType ?? _contentTypeFor(image.name),
      );
    });
  }

  Future<void> _sendEmailVerification() async {
    setState(() {
      kycMessage = null;
      sendingEmail = true;
    });
    try {
      await widget.repository.sendEmailVerification();
      if (mounted) showMessage(context, 'Verification email sent');
    } catch (error) {
      if (mounted) _showKycMessage(_kycErrorMessage(error));
    } finally {
      if (mounted) setState(() => sendingEmail = false);
    }
  }

  Future<void> _sendPhoneCode() async {
    if (phoneController.text.trim().isEmpty) {
      _showKycMessage('Enter your phone number first');
      return;
    }
    setState(() {
      kycMessage = null;
      sendingPhone = true;
    });
    try {
      await widget.repository.sendPhoneVerificationCode(phoneController.text);
      if (mounted) {
        showMessage(context, 'Code sent. Check the Firebase Auth emulator.');
      }
    } catch (error) {
      if (mounted) _showKycMessage(_kycErrorMessage(error));
    } finally {
      if (mounted) setState(() => sendingPhone = false);
    }
  }

  Future<void> _submit() async {
    final missing = _missingFields();
    if (missing != null) {
      _showKycMessage(missing);
      return;
    }

    setState(() {
      kycMessage = null;
      submitting = true;
    });
    try {
      await widget.repository.submit(
        KycSubmission(
          fullLegalName: fullNameController.text,
          dateOfBirth: dateOfBirth!,
          phoneNumber: phoneController.text,
          phoneVerificationCode: phoneCodeController.text,
          governmentId: governmentId!,
          selfie: selfie!,
          addressProof: addressProof!,
        ),
      );
      if (mounted) {
        showMessage(context, 'KYC submitted for automatic checks');
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) _showKycMessage(_kycErrorMessage(error));
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  String? _missingFields() {
    if (fullNameController.text.trim().isEmpty) return 'Enter your legal name';
    if (dateOfBirth == null) return 'Select your date of birth';
    if (governmentId == null) return 'Upload your ID or passport';
    if (selfie == null) return 'Capture a selfie';
    if (addressProof == null) return 'Upload address proof';
    if (phoneController.text.trim().isEmpty) return 'Enter your phone number';
    if (!_isE164PhoneNumber(phoneController.text.trim())) {
      return 'Enter your phone number in international format, e.g. +256774224734.';
    }
    if (phoneCodeController.text.trim().isEmpty) {
      return 'Enter the phone verification code';
    }
    return null;
  }

  void _showKycMessage(String message) {
    final displayMessage = message.trim().isEmpty
        ? 'We could not update your KYC details. Please try again.'
        : message.trim();
    setState(() => kycMessage = displayMessage);
    showMessage(context, displayMessage);
  }

  bool _isE164PhoneNumber(String phoneNumber) {
    return RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(phoneNumber);
  }

  String _contentTypeFor(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.png')) return 'image/png';
    return 'image/jpeg';
  }
}

class _KycMessageBanner extends StatelessWidget {
  const _KycMessageBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const ValueKey('kyc-message'),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withValues(alpha: .55)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.warning,
              size: 20,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        constraints: const BoxConstraints(minHeight: 50),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 20),
            SizedBox(width: 12),
            Expanded(child: Text(title, style: AppText.fieldLabel)),
            Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _VerificationRow extends StatelessWidget {
  const _VerificationRow({
    required this.label,
    required this.verified,
    required this.action,
    required this.onAction,
  });

  final String label;
  final bool verified;
  final String action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(
            verified ? Icons.check_circle_rounded : Icons.mail_outline_rounded,
            color: verified ? AppColors.success : AppColors.gold,
          ),
          SizedBox(width: 12),
          Expanded(child: Text(label, style: AppText.fieldLabel)),
          SizedBox(
            width: 104,
            child: SecondaryButton(
              label: action,
              onPressed: onAction,
              compact: true,
            ),
          ),
        ],
      ),
    );
  }
}

String _kycErrorMessage(Object error) {
  if (error is KycValidationException) {
    return error.message;
  }
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-phone-number' =>
        'Enter your phone number in international format, e.g. +256774224734.',
      'invalid-verification-code' => 'Enter the SMS code from the emulator.',
      'credential-already-in-use' =>
        'That phone number is already linked to another account.',
      'too-many-requests' => 'Too many verification attempts. Try again later.',
      _ =>
        error.message?.trim().isNotEmpty == true
            ? error.message!
            : 'Phone verification failed. Please try again.',
    };
  }
  if (error is FirebaseException) {
    return switch (error.code) {
      'unauthenticated' => 'Sign in again to continue with KYC.',
      'permission-denied' =>
        'You do not have permission to update this KYC profile.',
      'unavailable' =>
        'KYC services are temporarily unavailable. Please try again shortly.',
      'deadline-exceeded' =>
        'The request took too long. Please check your connection and try again.',
      'storage/unauthorized' =>
        'You do not have permission to upload this document.',
      'storage/canceled' => 'Document upload was cancelled.',
      'storage/retry-limit-exceeded' =>
        'The upload took too long. Please check your connection and try again.',
      'storage/quota-exceeded' =>
        'Document uploads are temporarily unavailable. Please try again later.',
      _ => 'We could not update your KYC details. Please try again.',
    };
  }
  return _friendlyUnexpectedMessage(error);
}

