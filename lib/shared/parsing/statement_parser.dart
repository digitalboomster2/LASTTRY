import 'dart:math';

class ParsedStatementResult {
  final Map<String, dynamic> summary;
  final double confidence;

  ParsedStatementResult(this.summary, this.confidence);
}

abstract class StatementAdapter {
  ParsedStatementResult parse(String text);
}

class CsvAdapter implements StatementAdapter {
  @override
  ParsedStatementResult parse(String text) {
    // Detect CSV quickly
    final firstLine = text.split('\n').firstOrNull ?? '';
    final looksCsv = firstLine.contains(',') || firstLine.contains(';');
    if (!looksCsv) return ParsedStatementResult({'income': 0.0, 'expenses': 0.0, 'savings': 0.0, 'categories': <String, double>{}}, 0.0);

    final lines = text.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return ParsedStatementResult({'income': 0.0, 'expenses': 0.0, 'savings': 0.0, 'categories': <String, double>{}}, 0.0);

    final sep = firstLine.contains(';') ? ';' : ',';
    final header = lines.first.split(sep).map((h) => h.trim().toLowerCase()).toList();
    final idxDesc = header.indexWhere((h) => h.contains('desc'));
    final idxIn = header.indexWhere((h) => h.contains('inflow') || h.contains('credit'));
    final idxOut = header.indexWhere((h) => h.contains('outflow') || h.contains('debit'));
    final idxBal = header.indexWhere((h) => h.contains('bal'));

    num inflow = 0, outflow = 0, opening = 0, closing = 0;
    final categories = <String, num>{};

    for (int i = 1; i < lines.length; i++) {
      final cols = lines[i].split(sep);
      if (cols.length < 2) continue;
      String desc = idxDesc >= 0 && idxDesc < cols.length ? cols[idxDesc] : '';
      num inc = idxIn >= 0 && idxIn < cols.length ? _parseAmount(cols[idxIn]) : 0;
      num out = idxOut >= 0 && idxOut < cols.length ? _parseAmount(cols[idxOut]) : 0;
      num bal = idxBal >= 0 && idxBal < cols.length ? _parseAmount(cols[idxBal]) : 0;
      if (i == 1) opening = bal;
      closing = bal == 0 ? closing : bal;
      inflow += inc;
      outflow += out;
      _classifyToCategories(desc, (inc > 0) ? inc : out, categories);
    }

    final savings = inflow - outflow;
    final summary = <String, dynamic>{
      'income': inflow.toDouble(),
      'expenses': outflow.toDouble(),
      'savings': savings.toDouble(),
      'categories': categories.map((k, v) => MapEntry(k, (v as num).toDouble())),
      'openingBalance': opening.toDouble(),
      'closingBalance': closing.toDouble(),
    };
    final conf = lines.length > 5 ? 0.8 : 0.5;
    return ParsedStatementResult(summary, conf);
  }

  num _parseAmount(String s) {
    final clean = s.replaceAll(',', '').replaceAll('₦', '').trim();
    if (clean.isEmpty) return 0;
    return double.tryParse(clean) ?? 0;
  }

  void _classifyToCategories(String desc, num amount, Map<String, num> cats) {
    final lower = desc.toLowerCase();
    void add(String k) => cats[k] = (cats[k] ?? 0) + amount;
    if (lower.contains('chowdeck') || lower.contains('amala') || lower.contains('restaurant') || lower.contains('food') || lower.contains('grocery')) {
      add('food');
    } else if (lower.contains('uber') || lower.contains('fuel') || lower.contains('car') || lower.contains('transport')) {
      add('transport');
    } else if (lower.contains('power') || lower.contains('electric') || lower.contains('utility') || lower.contains('internet') || lower.contains('data')) {
      add('utilities');
    } else if (lower.contains('sms alert') || lower.contains('nip-fee') || lower.contains('nip/fee') || lower.contains('vat-fee') || lower.contains('vat')) {
      add('fees');
    } else {
      add('other');
    }
  }
}

/// Generic text adapter that attempts to parse common bank statement rows
class GenericTextAdapter implements StatementAdapter {
  @override
  ParsedStatementResult parse(String text) {
    final lines = text.split(RegExp(r'\n|=== PAGE'));
    num openingBalance = 0;
    num closingBalance = 0;
    num totalInflow = 0;
    num totalOutflow = 0;
    final categories = <String, num>{};

    final balanceRegex = RegExp(r'BALANCE[^\d]*([\d,]+\.\d{2})', caseSensitive: false);
    bool sawFirstBalance = false;
    int txnCount = 0;
    bool headerSeen = false;

    for (final raw in lines) {
      final line = raw.replaceAll('\r', ' ').trim();
      if (line.isEmpty) continue;

      final lower = line.toLowerCase();
      if (!headerSeen && lower.contains('outflow') && lower.contains('inflow') && lower.contains('balance')) {
        headerSeen = true;
        continue;
      }

      final balMatch = balanceRegex.firstMatch(line);
      if (balMatch != null) {
        final value = _parseAmount(balMatch.group(1)!);
        if (!sawFirstBalance) {
          openingBalance = value;
          sawFirstBalance = true;
        }
        closingBalance = value;
      }

      if (headerSeen) {
        final nums = RegExp(r'([\d,]+\.\d{2})').allMatches(line).map((m) => m.group(1)!).toList();
        if (nums.length >= 3) {
          txnCount++;
          final outStr = nums[nums.length - 3];
          final inStr = nums[nums.length - 2];
          final balStr = nums[nums.length - 1];
          final out = _parseAmount(outStr);
          final inc = _parseAmount(inStr);
          final bal = _parseAmount(balStr);
          totalOutflow += out;
          totalInflow += inc;
          if (!sawFirstBalance && bal > 0) {
            openingBalance = bal;
            sawFirstBalance = true;
          }
          if (bal > 0) closingBalance = bal;

          void addCat(String k, num amt) {
            categories[k] = (categories[k] ?? 0) + amt;
          }
          final amt = out; // expenses only
          if (amt > 0) {
            if (lower.contains('chowdeck') || lower.contains('amala') || lower.contains('restaurant') || lower.contains('food') || lower.contains('grocery')) {
              addCat('food', amt);
            } else if (lower.contains('uber') || lower.contains('pos fuel') || lower.contains('fuel') || lower.contains('car') || lower.contains('transport')) {
              addCat('transport', amt);
            } else if (lower.contains('power') || lower.contains('electric') || lower.contains('utility') || lower.contains('internet') || lower.contains('data')) {
              addCat('utilities', amt);
            } else if (lower.contains('sms alert') || lower.contains('nip-fee') || lower.contains('nip/fee') || lower.contains('vat-fee') || lower.contains('vat')) {
              addCat('fees', amt);
            } else {
              addCat('other', amt);
            }
          }
        }
        continue;
      }
    }

    final savings = totalInflow - totalOutflow;
    final summary = <String, dynamic>{
      'income': totalInflow.toDouble(),
      'expenses': totalOutflow.toDouble(),
      'savings': savings.toDouble(),
      'categories': categories.map((k, v) => MapEntry(k, (v as num).toDouble())),
      'openingBalance': openingBalance.toDouble(),
      'closingBalance': closingBalance.toDouble(),
    };

    final conf = min(0.95, max(0.3, txnCount / 50));
    return ParsedStatementResult(summary, conf);
  }

  num _parseAmount(String amountStr) {
    final cleanStr = amountStr.replaceAll(',', '');
    try {
      return double.parse(cleanStr);
    } catch (_) {
      return 0;
    }
  }
}

class StatementParser {
  final List<StatementAdapter> _adapters = [CsvAdapter(), GenericTextAdapter()];

  Map<String, dynamic> parse(String text) {
    ParsedStatementResult? best;
    for (final a in _adapters) {
      final r = a.parse(text);
      if (best == null || r.confidence > best!.confidence) best = r;
    }
    return best?.summary ?? {'income': 0.0, 'expenses': 0.0, 'savings': 0.0, 'categories': <String, double>{}};
  }
}


