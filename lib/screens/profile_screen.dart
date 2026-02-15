import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../database/isar_service.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../utils/camera_support.dart';
import '../utils/navigation_helpers.dart';
import '../utils/tr_phone_input_formatter.dart';
import '../utils/turkish_upper_case_formatter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.forceSetup = false,
  });

  final bool forceSetup;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imagePicker = ImagePicker();

  DateTime? _birthDate;
  Uint8List? _photoBytes;
  bool _loading = true;
  bool _saving = false;
  bool _resetting = false;
  bool _showValidationHints = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await UserProfileService.getProfile();
      if (!mounted) return;

      if (profile != null) {
        _firstNameController.text = profile.firstName;
        _lastNameController.text = profile.lastName;
        _emailController.text = profile.email ?? '';
        _phoneController.text = TrPhoneInputFormatter.formatDigits(
          profile.phone ?? '',
        );
        _birthDate = profile.birthDate;
        _photoBytes = profile.photoBytes == null
            ? null
            : Uint8List.fromList(profile.photoBytes!);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil yüklenemedi. Uygulamayı yeniden başlatın.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera && !isCameraSourceAvailable()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kamera bu platformda desteklenmiyor.'),
          ),
        );
        return;
      }

      final file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photoBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resim alınamadı: $e'),
        ),
      );
    }
  }

  Future<void> _showImageSourcePicker() async {
    final cameraSupported = isCameraSourceAvailable();

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cameraSupported)
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () async {
                  Navigator.pop(context);
                  await Future<void>.delayed(const Duration(milliseconds: 220));
                  if (!mounted) return;
                  await _pickImage(ImageSource.camera);
                },
              ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () async {
                Navigator.pop(context);
                await Future<void>.delayed(const Duration(milliseconds: 220));
                if (!mounted) return;
                await _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
      locale: const Locale('tr', 'TR'),
    );

    if (selected == null) return;
    setState(() {
      _birthDate = selected;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _showValidationHints = true;
    });
    if (!_formKey.currentState!.validate() || _birthDate == null || _photoBytes == null) {
      return;
    }

    setState(() {
      _saving = true;
    });

    final profile = UserProfile()
      ..firstName = _firstNameController.text.trim()
      ..lastName = _lastNameController.text.trim()
      ..birthDate = _birthDate
      ..email = _emailController.text.trim()
      ..phone = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '')
      ..photoBytes = _photoBytes?.toList();

    try {
      await UserProfileService.save(profile);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil kaydedilemedi: $e'),
        ),
      );
      setState(() {
        _saving = false;
      });
    }
  }

  InputDecoration _requiredDecoration(String label) {
    return InputDecoration(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          const Text(
            'Zorunlu',
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndResetApp() async {
    if (_resetting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Dikkat',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          'Bu işlem sonrası tüm bilgileriniz silinecektir.\n'
          'Hesaplar, gelir/gider işlemleri, planlar, cari kartlar ve profil verileri kalıcı olarak kaldırılacaktır.\n\n'
          'Onaylıyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Evet, Sıfırla'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _resetting = true;
    });

    try {
      await IsarService.resetDatabase();
      if (!mounted) return;
      Navigator.pop(context, 'reset');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sıfırlama başarısız: $e'),
        ),
      );
      setState(() {
        _resetting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.forceSetup,
      child: Scaffold(
        drawer: buildAppMenuDrawer(),
        appBar: AppBar(
          leading: widget.forceSetup ? null : buildMenuLeading(),
          automaticallyImplyLeading: !widget.forceSetup,
          title: Text(widget.forceSetup
              ? 'Profil Oluştur'
              : 'Kullanıcı Profili'),
          actions: widget.forceSetup ? null : [buildHomeAction(context)],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (widget.forceSetup)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Devam etmek için profil bilgilerinizi giriniz.',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Profil Resmi',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Zorunlu',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      CircleAvatar(
                        radius: 44,
                        backgroundImage:
                            _photoBytes != null ? MemoryImage(_photoBytes!) : null,
                        child: _photoBytes == null
                            ? const Icon(Icons.person, size: 44)
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _showImageSourcePicker,
                            icon: const Icon(Icons.image_outlined),
                            label: const Text('Resim Seç'),
                          ),
                          if (_photoBytes != null)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _photoBytes = null;
                                });
                              },
                              child: const Text('Resmi Kaldır'),
                            ),
                        ],
                      ),
                      if (_showValidationHints && _photoBytes == null)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              'Profil resmi zorunludur.',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _firstNameController,
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: const [TurkishUpperCaseFormatter()],
                        decoration: _requiredDecoration('Ad'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ad zorunludur';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _lastNameController,
                        textCapitalization: TextCapitalization.words,
                        inputFormatters: const [TurkishUpperCaseFormatter()],
                        decoration: _requiredDecoration('Soyad'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Soyad zorunludur';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickBirthDate,
                        child: InputDecorator(
                          decoration: _requiredDecoration('Doğum Tarihi').copyWith(
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _birthDate == null
                                ? 'Seçiniz'
                                : DateFormat('dd.MM.yyyy').format(_birthDate!),
                          ),
                        ),
                      ),
                      if (_showValidationHints && _birthDate == null)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              'Doğum tarihi zorunludur.',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        decoration: _requiredDecoration('E-posta'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return 'E-posta zorunludur';
                          if (!v.contains('@') || !v.contains('.')) {
                            return 'Geçerli bir e-posta giriniz';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        decoration: _requiredDecoration('Telefon').copyWith(
                          hintText: '(5XX)XXX XX XX',
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: const [TrPhoneInputFormatter()],
                        validator: (value) {
                          final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                          if (digits.isEmpty) return 'Telefon zorunludur';
                          if (digits.length != 10) {
                            return 'Telefon formatı: (537)324 84 52';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saving || _resetting ? null : _save,
                          child: Text(
                            _saving
                                ? 'Kaydediliyor...'
                                : widget.forceSetup
                                    ? 'Kaydet ve Başla'
                                    : 'Kaydet',
                          ),
                        ),
                      ),
                      if (!widget.forceSetup) ...[
                        const SizedBox(height: 28),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tehlikeli İşlemler',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _saving || _resetting
                                ? null
                                : _confirmAndResetApp,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            icon: _resetting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.red,
                                    ),
                                  )
                                : const Icon(Icons.warning_amber_rounded),
                            label: Text(
                              _resetting
                                  ? 'Sıfırlanıyor...'
                                  : 'Uygulamayı Sıfırla',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
