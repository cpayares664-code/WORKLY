import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../app_scaffold.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _institutionController;
  late UserRole _selectedRole;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _institutionController = TextEditingController(text: widget.user.institution ?? '');
    _selectedRole = widget.user.role;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Editar Perfil',
      currentIndex: 8,
      actions: [
        TextButton.icon(
          onPressed: _saving ? null : _save,
          icon: const Icon(Icons.check, color: Colors.white),
          label: const Text('Guardar', style: TextStyle(color: Colors.white)),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.spaceLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                  ),
                  child: Center(
                    child: Text(
                      HelpersInitials.fromName(_nameController.text),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.spaceXl),
              _buildSectionLabel('Información Personal'),
              const SizedBox(height: AppDimens.spaceMd),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  hintText: 'Ej: Dra. Elena Vargas',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => Validators.required(v, field: 'El nombre'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppDimens.spaceMd),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'ejemplo@universidad.edu',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  final req = Validators.required(v, field: 'El correo');
                  if (req != null) return req;
                  return Validators.email(v);
                },
              ),
              const SizedBox(height: AppDimens.spaceMd),
              TextFormField(
                controller: _institutionController,
                decoration: const InputDecoration(
                  labelText: 'Institución',
                  hintText: 'Ej: Universidad Nacional de Investigación',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
              ),
              const SizedBox(height: AppDimens.spaceXl),
              _buildSectionLabel('Rol'),
              const SizedBox(height: AppDimens.spaceMd),
              _buildRoleSelector(),
              const SizedBox(height: AppDimens.spaceXl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save),
                  label: Text(_saving ? 'Guardando...' : 'Guardar Cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Wrap(
      spacing: AppDimens.spaceSm,
      children: UserRole.values.map((role) {
        final isSelected = _selectedRole == role;
        return GestureDetector(
          onTap: () => setState(() => _selectedRole = role),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              role.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final updated = widget.user.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      institution: _institutionController.text.trim().isEmpty
          ? null
          : _institutionController.text.trim(),
      role: _selectedRole,
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, updated);
      }
    });
  }
}

class HelpersInitials {
  static String fromName(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
