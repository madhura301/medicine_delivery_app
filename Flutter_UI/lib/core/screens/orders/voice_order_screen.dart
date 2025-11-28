import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmaish/core/services/order_service.dart';
import 'package:pharmaish/shared/models/order_enums.dart';
import 'package:pharmaish/shared/models/order_model.dart';
import 'package:pharmaish/utils/app_logger.dart';
import 'package:pharmaish/shared/widgets/step_progress_indicator.dart';
import 'package:pharmaish/shared/widgets/address_selector_widget.dart';
import 'package:pharmaish/utils/order_exceptions.dart';
import 'package:pharmaish/utils/storage.dart';

class VoiceOrderScreen extends StatefulWidget {
  final String customerId;

  const VoiceOrderScreen({super.key, required this.customerId});

  @override
  State<VoiceOrderScreen> createState() => _VoiceOrderScreenState();
}

class _VoiceOrderScreenState extends State<VoiceOrderScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Address selection
  CustomerAddressDto? _selectedAddress;

  // Recording variables
  FlutterSoundRecorder? _audioRecorder;
  FlutterSoundPlayer? _audioPlayer;
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isPlaying = false;
  bool _recorderInitialized = false;
  bool _playerInitialized = false;
  String? _audioPath;
  Duration _recordingDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  // Order type
  String _orderType = 'prescription';
  String _deliveryType = 'home';
  String _urgency = 'regular';

  final List<StepItem> _steps = const [
    StepItem(label: 'Record', icon: Icons.mic),
    StepItem(label: 'Details', icon: Icons.edit_note),
    StepItem(label: 'Review', icon: Icons.preview),
  ];

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    try {
      _audioRecorder = FlutterSoundRecorder();
      _audioPlayer = FlutterSoundPlayer();

      await _audioRecorder!.openRecorder();
      await _audioPlayer!.openPlayer();

      setState(() {
        _recorderInitialized = true;
        _playerInitialized = true;
      });

      // Setup player subscriptions
      _audioPlayer!.onProgress!.listen((event) {
        setState(() {
          _playbackPosition = event.position;
          _totalDuration = event.duration;
        });
      });

      AppLogger.info('Audio recorder and player initialized');
    } catch (e) {
      AppLogger.error('Error initializing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _stopPlayback();
    _audioRecorder?.closeRecorder();
    _audioPlayer?.closePlayer();
    _audioRecorder = null;
    _audioPlayer = null;
    _patientNameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<bool> _checkPermission() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required for recording'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
    return true;
  }

  Future<void> _startRecording() async {
    if (!_recorderInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recorder not initialized. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final hasPermission = await _checkPermission();
    if (!hasPermission) return;

    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String filePath =
          '${appDocDir.path}/voice_order_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _audioRecorder!.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
      );

      setState(() {
        _isRecording = true;
        _isPaused = false;
        _audioPath = filePath;
        _recordingDuration = Duration.zero;
      });

      _updateRecordingDuration();

      AppLogger.info('Recording started: $filePath');
    } catch (e) {
      AppLogger.error('Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateRecordingDuration() {
    if (_isRecording && !_isPaused) {
      Future.delayed(const Duration(seconds: 1), () {
        if (_isRecording && !_isPaused && mounted) {
          setState(() {
            _recordingDuration += const Duration(seconds: 1);
          });
          _updateRecordingDuration();
        }
      });
    }
  }

  Future<void> _pauseRecording() async {
    try {
      await _audioRecorder!.pauseRecorder();
      setState(() => _isPaused = true);
      AppLogger.info('Recording paused');
    } catch (e) {
      AppLogger.error('Error pausing recording: $e');
    }
  }

  Future<void> _resumeRecording() async {
    try {
      await _audioRecorder!.resumeRecorder();
      setState(() => _isPaused = false);
      _updateRecordingDuration();
      AppLogger.info('Recording resumed');
    } catch (e) {
      AppLogger.error('Error resuming recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder!.stopRecorder();
      setState(() {
        _isRecording = false;
        _isPaused = false;
        _audioPath = path;
      });
      AppLogger.info('Recording stopped: $path');
    } catch (e) {
      AppLogger.error('Error stopping recording: $e');
    }
  }

  Future<void> _playRecording() async {
    if (_audioPath == null || !_playerInitialized) return;

    try {
      await _audioPlayer!.startPlayer(
        fromURI: _audioPath,
        codec: Codec.aacADTS,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
            _playbackPosition = Duration.zero;
          });
        },
      );
      setState(() => _isPlaying = true);
      AppLogger.info('Playing recording');
    } catch (e) {
      AppLogger.error('Error playing recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pausePlayback() async {
    try {
      await _audioPlayer!.pausePlayer();
      setState(() => _isPlaying = false);
      AppLogger.info('Playback paused');
    } catch (e) {
      AppLogger.error('Error pausing playback: $e');
    }
  }

  Future<void> _stopPlayback() async {
    try {
      await _audioPlayer!.stopPlayer();
      setState(() {
        _isPlaying = false;
        _playbackPosition = Duration.zero;
      });
      AppLogger.info('Playback stopped');
    } catch (e) {
      AppLogger.error('Error stopping playback: $e');
    }
  }

  void _deleteRecording() {
    setState(() {
      _audioPath = null;
      _recordingDuration = Duration.zero;
      _playbackPosition = Duration.zero;
      _totalDuration = Duration.zero;
    });
  }

  Future<String> _convertAudioToBase64() async {
    if (_audioPath == null) return '';
    try {
      File audioFile = File(_audioPath!);
      List<int> audioBytes = await audioFile.readAsBytes();
      return base64Encode(audioBytes);
    } catch (e) {
      AppLogger.error('Error converting audio to base64: $e');
      return '';
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_audioPath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please record your order first'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    } else if (_currentStep == 1) {
      // Validate address selection
      if (_selectedAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a delivery address'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitOrder() async {
    // if (!_formKey.currentState!.validate() || _audioPath == null) {
    //   return;
    // }
    if (_audioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No recording available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedAddress?.addressId == null ||
        _selectedAddress!.addressId!.isEmpty) {
      AppLogger.error('❌ Selected address has no ID!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Invalid address selected. Please select another address.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final orderService = OrderService();
      final audioFile = File(_audioPath!);

      final orderRequest = CreateOrderRequest(
        customerId: widget.customerId,
        customerAddressId: _selectedAddress!.addressId!,
        orderType: _orderType == 'prescription'
            ? OrderType.prescriptionDrugs
            : OrderType.otc,
        orderInputType: OrderInputType.voice,
        orderInputFile: audioFile,
        orderInputText: null,
        orderInputFileLocation: null,
      );

      AppLogger.info('📤 Submitting voice order...');
      AppLogger.info('Customer ID: ${widget.customerId}');
      AppLogger.info('Address ID: ${_selectedAddress!.addressId}');
      AppLogger.info(
          'Recording Duration: ${_formatDuration(_recordingDuration)}');

      final createdOrder = await orderService.createOrder(orderRequest);

      AppLogger.info('✅ Order created! ID: ${createdOrder.orderId}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice order submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } on OrderValidationException catch (e) {
      AppLogger.error('Validation error: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Validation Error: ${e.message}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } on OrderNetworkException catch (e) {
      AppLogger.error('Network error: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network Error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Error submitting order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Order'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Step Progress Indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            color: Colors.grey.shade50,
            child: StepProgressIndicator(
              steps: _steps,
              currentStep: _currentStep,
              activeColor: Colors.black,
            ),
          ),

          // Step Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(),
            ),
          ),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildRecordStep();
      case 1:
        return _buildDetailsStep();
      case 2:
        return _buildReviewStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildRecordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Voice Order',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Record your medicine order or prescription details',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 30),

        // Recording Status Card
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.shade50,
                  Colors.orange.shade100,
                ],
              ),
            ),
            child: Column(
              children: [
                // Microphone Icon with Animation
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording
                        ? Colors.red.shade100
                        : Colors.orange.shade200,
                    boxShadow: _isRecording
                        ? [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.mic,
                    size: 60,
                    color: _isRecording ? Colors.red : Colors.black,
                  ),
                ),

                const SizedBox(height: 24),

                // Recording Status
                Text(
                  _isRecording
                      ? (_isPaused ? 'Recording Paused' : 'Recording...')
                      : (_audioPath != null
                          ? 'Recording Complete'
                          : 'Ready to Record'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),

                const SizedBox(height: 12),

                // Duration Display
                Text(
                  _formatDuration(_recordingDuration),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 24),

                // Recording Controls
                if (!_recorderInitialized)
                  const CircularProgressIndicator(color: Colors.black)
                else if (!_isRecording && _audioPath == null)
                  ElevatedButton.icon(
                    onPressed: _startRecording,
                    icon: const Icon(Icons.fiber_manual_record),
                    label: const Text('Start Recording'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),

                if (_isRecording) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pause/Resume Button
                      ElevatedButton.icon(
                        onPressed:
                            _isPaused ? _resumeRecording : _pauseRecording,
                        icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                        label: Text(_isPaused ? 'Resume' : 'Pause'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Stop Button
                      ElevatedButton.icon(
                        onPressed: _stopRecording,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),

        // Playback Section
        if (_audioPath != null && !_isRecording) ...[
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.audiotrack, color: Colors.black),
                      const SizedBox(width: 8),
                      const Text(
                        'Your Recording',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Playback Progress
                  Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.orange,
                          inactiveTrackColor: Colors.orange.shade100,
                          thumbColor: Colors.orange,
                          overlayColor: Colors.orange.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: _totalDuration.inMilliseconds > 0
                              ? _playbackPosition.inMilliseconds /
                                  _totalDuration.inMilliseconds
                              : 0.0,
                          onChanged: (value) async {
                            if (_playerInitialized) {
                              final position = _totalDuration * value;
                              await _audioPlayer!.seekToPlayer(position);
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_playbackPosition),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              _formatDuration(_totalDuration),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Playback Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _isPlaying ? _pausePlayback : _playRecording,
                        icon: Icon(
                          _isPlaying ? Icons.pause_circle : Icons.play_circle,
                          size: 48,
                        ),
                        color: Colors.black,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: _stopPlayback,
                        icon: const Icon(Icons.stop_circle, size: 48),
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Recording'),
                              content: const Text(
                                'Are you sure you want to delete this recording?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _deleteRecording();
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete, size: 40),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Tips
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Tips for clear recording',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTipItem('Speak clearly and at normal pace'),
              _buildTipItem('Mention medicine names carefully'),
              _buildTipItem('Include dosage and quantity'),
              _buildTipItem('Record in a quiet environment'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Order Details',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Provide additional information for your order',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 30),

          // Order Type
          const Text(
            'Order Type',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          RadioListTile<String>(
            title: const Text('Prescription Medicines'),
            subtitle: const Text('Medicines requiring prescription'),
            value: 'prescription',
            groupValue: _orderType,
            activeColor: Colors.black,
            onChanged: (value) {
              setState(() => _orderType = value!);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(height: 8),
          RadioListTile<String>(
            title: const Text('OTC Medicines'),
            subtitle: const Text('Over-the-counter medicines'),
            value: 'otc',
            groupValue: _orderType,
            activeColor: Colors.black,
            onChanged: (value) {
              setState(() => _orderType = value!);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(height: 24),

          // Patient Name
          TextFormField(
            controller: _patientNameController,
            decoration: InputDecoration(
              labelText: 'Patient Name',
              prefixIcon: const Icon(Icons.person, color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
            ),
            validator: (value) {
              // if (value == null || value.isEmpty) {
              //   return 'Please enter patient name';
              // }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Phone Number
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            decoration: InputDecoration(
              labelText: 'Contact Number',
              prefixIcon: const Icon(Icons.phone, color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
              counterText: '',
            ),
            validator: (value) {
                // if (value == null || value.isEmpty) {
                //   return 'Please enter contact number';
                // }
              if ((value != null && value.isNotEmpty ) && value.length != 10) {
                return 'Please enter a valid 10-digit number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Notes
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Additional Notes (Optional)',
              prefixIcon: const Icon(Icons.note, color: Colors.black),
              hintText: 'Any specific instructions...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          const SizedBox(height: 24),

// Address Selection
          const Text(
            'Delivery Address',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          AddressSelectorWidget(
            customerId: widget.customerId,
            onAddressSelected: (address) {
              setState(() => _selectedAddress = address);
            },
            themeColor: Colors.black,
          ),

          const SizedBox(height: 24),
          // Delivery Type
          const Text(
            'Delivery Type',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Home'),
                  subtitle: const Text('Deliver to home'),
                  value: 'home',
                  groupValue: _deliveryType,
                  activeColor: Colors.black,
                  onChanged: (value) {
                    setState(() => _deliveryType = value!);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Pickup'),
                  subtitle: const Text('Store pickup'),
                  value: 'pickup',
                  groupValue: _deliveryType,
                  activeColor: Colors.black,
                  onChanged: (value) {
                    setState(() => _deliveryType = value!);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Urgency
          const Text(
            'Urgency',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Regular'),
                  subtitle: const Text('1-2 days'),
                  value: 'regular',
                  groupValue: _urgency,
                  activeColor: Colors.black,
                  onChanged: (value) {
                    setState(() => _urgency = value!);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Urgent'),
                  subtitle: const Text('Same day'),
                  value: 'urgent',
                  groupValue: _urgency,
                  activeColor: Colors.black,
                  onChanged: (value) {
                    setState(() => _urgency = value!);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Review Order',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Please review your voice order before submitting',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 30),

        // Voice Recording
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.mic, color: Colors.black),
                    const SizedBox(width: 8),
                    const Text(
                      'Voice Recording',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    Icon(Icons.audiotrack, color: Colors.black, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Voice Order Recording',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Duration: ${_formatDuration(_recordingDuration)}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Order Type
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.medical_services, color: Colors.black),
                    const SizedBox(width: 8),
                    const Text(
                      'Order Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                _buildReviewRow(
                  'Category',
                  _orderType == 'prescription'
                      ? 'Prescription Medicines'
                      : 'OTC Medicines',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Patient Details
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.black),
                    const SizedBox(width: 8),
                    const Text(
                      'Patient Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                _buildReviewRow('Name', _patientNameController.text),
                _buildReviewRow('Phone', _phoneController.text),
                if (_notesController.text.isNotEmpty)
                  _buildReviewRow('Notes', _notesController.text),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

// Delivery Address Card
        if (_selectedAddress != null)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.black),
                      const SizedBox(width: 8),
                      const Text(
                        'Delivery Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  if (_selectedAddress!.address != null &&
                      _selectedAddress!.address!.isNotEmpty)
                    _buildReviewRow('Label', _selectedAddress!.address!),
                  _buildReviewRow('Address', _selectedAddress!.fullAddress),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Delivery Details
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_shipping, color: Colors.black),
                    const SizedBox(width: 8),
                    const Text(
                      'Delivery Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                _buildReviewRow(
                  'Type',
                  _deliveryType == 'home' ? 'Home Delivery' : 'Store Pickup',
                ),
                _buildReviewRow(
                  'Urgency',
                  _urgency == 'regular'
                      ? 'Regular (1-2 days)'
                      : 'Urgent (Same day)',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : (_currentStep == _steps.length - 1
                      ? _submitOrder
                      : _nextStep),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _currentStep == _steps.length - 1
                          ? 'Submit Order'
                          : 'Next',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
