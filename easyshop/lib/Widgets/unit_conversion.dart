// method to get the unit based on category

String getUnit(String? category) {
  if (category == null) return 'kg';
  switch (category.toLowerCase()) {
    case "bakery":
      return "loaf";
    case 'vegetable':
      return 'kg';
    
    default:
      return 'kg';
  }
}