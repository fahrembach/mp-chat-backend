import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';
import '../models/community.dart';
import '../services/community_service.dart';
import '../services/auth_service.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({Key? key}) : super(key: key);

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final CommunityService _communityService = GetIt.instance<CommunityService>();
  final AuthService _authService = GetIt.instance<AuthService>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  File? _selectedAvatar;
  bool _isPrivate = false;
  bool _isLoading = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    try {
      _currentUser = await _authService.getCurrentUser();
    } catch (e) {
      debugPrint('Erro ao obter usuário atual: $e');
    }
  }

  Future<void> _pickAvatar() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedAvatar = File(image.path);
        });
      }
    } catch (e) {
      _showError('Erro ao selecionar avatar: $e');
    }
  }

  Future<void> _takeAvatarPhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedAvatar = File(image.path);
        });
      }
    } catch (e) {
      _showError('Erro ao tirar foto: $e');
    }
  }

  Future<void> _createCommunity() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Nome da comunidade é obrigatório');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showError('Descrição da comunidade é obrigatória');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? avatarUrl;
      
      // Upload do avatar se necessário
      if (_selectedAvatar != null) {
        avatarUrl = await _communityService.uploadCommunityAvatar(_selectedAvatar!.path);
      }

      // Criar comunidade
      await _communityService.createCommunity(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        avatar: avatarUrl,
        isPrivate: _isPrivate,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comunidade criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Erro ao criar comunidade: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Comunidade'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createCommunity,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Criar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar da comunidade
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showAvatarOptions,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!, width: 2),
                        color: Colors.grey[100],
                      ),
                      child: _selectedAvatar != null
                          ? ClipOval(
                              child: Image.file(
                                _selectedAvatar!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _showAvatarOptions,
                    child: const Text('Adicionar Foto'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Nome da comunidade
            const Text(
              'Nome da Comunidade',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Digite o nome da comunidade',
                border: OutlineInputBorder(),
              ),
              maxLength: 50,
            ),

            const SizedBox(height: 16),

            // Descrição da comunidade
            const Text(
              'Descrição',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Descreva sua comunidade...',
                border: OutlineInputBorder(),
              ),
              maxLength: 500,
            ),

            const SizedBox(height: 24),

            // Configurações de privacidade
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configurações de Privacidade',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Comunidade Privada'),
                      subtitle: const Text(
                        'Apenas membros convidados podem ver e participar',
                      ),
                      value: _isPrivate,
                      onChanged: (value) {
                        setState(() {
                          _isPrivate = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Informações sobre criação
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Sobre Comunidades',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Comunidades são espaços para pessoas com interesses em comum\n'
                      '• Você será o administrador da comunidade criada\n'
                      '• Membros podem ser adicionados através de convites\n'
                      '• Comunidades privadas são visíveis apenas para membros',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickAvatar();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.pop(context);
                _takeAvatarPhoto();
              },
            ),
            if (_selectedAvatar != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remover Foto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedAvatar = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}

