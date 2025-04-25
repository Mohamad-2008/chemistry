enum SearchType {
  name,
  symbol,
  atomicNumber,
  atomicMass,
  category,
  phase,
  meltingPoint,
  boilingPoint,
}

extension SearchTypeExtension on SearchType {
  String get title {
    switch (this) {
      case SearchType.name:
        return 'نام';
      case SearchType.symbol:
        return 'نماد';
      case SearchType.atomicNumber:
        return 'عدد اتمی';
      case SearchType.atomicMass:
        return 'جرم اتمی';
      case SearchType.category:
        return 'دسته';
      case SearchType.phase:
        return 'فاز';
      case SearchType.meltingPoint:
        return 'نقطه ذوب';
      case SearchType.boilingPoint:
        return 'نقطه جوش';
    }
  }
} 