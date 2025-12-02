import 'package:get/get.dart';
import 'package:rrfx/src/service/auth_service.dart';

class CompanyController extends GetxController {
  RxBool isLoading = false.obs;
  RxString responseMessage = "".obs;
  AuthService authService = AuthService();

  String profilePerusahaan({String? acc}) {
    return "https://client.rrfx.co.id/export/profile-perusahaan?acc=${acc ?? ''}";
  }

  String pernyataanSimulasi({String? acc}) {
    return "https://client.rrfx.co.id/export/pernyataan-simulasi?acc=${acc ?? ''}";
  }

  String pernyataanPengalaman({String? acc}) {
    return "https://client.rrfx.co.id/export/pernyataan-pengalaman?acc=${acc ?? ''}";
  }

  String aplikasiPembukaanRekening({String? acc}) {
    return "https://client.rrfx.co.id/export/aplikasi-pembukaan-rekening?acc=${acc ?? ''}";
  }

  String dokumenPemberitahuanAdanyaResiko({String? acc}) {
    return "https://client.rrfx.co.id/export/pemberitahuan-adanya-risiko?acc=${acc ?? ''}";
  }

  String perjanjianPemberianAmanat({String? acc}) {
    return "https://client.rrfx.co.id/export/perjanjian-pemberian-amanat?acc=${acc ?? ''}";
  }

  String tradingRules({String? acc}) {
    return "https://client.rrfx.co.id/export/trading-rules?acc=${acc ?? ''}";
  }

  String personalAccessPassword({String? acc}) {
    return "https://client.rrfx.co.id/export/personal-access-password?acc=${acc ?? ''}";
  }

  String pernyataanDanaNasabah({String? acc}) {
    return "https://client.rrfx.co.id/export/pernyataan-dana-nasabah?acc=${acc ?? ''}";
  }

  String suratPernyataanPenerimaanNasabah({String? acc}) {
    return "https://client.rrfx.co.id/export/surat-pernyataan?acc=${acc ?? ''}";
  }

  String formulirVerifikasiKelengkapan({String? acc}) {
    return "https://client.rrfx.co.id/export/kelengkapan-formulir?acc=${acc ?? ''}";
  }
}