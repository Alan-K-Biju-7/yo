class AttendanceRecord {
  const AttendanceRecord(this.date, this.periods);

  final String date;
  final List<String> periods;
}

abstract final class AttendanceReferenceRepository {
  static const classCodes = ['2026S3CS-C', '2026S2CS-C', '2025S1CS-C'];

  static const recordsByClass = {
    '2026S3CS-C': [
      AttendanceRecord('07/01/2026', [
        '102802/C0300A',
        '102903/C0300B',
        '102902/C0300D',
        '102903/C0322S',
        '102903/C0322S',
        '102903/C0322S',
        '',
      ]),
    ],
    '2026S2CS-C': [
      AttendanceRecord('12/10/2025', [
        '102903/MA200B',
        '102903/CE200C',
        '102908/CH900A',
        '102908/ME900D',
        '102908/CH900A',
        '102908/CO200F',
        '',
      ]),
      AttendanceRecord('01/21/2026', [
        '',
        '',
        '102908/CH900A',
        '',
        '',
        '',
        '',
      ]),
      AttendanceRecord('01/22/2026', [
        '102902/CO200F',
        '102902/CO200F',
        '',
        '102903/MA200B',
        '',
        '',
        '',
      ]),
      AttendanceRecord('01/23/2026', [
        '102906/CO922S-B2',
        '102906/CO922S-B2',
        '',
        '',
        '',
        '',
        '',
      ]),
      AttendanceRecord('02/09/2026', [
        '102908/ME900D',
        '102908/ME900D',
        '102908/CH900A',
        '402909/CO901R',
        '102903/CE200C',
        '102903/MA200B',
        '',
      ]),
      AttendanceRecord('03/19/2026', [
        '102902/CO200F',
        '102902/CO200F',
        '102902/CO200F',
        '102903/MA200B',
        '102902/CO200F',
        '102908/CH900A',
        '',
      ]),
    ],
    '2025S1CS-C': [
      AttendanceRecord('10/10/2025', ['', '', '', '', '', '', '102906/CO100E']),
      AttendanceRecord('10/24/2025', [
        '',
        '',
        '102906/PH900A',
        '',
        '102906/CO100E',
        '',
        '',
      ]),
      AttendanceRecord('10/30/2025', [
        '102908/MA100B',
        '102908/MA100B',
        '102906/CO100E',
        '102906/PH900A',
        '102906/PH900A',
        '102906/PH900A',
        '',
      ]),
      AttendanceRecord('10/31/2025', [
        '102903/CO100F',
        '',
        '102906/PH900A',
        '',
        '102903/CO100F',
        '102903/CO100F',
        '102906/CO100E',
      ]),
      AttendanceRecord('11/14/2025', [
        '102903/CO100F',
        '',
        '',
        '',
        '102903/CO100F',
        '102903/CO100F',
        '102906/CO100E',
      ]),
    ],
  };
}
