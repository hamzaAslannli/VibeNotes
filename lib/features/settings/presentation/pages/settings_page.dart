import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibe_notes/core/services/ai_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _apiKeyController = TextEditingController();
  bool _isLoading = true;
  bool _hasKey = false;
  bool _isSaving = false;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final key = await AIService.getApiKey();
    setState(() {
      if (key != null && key.isNotEmpty) {
        _apiKeyController.text = key;
        _hasKey = true;
      }
      _isLoading = false;
    });
  }

  Future<void> _saveApiKey() async {
    setState(() => _isSaving = true);
    await AIService.saveApiKey(_apiKeyController.text.trim());
    setState(() {
      _isSaving = false;
      _hasKey = _apiKeyController.text.trim().isNotEmpty;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
            SizedBox(width: 12),
            Text('API Key saved!'),
          ],
        ),
        backgroundColor: const Color(0xFF2A2A2A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent))
        : ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // AI Section
              _buildSectionHeader('🤖 AI Integration', 'Gemini API ile sesli notlarınızı özetleyin'),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepPurple.withOpacity(0.15),
                      Colors.blue.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status indicator
                    Row(
                      children: [
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            color: _hasKey ? Colors.greenAccent : Colors.orange,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: (_hasKey ? Colors.greenAccent : Colors.orange).withOpacity(0.5), blurRadius: 8)],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _hasKey ? 'AI Active' : 'API Key Required',
                          style: TextStyle(color: _hasKey ? Colors.greenAccent : Colors.orange, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // API Key Input
                    TextField(
                      controller: _apiKeyController,
                      obscureText: _obscureKey,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        labelText: 'Google Gemini API Key',
                        labelStyle: const TextStyle(color: Colors.white38),
                        hintText: 'AIza...',
                        hintStyle: const TextStyle(color: Colors.white12),
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 2)),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureKey ? Icons.visibility_off : Icons.visibility, color: Colors.white30),
                          onPressed: () => setState(() => _obscureKey = !_obscureKey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveApiKey,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSaving 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Save API Key', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Help text
                    GestureDetector(
                      onTap: () => launchUrl(Uri.parse('https://aistudio.google.com/app/apikey')),
                      child: Text(
                        '🔗 Get free API key from aistudio.google.com',
                        style: TextStyle(color: Colors.deepPurpleAccent.withOpacity(0.8), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // AI Features info
              _buildSectionHeader('✨ AI Features', 'API key ile aktif olan özellikler'),
              const SizedBox(height: 16),
              
              _buildFeatureCard(Icons.summarize_rounded, 'Akıllı Özetleme', 'Notlarınızı 3-4 cümleye özetler', Colors.cyan),
              const SizedBox(height: 12),
              _buildFeatureCard(Icons.tag, 'Anahtar Kelimeler', 'Önemli kelimeleri otomatik çıkarır', Colors.amber),
              const SizedBox(height: 12),
              _buildFeatureCard(Icons.category_rounded, 'Kategori Önerisi', 'Notunuz için en uygun kategoriyi önerir', Colors.green),
              const SizedBox(height: 12),
              _buildFeatureCard(Icons.checklist_rounded, 'Görev Listesi', 'Notunuzdan yapılacak görevleri çıkarır', Colors.orange),
              
              const SizedBox(height: 32),
              
              // About
              _buildSectionHeader('ℹ️ About', 'Vibe Notes v2.0'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('Vibe Notes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('v2.0.0 • AI Powered Voice Notes', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                    const SizedBox(height: 12),
                    Text('Made with 💜 by Vibe Team', style: TextStyle(color: Colors.deepPurpleAccent.withOpacity(0.6), fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 2),
                Text(description, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.2)),
        ],
      ),
    );
  }
}
