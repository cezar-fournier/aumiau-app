import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:aumiau_app/services/sync_gateway.dart';

void main() {
  const token = 'token-de-teste';

  test('cliente cria e lista agendamentos autenticados', () async {
    final requests = <http.Request>[];
    final gateway = HttpSyncGateway(
      baseUri: Uri.parse('https://api.example.test/'),
      client: MockClient((request) async {
        requests.add(request);
        if (request.method == 'POST') {
          return http.Response(
            jsonEncode({
              'id': 42,
              'status': 'requested',
              'createdAt': '2026-08-02T01:00:00Z',
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'appointments': [
              {'id': 42, 'status': 'requested'},
            ],
          }),
          200,
        );
      }),
    );

    final created = await gateway.createAppointment(
      accessToken: token,
      partnerId: 7,
      petId: '3',
      petName: 'Luna',
      service: 'Consulta',
      scheduledAt: DateTime.utc(2026, 8, 3, 10),
    );
    final listed = await gateway.loadAppointments(accessToken: token);

    expect(created['id'], 42);
    expect(listed.single['status'], 'requested');
    expect(requests[0].method, 'POST');
    expect(requests[0].url.path, '/appointments');
    expect(requests[1].method, 'GET');
    expect(requests[1].headers['authorization'], 'Bearer $token');
    expect(jsonDecode(requests[0].body)['partnerId'], 7);
  });

  test('parceiro lista e atualiza somente pela rota própria', () async {
    final requests = <http.Request>[];
    final gateway = HttpSyncGateway(
      baseUri: Uri.parse('https://api.example.test/'),
      client: MockClient((request) async {
        requests.add(request);
        if (request.method == 'PATCH') {
          return http.Response(
            jsonEncode({'id': 9, 'status': 'confirmed'}),
            200,
          );
        }
        return http.Response(jsonEncode({'appointments': []}), 200);
      }),
    );

    await gateway.loadPartnerAppointments(accessToken: token);
    final updated = await gateway.updatePartnerAppointmentStatus(
      accessToken: token,
      appointmentId: 9,
      status: 'confirmed',
    );

    expect(requests[0].url.path, '/partner/appointments');
    expect(requests[1].method, 'PATCH');
    expect(requests[1].url.path, '/partner/appointments/9/status');
    expect(updated['status'], 'confirmed');
  });

  test('erros de conflito e limite preservam status e mensagem', () async {
    var status = 409;
    final gateway = HttpSyncGateway(
      baseUri: Uri.parse('https://api.example.test/'),
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'detail': status == 409 ? 'Transição inválida.' : 'Aguarde.',
          }),
          status,
        ),
      ),
    );

    await expectLater(
      gateway.updateAppointmentStatus(
        accessToken: token,
        appointmentId: 1,
        status: 'completed',
      ),
      throwsA(
        isA<SyncGatewayException>()
            .having((error) => error.statusCode, 'statusCode', 409)
            .having((error) => error.message, 'message', 'Transição inválida.'),
      ),
    );

    status = 429;
    await expectLater(
      gateway.updateAppointmentStatus(
        accessToken: token,
        appointmentId: 1,
        status: 'cancelled',
      ),
      throwsA(
        isA<SyncGatewayException>().having(
          (error) => error.statusCode,
          'statusCode',
          429,
        ),
      ),
    );
  });
}
