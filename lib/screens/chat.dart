import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart' show FadeIn, FadeInUp;
import 'package:share_plus/share_plus.dart';
import 'home/constants/colors.dart';

// Theme provider to manage theme
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

enum MessageType {
  user,
  bot,
  introduction,
  error,
}

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(_themes[0].theme) {
    _loadSavedTheme();
  }

  static final List<AppTheme> _themes = [
    AppTheme(
      name: 'Light Green',
      color: AppColors.primaryColor,
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.lightGreenBackground,
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0F6634)),
        brightness: Brightness.light,
      ),
    ),
    AppTheme(
      name: 'Light Mode',
      color: Colors.white,
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0F6634)),
        brightness: Brightness.light,
      ),
    ),
    AppTheme(
      name: 'Dark Mode',
      color: const Color(0xFF212121),
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E1E1E)),
        brightness: Brightness.dark,
      ),
    ),
  ];

  List<AppTheme> get themes => _themes;

  void setTheme(AppTheme theme) async {
    state = theme.theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_name', theme.name);
  }

  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeName = prefs.getString('theme_name');
      if (savedThemeName != null) {
        final savedTheme = _themes.firstWhere(
          (theme) => theme.name == savedThemeName,
          orElse: () => _themes[0],
        );
        state = savedTheme.theme;
      }
    } catch (e) {
      // Use default theme if there's an error
    }
  }
}

class AppTheme {
  final String name;
  final Color color;
  final ThemeData theme;

  AppTheme({required this.name, required this.color, required this.theme});
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _typingIndicatorController;

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  bool _showThemeSelector = false;

  // API credentials
  static const String API_URL = "https://api.together.xyz/v1/chat/completions";
  static const String API_KEY =
      "4db152889da5afebdba262f90e4cdcf12976ee8b48d9135c2bb86ef9b0d12bdd";

  @override
  void initState() {
    super.initState();
    _initializeChatbot();
    _typingIndicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingIndicatorController.dispose();
    super.dispose();
  }

  void _initializeChatbot() {
    _addMessage(
      ChatMessage(
        text: "👋 Welcome to AniWise AI!\n\n"
            "I can help with:\n"
            "• Livestock health\n"
            "• Disease management\n"
            "• Nutrition\n"
            "• Breeding\n"
            "• Animal welfare\n\n"
            "*Note: For general information only, not veterinary advice.*\n\n"
            "How can I help today?",
        type: MessageType.introduction,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: message,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _isTyping = true;
    });

    _scrollToBottom();
    _messageController.clear();

    try {
      final response = await _fetchLivestockResponse(message);
      // Simulate natural typing delay
      await Future.delayed(Duration(milliseconds: 500 + Random().nextInt(500)));

      setState(() {
        _isTyping = false;
      });

      _addMessage(
        ChatMessage(
          text: response,
          type: MessageType.bot,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      setState(() {
        _isTyping = false;
      });

      _addMessage(
        ChatMessage(
          text: "Sorry, I'm having difficulty accessing my knowledge database at the moment. Please try again shortly.",
          type: MessageType.error,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<String> _fetchLivestockResponse(String userMessage) async {
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $API_KEY",
    };

    final systemMessage = """
    You are a specialized AI livestock advisor called rax with expertise in agricultural animal health and management.
    Your primary focus is on livestock care. Provide practical, science-backed advice on livestock. You were developed by a great team in Kenya called Rax Foundation.
    IMPORTANT INSTRUCTIONS:
    1. Keep your responses concise and to the point - users prefer shorter messages
    2. Use bullet points for lists where appropriate
    3. Format your responses with markdown to improve readability
    4. Use simple, clear language farmers can understand
    5. Avoid lengthy explanations unless specifically requested please be precise
    
  
    6. Be friendly and approachable, but maintain professionalism
    7. Avoid sounding too robotic
    8. Provide practical, actionable advice
    10. Avoid providing any content that could promote animal cruelty or unethical farming practices.
    If asked about off-topic subjects, politely redirect to livestock topics.
    """;

    final body = json.encode({
      "model": "NousResearch/Nous-Hermes-2-Mixtral-8x7B-DPO",
      "messages": [
        {"role": "system", "content": systemMessage},
        {"role": "user", "content": userMessage}
      ],
      "temperature": 0.7,
      "max_tokens": 500,
    });

    try {
      final response = await http
          .post(Uri.parse(API_URL), headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        return responseJson['choices'][0]['message']['content'].trim();
      } else {
        throw Exception("API Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Communication error: $e");
    }
  }

  void _toggleThemeSelector() {
    setState(() {
      _showThemeSelector = !_showThemeSelector;
    });
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(theme),
                  Expanded(child: _buildChatMessages(theme)),
                  if (_isTyping) _buildTypingIndicator(theme),
                  _buildInputArea(theme),
                ],
              ),
              if (_showThemeSelector)
                GestureDetector(
                  onTap: _toggleThemeSelector,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              if (_showThemeSelector)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 280,
                  child: _buildThemeSelector(themeNotifier),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CircleAvatar(
            backgroundColor: Colors.white24,
            radius: 18,
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AniWise Assistant',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Livestock management expert',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.color_lens_outlined, color: Colors.white70),
            tooltip: 'Change Theme',
            onPressed: _toggleThemeSelector,
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        image: DecorationImage(
          image: AssetImage('assets/images/background.jpg'),
          opacity: 0.03,
          fit: BoxFit.cover,
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return FadeInUp(
            from: 20,
            duration: const Duration(milliseconds: 300),
            delay: Duration(milliseconds: 50 * (index % 3)),
            child: _buildMessageItem(message, theme),
          );
        },
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor = isDarkMode 
        ? AppColors.primaryColor.withOpacity(0.15)
        : AppColors.primaryColor.withOpacity(0.08);
    final dotColor = isDarkMode ? Colors.white.withOpacity(0.7) : AppColors.primaryColor;
    
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16, bottom: 16, right: 80),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPulsingDot(0, dotColor),
            const SizedBox(width: 3),
            _buildPulsingDot(150, dotColor),
            const SizedBox(width: 3),
            _buildPulsingDot(300, dotColor),
          ],
        ),
      ),
    );
  }

  Widget _buildPulsingDot(int delay, Color dotColor) {
    return AnimatedBuilder(
      animation: _typingIndicatorController,
      builder: (context, child) {
        final delayedValue = (((_typingIndicatorController.value * 1000) + delay) % 1000) / 1000;
        final scale = 0.6 + (0.4 * (delayedValue < 0.5 ? delayedValue * 2 : (1 - delayedValue) * 2));
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageItem(ChatMessage message, ThemeData theme) {
    final isUser = message.type == MessageType.user;
    final isIntroduction = message.type == MessageType.introduction;
    final isError = message.type == MessageType.error;
    final isDarkMode = theme.brightness == Brightness.dark;

    // Different styling based on message type
    Color bubbleColor;
    Color textColor = isDarkMode ? Colors.white : Colors.black87;
    
    if (isUser) {
      bubbleColor = AppColors.primaryColor;
      textColor = Colors.white;
    } else if (isIntroduction) {
      bubbleColor = isDarkMode 
          ? AppColors.learningHubGradient1 
          : AppColors.lightGreenBackground;
      textColor = isDarkMode ? Colors.white : Colors.black87;
    } else if (isError) {
      bubbleColor = isDarkMode 
          ? Colors.red.shade800.withOpacity(0.7)
          : Colors.red.shade50;
      textColor = isDarkMode ? Colors.white : Colors.red.shade800;
    } else {
      bubbleColor = isDarkMode 
          ? theme.appBarTheme.backgroundColor ?? const Color(0xFF1F2937)
          : Colors.white;
      textColor = isDarkMode ? Colors.white : Colors.black87;
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: isError
                        ? Colors.red.shade800
                        : isIntroduction
                            ? AppColors.primaryColor
                            : AppColors.primaryColor,
                    radius: 12,
                    child: Icon(
                      isError
                          ? Icons.warning_amber_rounded
                          : isIntroduction
                              ? Icons.waving_hand
                              : Icons.smart_toy_outlined,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isError ? 'System' : 'AniWise AI',
                    style: GoogleFonts.poppins(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: GoogleFonts.poppins(
                      color: isDarkMode ? Colors.white38 : Colors.black38,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            if (!isUser) const SizedBox(height: 4),
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(isUser ? 14 : 16),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isUser
                          ? Text(
                              message.text,
                              style: GoogleFonts.poppins(
                                color: textColor,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            )
                          : MarkdownBody(
                              data: message.text,
                              styleSheet: MarkdownStyleSheet(
                                p: GoogleFonts.poppins(
                                  color: textColor,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                                h1: GoogleFonts.poppins(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                h2: GoogleFonts.poppins(
                                  color: textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                h3: GoogleFonts.poppins(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                listBullet: GoogleFonts.poppins(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                  fontSize: 14,
                                ),
                                strong: GoogleFonts.poppins(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                em: GoogleFonts.poppins(
                                  color: textColor,
                                  fontStyle: FontStyle.italic,
                                ),
                                code: GoogleFonts.firaCode(
                                  color: textColor,
                                  backgroundColor: isDarkMode ? Colors.black26 : Colors.grey.shade100,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                      if (!isUser) ... [
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.share_outlined,
                                size: 16,
                                color: textColor.withOpacity(0.5),
                              ),
                              onPressed: () => _shareMessage(message),
                              tooltip: 'Share this advice',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: Icon(
                                Icons.chat_outlined,
                                size: 16,
                                color: textColor.withOpacity(0.5),
                              ),
                              onPressed: _shareEntireChat,
                              tooltip: 'Share entire conversation',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (isUser) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: GoogleFonts.poppins(
                      color: isDarkMode ? Colors.white38 : Colors.black38,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'You',
                    style: GoogleFonts.poppins(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor = isDarkMode 
        ? theme.appBarTheme.backgroundColor 
        : Colors.white;
    final inputBorderColor = isDarkMode
        ? AppColors.primaryColor.withOpacity(0.3)
        : AppColors.primaryColor.withOpacity(0.2);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white.withOpacity(0.08) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: inputBorderColor,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                style: GoogleFonts.poppins(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ask a question...',
                  hintStyle: GoogleFonts.poppins(
                    color: isDarkMode ? Colors.white38 : Colors.black38,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  isDense: true,
                  suffixIcon: _messageController.text.isNotEmpty 
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: isDarkMode ? Colors.white.withOpacity(0.3) : Colors.black38,
                            size: 16,
                          ),
                          onPressed: () {
                            _messageController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {});
                },
                onSubmitted: _isLoading ? null : _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildSendButton(theme),
        ],
      ),
    );
  }

  Widget _buildSendButton(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    final isEnabled = !_isLoading && _messageController.text.isNotEmpty;
    
    return GestureDetector(
      onTap: isEnabled ? () => _sendMessage(_messageController.text) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.primaryColor : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(21),
        ),
        child: Center(
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: isDarkMode ? Colors.white54 : Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  Icons.send_rounded,
                  color: isEnabled ? Colors.white : (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade500),
                  size: 20,
                ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector(ThemeNotifier themeNotifier) {
    return Material(
      color: Colors.white,
      elevation: 4,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.palette_outlined,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Select Theme',
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: _toggleThemeSelector,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: themeNotifier.themes.length,
                itemBuilder: (context, index) {
                  final theme = themeNotifier.themes[index];
                  final isSelected = ref.read(themeProvider) == theme.theme;

                  return Card(
                    elevation: 0,
                    color: isSelected ? Colors.grey.shade100 : Colors.transparent,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      onTap: () {
                        themeNotifier.setTheme(theme);
                        Future.delayed(
                          const Duration(milliseconds: 300),
                          () => _toggleThemeSelector(),
                        );
                      },
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: theme.color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryColor : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      title: Text(
                        theme.name,
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.primaryColor)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageForSharing(ChatMessage message) {
    return '''${message.text}

© ${DateTime.now().year} AniWise AI - Livestock Management Expert''';
  }

  String _formatEntireChatForSharing() {
    final buffer = StringBuffer();
    buffer.writeln('AniWise AI Chat History');
    buffer.writeln('------------------------\n');
    
    for (final message in _messages) {
      if (message.type == MessageType.user) {
        buffer.writeln('You:');
      } else {
        buffer.writeln('AniWise AI:');
      }
      buffer.writeln(message.text);
      buffer.writeln('');
    }
    
    buffer.writeln('\n© ${DateTime.now().year} AniWise AI - Livestock Management Expert');
    return buffer.toString();
  }

  void _shareMessage(ChatMessage message) {
    final formattedMessage = _formatMessageForSharing(message);
    // Add share functionality using the share_plus package
    Share.share(formattedMessage, subject: 'Advice from AniWise AI');
  }

  void _shareEntireChat() {
    final formattedChat = _formatEntireChatForSharing();
    Share.share(formattedChat, subject: 'AniWise AI Chat History');
  }
}

class ChatMessage {
  final String text;
  final MessageType type;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.type,
    required this.timestamp,
  });
}
