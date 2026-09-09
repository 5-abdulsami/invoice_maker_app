import 'package:flutter/foundation.dart';
import 'package:invoicemaker/data/models/client.dart';

/// The client list plus whichever client the current invoice bills.
class ClientProvider extends ChangeNotifier {
  final List<Client> _clients = [];
  Client? _selected;

  List<Client> get clients => List.unmodifiable(_clients);

  /// The client chosen for the invoice being edited, if any.
  Client? get selectedClient => _selected;

  /// The selected client, or an empty one so callers never handle null.
  Client get client => _selected ?? Client.empty();

  bool get hasClients => _clients.isNotEmpty;

  void addClient(Client client) {
    _clients.add(client);
    notifyListeners();
  }

  void updateClient(Client client) {
    final index = _clients.indexWhere((current) => current.id == client.id);
    if (index == -1) return;
    _clients[index] = client;
    if (_selected?.id == client.id) _selected = client;
    notifyListeners();
  }

  void removeClient(Client client) {
    final removed = _clients.remove(client);
    if (!removed) return;
    if (_selected?.id == client.id) _selected = null;
    notifyListeners();
  }

  void clearClients() {
    if (_clients.isEmpty) return;
    _clients.clear();
    _selected = null;
    notifyListeners();
  }

  /// Marks [clientId] as the chosen client and clears the previous choice.
  void selectClient(String clientId) {
    var found = false;
    for (var i = 0; i < _clients.length; i++) {
      final isMatch = _clients[i].id == clientId;
      if (isMatch) found = true;
      if (_clients[i].isSelected != isMatch) {
        _clients[i] = _clients[i].copyWith(isSelected: isMatch);
      }
    }
    _selected = found
        ? _clients.firstWhere((client) => client.id == clientId)
        : null;
    notifyListeners();
  }

  void clearSelection() {
    for (var i = 0; i < _clients.length; i++) {
      if (_clients[i].isSelected) {
        _clients[i] = _clients[i].copyWith(isSelected: false);
      }
    }
    _selected = null;
    notifyListeners();
  }

  Client? getClientById(String id) {
    final index = _clients.indexWhere((client) => client.id == id);
    return index == -1 ? null : _clients[index];
  }

  /// Clients whose name, email or phone contains [query].
  List<Client> search(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return clients;

    return _clients
        .where((client) =>
            client.name.toLowerCase().contains(trimmed) ||
            client.emailAddress.toLowerCase().contains(trimmed) ||
            client.phone.contains(trimmed))
        .toList(growable: false);
  }
}
