import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_midi_pro/flutter_midi_pro.dart';

Map<String, int> instrumentIdMap = {
  "grand" : 2,
  "e piano" : 4,
  "strings" : 49,
  "bass" : 39,
  "trumpet" : 56,
  "guitar" : 24,
};

class MidiController {
  final MidiPro _midi = MidiPro();
  int _soundfontId = 0;
  String path = 'assets/soundfonts/GeneralUser-GS.sf2';

   final int _channel1 = 0;
   final int _channel2 = 1;

   final int _bank = 0;

   late int _program1 = 2;
   late int _program2 = 2;
   final int _velocity = 46;

  bool _isInitialized = false;

  final Set<int> _activeNotes = {};

  final Map<int, Timer?> noteTimers = {};

  Duration sustainDuration = Duration(milliseconds: 500);

  int splitPoint = 65;

  bool isDualModeActive = false;

  final Set<int> _pressedKeys = {};


  

  Future<int> loadFont() async {
    if (!_isInitialized) {
      try {
        debugPrint('Loading soundfont file: $path');
        _soundfontId = await _midi.loadSoundfont(path: 'assets/soundfonts/GeneralUser-GS.sf2', bank: _bank, program: _program1);
        debugPrint('Loaded soundfont file: $path with ID: $_soundfontId');
        _isInitialized = true;
      } catch (e) {
        debugPrint('Error loading soundfont file: $path: $e');
        rethrow;
      }
    }

    return _soundfontId;
  }
  
  Future<void> selectInstrument(String instrument) async {
    if (_soundfontId <= 0) await loadFont();

    if (!isDualModeActive) {
      // Single instrument mode - use the same instrument for both channels
      _program1 = instrumentIdMap[instrument] ?? _program1;
      _program2 = _program1;
      await _midi.selectInstrument(sfId: _soundfontId, channel: _channel1, bank: _bank, program: _program1);
      await _midi.selectInstrument(sfId: _soundfontId, channel: _channel2, bank: _bank, program: _program2);
    } else {

    }

  }

  // Method to update instruments for dual mode
  Future<void> updateDualModeInstruments(List<String> instruments) async {
    if (_soundfontId <= 0) await loadFont();
    
    if (instruments.length >= 1) {
      _program1 = instrumentIdMap[instruments[0]] ?? _program1;
      await _midi.selectInstrument(sfId: _soundfontId, channel: _channel1, bank: _bank, program: _program1);
    }
    
    if (instruments.length >= 2) {
      _program2 = instrumentIdMap[instruments[1]] ?? _program2;
      await _midi.selectInstrument(sfId: _soundfontId, channel: _channel2, bank: _bank, program: _program2);
    }
  }

    // Set dual mode state
  void setDualMode(bool isDualMode) {
    isDualModeActive = isDualMode;
  }

  
  Future<void> playNote(int key) async {
    try {
      _pressedKeys.add(key);

      print("key ${key} has been pressed");

      if (_soundfontId <= 0) {
        await loadFont();
      }
      noteTimers[key]?.cancel(); 

      int channelToUse;

      if (isDualModeActive){
        channelToUse = key < splitPoint ? _channel1 : _channel2;
      } else {
        channelToUse = _channel1;
      }


      await _midi.playNote(channel: channelToUse, key: key, velocity: _velocity, sfId: _soundfontId);
      _activeNotes.add(key);

      noteTimers[key] = Timer(sustainDuration, () => stopNote(key));
      
    } catch (e) {
      debugPrint('Error playing note: $e');
    }
  }

  
  Future<void> stopNote(int key) async {
    try {
      _pressedKeys.remove(key);
      print("key ${key} has been unpressed");

      if (_soundfontId <= 0 || !_activeNotes.contains(key)) return;

      int channelToUse;

      if (isDualModeActive){
        channelToUse = key < splitPoint ? _channel1 : _channel2;
      } else {
        channelToUse = _channel1;
      }
      
      await _midi.stopNote(channel: channelToUse, key: key, sfId: _soundfontId);
      _activeNotes.remove(key);


    } catch (e) {
      debugPrint('Error stopping note: $e');
    }
  }

  bool isKeyPressed(int key){
    return _pressedKeys.contains(key);
  }

  void dispose() {
    noteTimers.forEach((key, timer) => timer?.cancel());
    noteTimers.clear();
  }
}






