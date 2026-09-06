/// The delivery destination carried inline on an order.
///
/// Mirrors the backend `OrderDeliveryAddressDto`, which every `/Orders` read now
/// embeds. Before that existed, each screen fetched the address itself with a
/// second hop (`GET /Orders/{id}` for the address id, then
/// `GET /CustomerAddresses/{id}`) — a round trip that simply 403s for chemists
/// and delivery partners, who hold neither `CustomerRead` nor `AllCustomerRead`.
/// Read [DeliveryAddressModel] off the order instead of re-fetching it.
class DeliveryAddressModel {
  final String? id;
  final String? address;
  final String? addressLine1;
  final String? addressLine2;
  final String? addressLine3;
  final String? city;
  final String? state;
  final String? postalCode;
  final double? latitude;
  final double? longitude;

  const DeliveryAddressModel({
    this.id,
    this.address,
    this.addressLine1,
    this.addressLine2,
    this.addressLine3,
    this.city,
    this.state,
    this.postalCode,
    this.latitude,
    this.longitude,
  });

  static String? _str(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  static double? _num(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  /// Reads either camelCase or PascalCase, since a few endpoints round-trip the
  /// address through raw JSON that keeps the .NET casing.
  static dynamic _get(Map<String, dynamic> json, String key) {
    if (json.containsKey(key)) return json[key];
    final pascal = key[0].toUpperCase() + key.substring(1);
    return json[pascal];
  }

  factory DeliveryAddressModel.fromJson(Map<String, dynamic> json) {
    return DeliveryAddressModel(
      id: _str(_get(json, 'id')),
      address: _str(_get(json, 'address')),
      addressLine1: _str(_get(json, 'addressLine1')),
      addressLine2: _str(_get(json, 'addressLine2')),
      addressLine3: _str(_get(json, 'addressLine3')),
      city: _str(_get(json, 'city')),
      state: _str(_get(json, 'state')),
      // `postalCode` is the backend's name for it; `pincode` is accepted because
      // some older client-side payloads spell it that way.
      postalCode: _str(_get(json, 'postalCode')) ?? _str(_get(json, 'pincode')),
      latitude: _num(_get(json, 'latitude')),
      longitude: _num(_get(json, 'longitude')),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'address': address,
        'addressLine1': addressLine1,
        'addressLine2': addressLine2,
        'addressLine3': addressLine3,
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'latitude': latitude,
        'longitude': longitude,
      };

  /// The street portion, one entry per line, in the order it should be read out.
  List<String> get streetLines => [address, addressLine1, addressLine2, addressLine3]
      .whereType<String>()
      .where((s) => s.isNotEmpty)
      .toList();

  /// "City, State - 411001" — whichever of the three are present.
  String get localityLine {
    final cityState =
        [city, state].whereType<String>().where((s) => s.isNotEmpty).join(', ');
    if (postalCode == null || postalCode!.isEmpty) return cityState;
    return cityState.isEmpty ? postalCode! : '$cityState - $postalCode';
  }

  /// Display lines for a multi-line address block.
  List<String> get displayLines {
    final lines = streetLines;
    final locality = localityLine;
    return locality.isEmpty ? lines : [...lines, locality];
  }

  /// The whole address on one line, for list tiles and single-row layouts.
  String get singleLine => displayLines.join(', ');

  /// True when there is nothing worth rendering.
  bool get isEmpty => displayLines.isEmpty;
  bool get isNotEmpty => !isEmpty;

  /// True when the address can be handed to a maps app for navigation.
  bool get hasCoordinates => latitude != null && longitude != null;
}
