import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/product_provider.dart';

class CreateEditProductScreen extends StatefulWidget {
  /// Si [product] es null → modo creación. Si no, modo edición.
  final ProductModel? product;

  const CreateEditProductScreen({super.key, this.product});

  @override
  State<CreateEditProductScreen> createState() =>
      _CreateEditProductScreenState();
}

class _CreateEditProductScreenState extends State<CreateEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _categoryIdCtrl = TextEditingController();
  final _categoryNameCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();

  File? _pickedImage;
  bool _isLoading = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final p = widget.product!;
      _nameCtrl.text = p.name;
      _descCtrl.text = p.description;
      _priceCtrl.text = p.price.toString();
      _stockCtrl.text = p.stock.toString();
      _categoryIdCtrl.text = p.categoryId;
      _categoryNameCtrl.text = p.categoryName;
      _discountCtrl.text = p.discountPrice?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _descCtrl, _priceCtrl, _stockCtrl,
      _categoryIdCtrl, _categoryNameCtrl, _discountCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (xfile != null) {
      setState(() => _pickedImage = File(xfile.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final provider = context.read<ProductProvider>();

    try {
      if (_isEditing) {
        await provider.updateProduct(
          productId: widget.product!.id,
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          price: double.parse(_priceCtrl.text.trim()),
          stock: int.parse(_stockCtrl.text.trim()),
          categoryId: _categoryIdCtrl.text.trim(),
          categoryName: _categoryNameCtrl.text.trim(),
          discountPrice: _discountCtrl.text.trim().isEmpty
              ? null
              : double.tryParse(_discountCtrl.text.trim()),
          newImageFile: _pickedImage,
          existingImageUrls: widget.product!.imageUrls,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto actualizado')),
          );
          Navigator.pop(context);
        }
      } else {
        await provider.createProduct(
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          price: double.parse(_priceCtrl.text.trim()),
          stock: int.parse(_stockCtrl.text.trim()),
          categoryId: _categoryIdCtrl.text.trim(),
          categoryName: _categoryNameCtrl.text.trim(),
          discountPrice: _discountCtrl.text.trim().isEmpty
              ? null
              : double.tryParse(_discountCtrl.text.trim()),
          imageFile: _pickedImage,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto creado')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Producto' : 'Nuevo Producto'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    image: _pickedImage != null
                        ? DecorationImage(
                            image: FileImage(_pickedImage!),
                            fit: BoxFit.cover,
                          )
                        : (_isEditing &&
                                widget.product!.imageUrls.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(
                                    widget.product!.imageUrls.first),
                                fit: BoxFit.cover,
                              )
                            : null,
                  ),
                  child: (_pickedImage == null &&
                          (!_isEditing ||
                              widget.product!.imageUrls.isEmpty))
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Toca para agregar imagen',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _nameCtrl,
                label: 'Nombre del producto',
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: _descCtrl,
                label: 'Descripción',
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceCtrl,
                      label: 'Precio',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Requerido';
                        if (double.tryParse(v) == null) return 'Número inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _discountCtrl,
                      label: 'Precio oferta (opcional)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: _stockCtrl,
                label: 'Stock',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (int.tryParse(v) == null) return 'Número entero';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _categoryIdCtrl,
                      label: 'ID Categoría',
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _categoryNameCtrl,
                      label: 'Nombre Categoría',
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: _isEditing ? 'Guardar cambios' : 'Crear producto',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
