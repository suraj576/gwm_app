// to check string contains digits only

bool isNumeric(String s) {
  if (s == null) {
  return false;
  }
  
  return int.tryParse(s) != null;
}