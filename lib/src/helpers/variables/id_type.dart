final List<IdentityCardType> idTypeList = [
  IdentityCardType("KTP"),
  IdentityCardType("PASSPORT"),
  IdentityCardType("KITAS"),
  // IdentityCardType(LanguageGlobalVar.TAX_CARD.tr)
];

class IdentityCardType {
  String name;
  IdentityCardType(this.name);
}