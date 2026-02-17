import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

/// Generic consent dialog that can be used for various consent scenarios
/// Includes support for checkbox, links, and custom styling
class ConsentDialog extends StatefulWidget {
  final String title;
  final IconData titleIcon;
  final Color titleColor;
  final String message;
  final String? checkboxText;
  final bool requireCheckbox;
  final String confirmButtonText;
  final String cancelButtonText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool barrierDismissible;
  final Map<String, String>? links; // Map of link text to URLs
  final Widget? customContent;

  const ConsentDialog({
    super.key,
    required this.title,
    required this.titleIcon,
    required this.titleColor,
    required this.message,
    this.checkboxText,
    this.requireCheckbox = false,
    this.confirmButtonText = 'I Accept',
    this.cancelButtonText = 'Cancel',
    required this.onConfirm,
    this.onCancel,
    this.barrierDismissible = false,
    this.links,
    this.customContent,
  });

  @override
  State<ConsentDialog> createState() => _ConsentDialogState();
}

class _ConsentDialogState extends State<ConsentDialog> {
  bool _isChecked = false;

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to open link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  TextSpan _buildMessageWithLinks(String message) {
    if (widget.links == null || widget.links!.isEmpty) {
      return TextSpan(
        text: message,
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey.shade700,
          height: 1.5,
        ),
      );
    }

    List<TextSpan> spans = [];
    String remainingText = message;

    // Sort links by their position in the message
    var sortedLinks = widget.links!.entries.toList()
      ..sort((a, b) {
        int posA = message.indexOf(a.key);
        int posB = message.indexOf(b.key);
        return posA.compareTo(posB);
      });

    for (var entry in sortedLinks) {
      int index = remainingText.indexOf(entry.key);
      if (index != -1) {
        // Add text before the link
        if (index > 0) {
          spans.add(TextSpan(
            text: remainingText.substring(0, index),
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ));
        }

        // Add the link
        spans.add(TextSpan(
          text: entry.key,
          style: TextStyle(
            fontSize: 15,
            color: widget.titleColor,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
            height: 1.5,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _launchUrl(entry.value),
        ));

        remainingText = remainingText.substring(index + entry.key.length);
      }
    }

    // Add remaining text
    if (remainingText.isNotEmpty) {
      spans.add(TextSpan(
        text: remainingText,
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey.shade700,
          height: 1.5,
        ),
      ));
    }

    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => widget.barrierDismissible,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.titleColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.titleIcon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Custom content or message
                      if (widget.customContent != null)
                        widget.customContent!
                      else
                        RichText(
                          text: _buildMessageWithLinks(widget.message),
                          textAlign: TextAlign.left,
                        ),

                      // Checkbox if required
                      if (widget.requireCheckbox) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.titleColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.titleColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _isChecked,
                                onChanged: (value) {
                                  setState(() {
                                    _isChecked = value ?? false;
                                  });
                                },
                                activeColor: widget.titleColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              Expanded(
                                child: RichText(
                                  text: _buildMessageWithLinks(
                                    widget.checkboxText ??
                                        'I have read and agree to the above',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onCancel ??
                            () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.cancelButtonText,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (widget.requireCheckbox && !_isChecked)
                            ? null
                            : () {
                                Navigator.of(context).pop();
                                widget.onConfirm();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),  // Green
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: Text(
                          widget.confirmButtonText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Information-only dialog (no checkbox, single "Understood" button)
class InfoDialog extends StatelessWidget {
  final String title;
  final IconData titleIcon;
  final Color titleColor;
  final String message;
  final String buttonText;
  final VoidCallback onConfirm;
  final bool barrierDismissible;
  final Map<String, String>? links;

  const InfoDialog({
    super.key,
    required this.title,
    required this.titleIcon,
    required this.titleColor,
    required this.message,
    this.buttonText = 'Understood',
    required this.onConfirm,
    this.barrierDismissible = false,
    this.links,
  });

  @override
  Widget build(BuildContext context) {
    return ConsentDialog(
      title: title,
      titleIcon: titleIcon,
      titleColor: titleColor,
      message: message,
      requireCheckbox: false,
      confirmButtonText: buttonText,
      cancelButtonText: '',
      onConfirm: onConfirm,
      barrierDismissible: barrierDismissible,
      links: links,
      customContent: Column(
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}