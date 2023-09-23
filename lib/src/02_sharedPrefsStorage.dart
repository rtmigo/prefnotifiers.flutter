// Copyright (c) 2021 Artёm Galkin <github.com/rtmigo>. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause license found
// in the LICENSE file in the root directory of this source tree

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '01_prefsStorage.dart';
import '02_ramPrefsStorage.dart';

/// A [PrefsStorage] that stores the data in platform-dependent [SharedPreferences].
class SharedPrefsStorage extends PrefsStorage {
  final Future<SharedPreferences> sp = SharedPreferences.getInstance();

  @override
  Future<String?> getString(String key) async => (await this.sp).getString(key);

  @override
  Future<bool?> getBool(String key) async => (await this.sp).getBool(key);

  @override
  Future<int?> getInt(String key) async => (await this.sp).getInt(key);

  @override
  Future<double?> getDouble(String key) async => (await this.sp).getDouble(key);

  @override
  Future<List<String>?> getStringList(String key) async =>
      (await this.sp).getStringList(key);

  Future<void> _setOrRemove<T>(
      String key,
      T? value,
      Future<void> Function(SharedPreferences, String, T) setFunc)
  async {
    SharedPreferences sps = await this.sp;
    if (value!=null) {
      //print("REALLY SETTING $value");
      await setFunc(sps, key, value);
      //print("AFTER SET ${(await SharedPreferences.getInstance()).getString(key)}");
    } else {
      await sps.remove(key);
    }
  }

  @override
  Future<void> setString(String key, String? value)
  => _setOrRemove<String>(key, value, (sps, k, v) => sps.setString(k, v));

  @override
  Future<void> setDouble(String key, double? value)
  => _setOrRemove<double>(key, value, (sps, k, v) => sps.setDouble(k, v));

  @override
  Future<void> setInt(String key, int? value)
  => _setOrRemove<int>(key, value, (sps, k, v) => sps.setInt(k, v));

  @override
  Future<void> setBool(String key, bool? value)
  => _setOrRemove<bool>(key, value, (sps, k, v) => sps.setBool(k, v));

  @override
  Future<void> setStringList(String key, List<String>? value)
  => _setOrRemove<List<String>>(key, value, (sps, k, v) => sps.setStringList(k, v));

  @override
  Future<Set<String>> getKeys(String key) async => (await this.sp).getKeys();

  static Future<PrefsStorage> withTestingFallback() async {
    try {
      final result = SharedPrefsStorage();
      await result.sp;
      return result;
    } on MissingPluginException catch (_, __) {
      print('Using RamPrefsStorage instead of SharedPrefsStorage.');
      return RamPrefsStorage();
    }
  }
}
