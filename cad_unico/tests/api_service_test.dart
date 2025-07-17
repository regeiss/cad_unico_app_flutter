// // test/services/api_service_test.dart

// import 'package:cadastro_app/services/api_service.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // Gere os mocks com: flutter pub run build_runner build
// import 'api_service_test.mocks.dart';

// @GenerateMocks([Dio, SharedPreferences])
// void main() {
//   late ApiService apiService;
//   late MockDio mockDio;
//   late MockSharedPreferences mockPrefs;

//   setUp(() {
//     mockDio = MockDio();
//     mockPrefs = MockSharedPreferences();
//     apiService = ApiService(dio: mockDio, prefs: mockPrefs);
//   });

//   group('getResponsavel', () {
//     final testCpf = '12345678901';
//     final testToken = 'test-token-123';
    
//     test('deve retornar responsável quando a requisição for bem-sucedida', () async {
//       // Arrange
//       final responseData = {
//         'cpf': testCpf,
//         'nome': 'João Silva',
//         'cep': '12345678',
//         'numero': 123,
//         'complemento': 'Apto 101',
//         'telefone': 11999999999,
//         'bairro': 'Centro',
//         'logradouro': 'Rua Principal',
//         'nome_mae': 'Maria Silva',
//         'data_nasc': '1990-01-01',
//         'timestamp': '2024-01-01T10:00:00Z',
//         'status': 'A',
//         'cod_rge': 12345,
//       };

//       when(mockPrefs.getString('auth_token')).thenReturn(testToken);
      
//       when(mockDio.get(
//         '/cadastro/api/responsaveis/$testCpf/',
//         options: anyNamed('options'),
//       )).thenAnswer((_) async => Response(
//         data: responseData,
//         statusCode: 200,
//         requestOptions: RequestOptions(path: ''),
//       ));

//       // Act
//       final result = await apiService.getResponsavel(testCpf);

//       // Assert
//       expect(result, isA<Map<String, dynamic>>());
//       expect(result['cpf'], equals(testCpf));
//       expect(result['nome'], equals('João Silva'));
//       expect(result['status'], equals('A'));
      
//       verify(mockDio.get(
//         '/cadastro/api/responsaveis/$testCpf/',
//         options: anyNamed('options'),
//       )).called(1);
//     });

//     test('deve retornar Responsavel tipado quando usar getResponsavelTipado', () async {
//       // Arrange
//       final responseData = {
//         'cpf': testCpf,
//         'nome': 'João Silva',
//         'cep': '12345678',
//         'numero': 123,
//         'status': 'A',
//       };

//       when(mockPrefs.getString('auth_token')).thenReturn(testToken);
      
//       when(mockDio.get(
//         '/cadastro/api/responsaveis/$testCpf/',
//         options: anyNamed('options'),
//       )).thenAnswer((_) async => Response(
//         data: responseData,
//         statusCode: 200,
//         requestOptions: RequestOptions(path: ''),
//       ));

//       // Act
//       final result = await apiService.getResponsavelTipado(testCpf);

//       // Assert
//       expect(result, isA<Responsavel>());
//       expect(result.cpf, equals(testCpf));
//       expect(result.nome, equals('João Silva'));
//       expect(result.isAtivo, isTrue);
//     });

//     test('deve lançar ApiException quando responsável não for encontrado', () async {
//       // Arrange
//       when(mockPrefs.getString('auth_token')).thenReturn(testToken);
      
//       when(mockDio.get(
//         '/cadastro/api/responsaveis/$testCpf/',
//         options: anyNamed('options'),
//       )).thenThrow(DioException(
//         response: Response(
//           statusCode: 404,
//           requestOptions: RequestOptions(path: ''),
//         ),
//         requestOptions: RequestOptions(path: ''),
//       ));

//       // Act & Assert
//       expect(
//         () => apiService.getResponsavel(testCpf),
//         throwsA(
//           isA<ApiException>()
//               .having((e) => e.message, 'message', 'Responsável não encontrado')
//               .having((e) => e.statusCode, 'statusCode', 404),
//         ),
//       );
//     });

//     test('deve lançar ApiException quando não autorizado', () async {
//       // Arrange
//       when(mockPrefs.getString('auth_token')).thenReturn(testToken);
      
//       when(mockDio.get(
//         '/cadastro/api/responsaveis/$testCpf/',
//         options: anyNamed('options'),
//       )).thenThrow(DioException(
//         response: Response(
//           statusCode: 401,
//           requestOptions: RequestOptions(path: ''),
//         ),
//         requestOptions: RequestOptions(path: ''),
//       ));

//       // Act & Assert
//       expect(
//         () => apiService.getResponsavel(testCpf),
//         throwsA(
//           isA<ApiException>()
//               .having((e) => e.message, 'message', 'Não autorizado. Faça login novamente.')
//               .having((e) => e.statusCode, 'statusCode', 401),
//         ),
//       );
//     });

//     test('deve funcionar sem token de autenticação', () async {
//       // Arrange
//       when(mockPrefs.getString('auth_token')).thenReturn(null);
      
//       final responseData = {'cpf': testCpf, 'nome': 'João Silva'};
      
//       when(mockDio.get(
//         '/cadastro/api/responsaveis/$testCpf/',
//         options: anyNamed('options'),
//       )).thenAnswer((_) async => Response(
//         data: responseData,
//         statusCode: 200,
//         requestOptions: RequestOptions(path: ''),
//       ));

//       // Act
//       final result = await apiService.getResponsavel(testCpf);

//       // Assert
//       expect(result['cpf'], equals(testCpf));
//     });
//   });

//   group('getResponsaveis com paginação', () {
//     test('deve retornar lista paginada de responsáveis', () async {
//       // Arrange
//       final responseData = {
//         'count': 50,
//         'next': 'http://api.example.com/responsaveis/?page=2',
//         'previous': null,
//         'results': [
//           {
//             'cpf': '12345678901',
//             'nome': 'João Silva',
//             'cep': '12345678',
//             'numero': 123,
//             'status': 'A',
//           },
//           {
//             'cpf': '98765432109',
//             'nome': 'Maria Santos',
//             'cep': '87654321',
//             'numero': 456,
//             'status': 'A',
//           },
//         ],
//       };

//       when(mockPrefs.getString('auth_token')).thenReturn('test-token');
      
//       when(mockDio.get(
//         '/cadastro/api/responsaveis/',
//         queryParameters: anyNamed('queryParameters'),
//         options: anyNamed('options'),
//       )).thenAnswer((_) async => Response(
//         data: responseData,
//         statusCode: 200,
//         requestOptions: RequestOptions(path: ''),
//       ));

//       // Act
//       final result = await apiService.getResponsaveis(
//         page: 1,
//         search: 'João',
//         status: 'A',
//       );

//       // Assert
//       expect(result.count, equals(50));
//       expect(result.hasNext, isTrue);
//       expect(result.hasPrevious, isFalse);
//       expect(result.results.length, equals(2));
//       expect(result.results[0].nome, equals('João Silva'));
//       expect(result.results[1].nome, equals('Maria Santos'));
//     });
//   });
// }