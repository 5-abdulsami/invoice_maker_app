import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:invoicemaker/model/business_model.dart';

class BusinessProvider extends ChangeNotifier {
  Business _business = Business(
    businessLogo: null,
    businessName: '',
    emailAddress: '',
    phone: '',
    billingAddress: '',
    website: '',
  );

  Business get business => _business;

  void setBusinessLogo(File? logo) {
    _business = _business.copyWith(businessLogo: logo);
    notifyListeners();
  }

  void setBusinessName(String name) {
    _business = _business.copyWith(businessName: name);
    notifyListeners();
  }

  void setEmailAddress(String email) {
    _business = _business.copyWith(emailAddress: email);
    notifyListeners();
  }

  void setPhone(String phone) {
    _business = _business.copyWith(phone: phone);
    notifyListeners();
  }

  void setBillingAddress(String address) {
    _business = _business.copyWith(billingAddress: address);
    notifyListeners();
  }

  void setWebsite(String website) {
    _business = _business.copyWith(website: website);
    notifyListeners();
  }

  void setBusiness(Business business) {
    _business = business;
    notifyListeners();
  }
}
