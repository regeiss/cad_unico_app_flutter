class User {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final bool isStaff;
  final bool isActive;
  final DateTime? dateJoined;
  final String? token; // Nova propriedade token
  final String? refreshToken; // Token de refresh opcional

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.isStaff = false,
    this.isActive = true,
    this.dateJoined,
    this.token,
    this.refreshToken,
  });

  /// Retorna o nome completo do usuário
  String get fullName {
    if (firstName == null && lastName == null) {
      return username;
    }
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }

  /// Verifica se o usuário está autenticado (tem token)
  bool get isAuthenticated => token != null && token!.isNotEmpty;

  /// Retorna as iniciais do usuário
  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    }
    if (firstName != null && firstName!.isNotEmpty) {
      return firstName![0].toUpperCase();
    }
    return username.isNotEmpty ? username[0].toUpperCase() : '?';
  }

  /// Cria uma cópia do modelo com novos valores
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    bool? isStaff,
    bool? isActive,
    DateTime? dateJoined,
    String? token,
    String? refreshToken,
  }) =>
      User(
        id: id ?? this.id,
        username: username ?? this.username,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        isStaff: isStaff ?? this.isStaff,
        isActive: isActive ?? this.isActive,
        dateJoined: dateJoined ?? this.dateJoined,
        token: token ?? this.token,
        refreshToken: refreshToken ?? this.refreshToken,
      );

  /// Cria um modelo sem token (para logout)
  User withoutToken() => copyWith(
        token: null,
        refreshToken: null,
      );

  /// Atualiza apenas o token
  User withToken(String newToken, {String? newRefreshToken}) => copyWith(
        token: newToken,
        refreshToken: newRefreshToken ?? refreshToken,
      );

  /// Converte o modelo para JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'is_staff': isStaff,
        'is_active': isActive,
        'date_joined': dateJoined?.toIso8601String(),
        'token': token,
        'refresh_token': refreshToken,
      };

  /// Cria um modelo a partir do JSON
  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        username: json['username'] as String,
        email: json['email'] as String,
        firstName: json['first_name'] as String?,
        lastName: json['last_name'] as String?,
        isStaff: json['is_staff'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? true,
        dateJoined: json['date_joined'] != null
            ? DateTime.parse(json['date_joined'] as String)
            : null,
        token: json['token'] as String?,
        refreshToken: json['refresh_token'] as String?,
      );

  /// Cria um modelo a partir da resposta de login da API
  factory User.fromLoginResponse(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? json;
    final token = json['token'] as String?;
    final refreshToken = json['refresh'] as String?;

    return User(
      id: userJson['id'] as int,
      username: userJson['username'] as String,
      email: userJson['email'] as String,
      firstName: userJson['first_name'] as String?,
      lastName: userJson['last_name'] as String?,
      isStaff: userJson['is_staff'] as bool? ?? false,
      isActive: userJson['is_active'] as bool? ?? true,
      dateJoined: userJson['date_joined'] != null
          ? DateTime.parse(userJson['date_joined'] as String)
          : null,
      token: token,
      refreshToken: refreshToken,
    );
  }

  /// Converte para JSON para armazenamento local
  Map<String, dynamic> toStorageJson() => {
        'id': id,
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'is_staff': isStaff,
        'is_active': isActive,
        'date_joined': dateJoined?.toIso8601String(),
        'token': token,
        'refresh_token': refreshToken,
      };

  /// Cria um modelo a partir do JSON do armazenamento local
  factory User.fromStorageJson(Map<String, dynamic> json) =>
      User.fromJson(json);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.isStaff == isStaff &&
        other.isActive == isActive &&
        other.dateJoined == dateJoined &&
        other.token == token &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode => Object.hash(
        id,
        username,
        email,
        firstName,
        lastName,
        isStaff,
        isActive,
        dateJoined,
        token,
        refreshToken,
      );

  @override
  String toString() => 'UserModel('
      'id: $id, '
      'username: $username, '
      'email: $email, '
      'firstName: $firstName, '
      'lastName: $lastName, '
      'isStaff: $isStaff, '
      'isActive: $isActive, '
      'dateJoined: $dateJoined, '
      'hasToken: ${token != null}, '
      'hasRefreshToken: ${refreshToken != null}'
      ')';
}
