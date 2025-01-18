import 'package:flutter/foundation.dart';
import 'package:invoicemaker/model/client_model.dart';

class ClientProvider extends ChangeNotifier {
  Client _client = Client(
    id: DateTime.now().toIso8601String(),
    name: 'Unknown Client',
    emailAddress: '',
    phone: '',
    billingAddress: '',
    shippingAddress: '',
    detail: '',
  );

  Client get client => _client;

  List<Client> _clients = []; // List to hold clients
  List<Client> get clients => _clients;

  void setName(String name) {
    _client = _client.copyWith(name: name);
    notifyListeners();
  }

  void setEmailAddress(String emailAddress) {
    _client = _client.copyWith(emailAddress: emailAddress);
    notifyListeners();
  }

  void setPhone(String phone) {
    _client = _client.copyWith(phone: phone);
    notifyListeners();
  }

  void setBillingAddress(String billingAddress) {
    _client = _client.copyWith(billingAddress: billingAddress);
    notifyListeners();
  }

  void setShippingAddress(String shippingAddress) {
    _client = _client.copyWith(shippingAddress: shippingAddress);
    notifyListeners();
  }

  void setDetail(String detail) {
    _client = _client.copyWith(detail: detail);
    notifyListeners();
  }

  void setClient(Client client) {
    _client = client;
    notifyListeners();
  }

  void addClient(Client client) {
    _clients.add(client);
    notifyListeners();
  }

  void removeClient(Client client) {
    _clients.remove(client);
    notifyListeners();
  }

  // void selectClient(String clientId) {
  //   _clients = _clients.map((client) {
  //     if (client.id == clientId) {
  //       return client.copyWith(isSelected: true);
  //     } else {
  //       return client.copyWith(isSelected: false);
  //     }
  //   }).toList();
  //   notifyListeners();
  // }
}
