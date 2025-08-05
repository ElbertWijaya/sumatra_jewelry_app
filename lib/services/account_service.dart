import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/accounts.dart';

class AccountService {
  static Future<String?> getAccountNameById(int accountsId) async {
    final url = Uri.parse(
      'http://192.168.110.147/sumatra_api/get_accounts_by_id.php?accounts_id=${accountsId.toString()}',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResp = jsonDecode(response.body);
      if (jsonResp['success'] == true && jsonResp['data'] != null) {
        final account = Account.fromJson(jsonResp['data']);
        print('Account name fetched: ${account.accountsName}');
        return account.accountsName;
      }
    }
    return null;
  }

  static Future<Account?> getAccountById(int accountsId) async {
    final url = Uri.parse(
      'http://192.168.110.147/sumatra_api/get_accounts_by_id.php?accounts_id=${accountsId.toString()}',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResp = jsonDecode(response.body);
      if (jsonResp['success'] == true && jsonResp['data'] != null) {
        return Account.fromJson(jsonResp['data']);
      }
    }
    return null;
  }
}
