import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rrfx/src/helpers/variables/global_variables.dart';
import 'package:rrfx/src/models/auth/image_login_model.dart';
import 'package:rrfx/src/models/settings/invite_model.dart';
import 'package:rrfx/src/models/trades/market_model.dart';
import 'package:rrfx/src/models/utilities/chat_model_list.dart';
import 'package:rrfx/src/models/utilities/messages_model.dart';
import 'package:rrfx/src/models/utilities/city_models.dart';
import 'package:rrfx/src/models/utilities/country_models.dart';
import 'package:rrfx/src/models/utilities/desa_models_api.dart';
import 'package:rrfx/src/models/utilities/kabupaten_models_api.dart';
import 'package:rrfx/src/models/utilities/kabupaten_raja_models.dart';
import 'package:rrfx/src/models/utilities/kecamatan_models_api.dart';
import 'package:rrfx/src/models/utilities/kecamatan_raja_models.dart';
import 'package:rrfx/src/models/utilities/news_detail.dart';
import 'package:rrfx/src/models/utilities/news_model.dart';
import 'package:rrfx/src/models/utilities/province_models.dart';
import 'package:rrfx/src/models/utilities/province_models_api.dart';
import 'package:rrfx/src/models/utilities/province_raja_models.dart';
import 'package:rrfx/src/models/utilities/slide_model.dart';
import 'package:rrfx/src/models/utilities/trading_signals_model.dart';
import 'package:rrfx/src/models/utilities/ticket_topics_model.dart';
import 'package:rrfx/src/service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UtilitiesController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLoadingProvince = false.obs;
  RxBool isLoadingCity = false.obs;
  RxString responseMessage = "".obs;
  RxString selectedCountry = "".obs;
  RxString selectedProvince = "".obs;
  RxString selectedCity = "".obs;
  RxString selectedTopic = "".obs;
  RxBool loadingPrice = false.obs;

  AuthService authService = Get.find();

  Rxn<CountryModels> countryModels = Rxn<CountryModels>();
  Rxn<ProvinceModels> provinceModels = Rxn<ProvinceModels>();
  Rxn<CityModels> cityModels = Rxn<CityModels>();
  Rxn<NewsModel> newsModel = Rxn<NewsModel>();
  Rxn<NewsDetail> newsDetail = Rxn<NewsDetail>();
  Rxn<MarketModel> marketModel = Rxn<MarketModel>();
  Rxn<SlideListModel> slideModel = Rxn<SlideListModel>();
  Rxn<ImageLoginModel> imageLoginModel = Rxn<ImageLoginModel>();
  Rxn<TradingSignalsModel> tradingSignal = Rxn<TradingSignalsModel>();
  Rxn<InviteLinkModel> inviteLinkModel = Rxn<InviteLinkModel>();

  // Ticket
  Rxn<ListOfTicketsModel> listTicketModel = Rxn<ListOfTicketsModel>();
  Rxn<MessagesModel> messagesModel = Rxn<MessagesModel>();
  Rxn<TicketTopicsModel> ticketTopicsModel = Rxn<TicketTopicsModel>();
  RxList<String> topics = <String>[].obs;

  //Raja Class Models
  Rxn<ProvinceRajaModels> provinceRajaModels = Rxn<ProvinceRajaModels>();
  Rxn<KabupatenRajaModels> kabupatenRajaModels = Rxn<KabupatenRajaModels>();
  Rxn<KecamatanRajaModels> kecamatanRajaModels = Rxn<KecamatanRajaModels>();

  Rxn<ProvinceModelsAPI> provinceModelAPI = Rxn<ProvinceModelsAPI>();
  Rxn<KabupatenModelsAPI> kabupatenModelAPI = Rxn<KabupatenModelsAPI>();
  Rxn<KecamatanModelsAPI> kecamatanModelAPI = Rxn<KecamatanModelsAPI>();
  Rxn<DesaModelsAPI> desaModelAPI = Rxn<DesaModelsAPI>();
  RxString selectedProvinceID = "".obs;
  RxString selectedKabupatenID = "".obs;
  RxString selectedKecamatanID = "".obs;
  RxString selectedDesaID = "".obs;

  Future<bool> getCountry() async {
    try {
      isLoading(true);
      http.Response response = await http.get(
        Uri.tryParse("https://countriesnow.space/api/v0.1/countries/capital")!,
        headers: {'Content-Type': 'application/json'},
      );
      var result = jsonDecode(response.body);
      isLoading(false);
      if (response.statusCode == 200) {
        countryModels.value = CountryModels.fromJson(result);
        return true;
      } else {
        responseMessage.value = result['msg'];
        return false;
      }
    } catch (e) {
      isLoading(false);
      responseMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> getProvince({String? countryName}) async {
    try {
      isLoadingProvince(true);
      http.Response response = await http.get(
        Uri.tryParse(
          "https://countriesnow.space/api/v0.1/countries/states/q?country=$countryName",
        )!,
        headers: {'Content-Type': 'application/json'},
      );
      var result = jsonDecode(response.body);
      isLoadingProvince(false);
      if (response.statusCode == 200) {
        provinceModels.value = ProvinceModels.fromJson(result);
        return true;
      } else {
        responseMessage.value = result['msg'];
        return false;
      }
    } catch (e) {
      isLoadingProvince(false);
      responseMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> getCity({String? provinceName}) async {
    try {
      isLoadingCity(true);
      http.Response response = await http.get(
        Uri.tryParse(
          "https://countriesnow.space/api/v0.1/countries/state/cities/q?country=${selectedCountry.value}&state=${selectedProvince.value}",
        )!,
        headers: {'Content-Type': 'application/json'},
      );
      var result = jsonDecode(response.body);
      isLoadingCity(false);
      if (response.statusCode == 200) {
        cityModels.value = CityModels.fromJson(result);
        return true;
      } else {
        responseMessage.value = result['msg'];
        return false;
      }
    } catch (e) {
      isLoadingCity(false);
      responseMessage.value = e.toString();
      return false;
    }
  }

  // Province Raja Controller API
  Future<bool> getProvinceRaja() async {
    try {
      isLoadingProvince(true);
      http.Response response = await http.get(
        Uri.tryParse("https://pro.rajaongkir.com/api/province")!,
        headers: {'key': 'e049d10db2bd7fc4d5ec3cb4035633be'},
      );
      var result = jsonDecode(response.body);
      isLoadingProvince(false);
      if (response.statusCode == 200) {
        provinceRajaModels.value = ProvinceRajaModels.fromJson(result);
        return true;
      } else {
        responseMessage.value = "Failed to get Province";
        return false;
      }
    } catch (e) {
      isLoadingProvince(false);
      responseMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> getCityRaja() async {
    try {
      isLoadingCity(true);
      http.Response response = await http.get(
        Uri.tryParse(
          "https://pro.rajaongkir.com/api/city?province=$selectedProvince",
        )!,
        headers: {'key': 'e049d10db2bd7fc4d5ec3cb4035633be'},
      );
      var result = jsonDecode(response.body);
      isLoadingCity(false);
      if (response.statusCode == 200) {
        kabupatenRajaModels.value = KabupatenRajaModels.fromJson(result);
        return true;
      } else {
        responseMessage.value = "Failed to get Kabupaten";
        return false;
      }
    } catch (e) {
      isLoadingCity(false);
      responseMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> getVillageRaja() async {
    try {
      isLoadingCity(true);
      http.Response response = await http.get(
        Uri.tryParse("https://pro.rajaongkir.com/api/subdistrict?city=409")!,
        headers: {'key': 'e049d10db2bd7fc4d5ec3cb4035633be'},
      );
      var result = jsonDecode(response.body);
      isLoadingCity(false);
      if (response.statusCode == 200) {
        cityModels.value = CityModels.fromJson(result);
        return true;
      } else {
        responseMessage.value = "Failed to get Kecamatan";
        return false;
      }
    } catch (e) {
      isLoadingCity(false);
      responseMessage.value = e.toString();
      return false;
    }
  }

  // Province API
  Future<bool> getProvinceAPI() async {
    try {
      Map<String, dynamic> result = await authService.get("regol/getProvince");
      isLoading(false);
      if (result['status'] != true) {
        return false;
      }
      provinceModelAPI(ProvinceModelsAPI.fromJson(result));
      responseMessage(result['message']);
      return true;
    } catch (e) {
      isLoading(false);
      responseMessage(e.toString());
      return false;
    }
  }

  // Kabupaten API
  Future<bool> getKabupatenAPI() async {
    try {
      Map<String, dynamic> result = await authService.post("regol/getRegency", {
        "province": selectedProvinceID.value,
      });

      if (result['status'] != true) {
        return false;
      }
      kabupatenModelAPI(KabupatenModelsAPI.fromJson(result));
      responseMessage(result['message']);
      return true;
    } catch (e) {
      responseMessage(e.toString());
      return false;
    }
  }

  // Kecamatan API
  Future<bool> getKecamatanAPI() async {
    try {
      Map<String, dynamic> result = await authService.post(
        "regol/getDistrict",
        {"regency": selectedKabupatenID.value},
      );
      if (result['status'] != true) {
        return false;
      }
      kecamatanModelAPI(KecamatanModelsAPI.fromJson(result));
      responseMessage(result['message']);
      return true;
    } catch (e) {
      responseMessage(e.toString());
      return false;
    }
  }

  // Desa API
  Future<bool> getDesaAPI() async {
    try {
      Map<String, dynamic> result = await authService.post(
        "regol/getVillages",
        {"district": selectedKecamatanID.value},
      );

      if (result['status'] != true) {
        return false;
      }
      desaModelAPI(DesaModelsAPI.fromJson(result));
      responseMessage(result['message']);
      return true;
    } catch (e) {
      responseMessage(e.toString());
      return false;
    }
  }

  // Desa API
  Future<bool> getNewsList() async {
    try {
      Map<String, dynamic> result = await authService.get("public/news");
      if (result['status'] != true) {
        return false;
      }
      newsModel(NewsModel.fromJson(result));
      responseMessage(result['message']);
      return true;
    } catch (e) {
      responseMessage(e.toString());
      return false;
    }
  }

  // Desa API
  Future<bool> getSlideImageHome() async {
    try {
      Map<String, dynamic> result = await authService.get("public/slide");

      if (result['status'] != true) {
        return false;
      }
      slideModel(SlideListModel.fromJson(result));
      responseMessage(result['message']);
      return true;
    } catch (e) {
      responseMessage(e.toString());
      return false;
    }
  }

  // Daftar Tickets API
  Future<bool> ticketList() async {
    try {
      Map<String, dynamic> result = await authService.get("ticket/list");

      if (result['status'] != true) {
        return false;
      }
      responseMessage(result['message']);
      listTicketModel(ListOfTicketsModel.fromJson(result));
      return true;
    } catch (e) {
      responseMessage(e.toString());
      return false;
    }
  }

  // Get Ticket Topics API
  Future<bool> getTopics() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');
    try {
      isLoading(true);
      http.Response response = await http.get(
        Uri.tryParse("${GlobalVariable.mainURL}/ticket/topics")!,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer $token'});
      var result = jsonDecode(response.body);
      isLoading(false);
      responseMessage.value = result['message'];
      if (response.statusCode == 200 && result['status']) {
        topics.value = List<String>.from(result['data'] ?? []);
        Get.log("✅ [UtilitiesController] Topics fetched successfully: ${topics.join(", ")}");
        return true;
      }
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage.value = e.toString();
      return false;
    }
  }

  // Create Tickets API
  Future<bool> createTicket({String? subject}) async {
    try {
      Map<String, dynamic> result = await authService.post("ticket/create", {
        "subject": subject,
        "topic": selectedTopic.value,
      });

      if (result['status'] != true) {
        return false;
      }
      responseMessage(result['message']);
      return true;
    } catch (e) {
      responseMessage(e.toString());
      return false;
    }
  }

  // Create Tickets API
  Future<bool> closeTicket({String? code}) async {
    try {
      Map<String, dynamic> result = await authService.post("ticket/close", {
        "code": code,
      });
      if (result['status'] != true) {
        return false;
      }
      responseMessage(result['message']);
      return true;
    } catch (e) {
      responseMessage(e.toString());
      return false;
    }
  }

  // List Message of Ticket API
  Future<bool> listMessageOfTicket({String? code}) async {
    try {
      Map<String, dynamic> result = await authService.get(
        "ticket/chats?code=$code",
      );

      if (result['status'] != true) {
        return false;
      }
      responseMessage(result['message']);
      messagesModel(MessagesModel.fromJson(result));
      return true;
    } catch (e) {
      responseMessage(e.toString());
      return false;
    }
  }

  // Send Ticket Message API
  Future<bool> sendMessage({
    String? code,
    String? message,
    String? attachmentPath, // optional (file)
  }) async {
    try {
      Map<String, String> body = {'code': code ?? ""};
      if (message != null && message.isNotEmpty) {
        body['message'] = message;
      }
      Map<String, String> file = {'attachment': attachmentPath ?? ""};
      final result = await authService.multipart(
        "ticket/send-message",
        body,
        file,
      );
      if (result['status'] != true) {
        responseMessage(result['message']);
        return false;
      }
      responseMessage(result['message']);
      return true;
    } catch (e) {
      responseMessage(e.toString());
      return false;
    }
  }

  // Desa API
  Future<bool> getSlideImageLogin() async {
    try {
      Map<String, dynamic> result = await authService.get("public/slide-home");

      if (result['status'] != true) {
        return false;
      }
      imageLoginModel(ImageLoginModel.fromJson(result));
      responseMessage(result['message']);
      return true;
    } catch (e) {
      responseMessage(e.toString());
      return false;
    }
  }

  // Desa API
  Future convertingMoney({
    String? amount,
    String? accountID,
    String? type = "withdrawal",
  }) async {
    try {
      Map<String, dynamic> result = await authService.post(
        "transaction/rate-conversation",
        {"amount": amount, "account": accountID, "type": type},
      );
      responseMessage(result['message']);
      if (result['status'] != true) {
        return false;
      }
      return result;
    } catch (e) {
      responseMessage(e.toString());
      return false;
    }
  }

  // Desa API
  Future getBankList() async {
    try {
      Map<String, dynamic> result = await authService.get("bank/banklist");
      responseMessage(result['message']);
      if (result['status'] != true) {
        responseMessage("Daftar Bank Tidak Ditemukan");
        return null;
      }
      return result['response'];
    } catch (e) {
      responseMessage(e.toString());
      return false;
    }
  }

  // Desa API
  Future<bool> getNewsDetail({String? newsID}) async {
    try {
      Map<String, dynamic> result = await authService.post(
        "public/news-detail",
        {"id": newsID},
      );

      if (result['status'] != true) {
        return false;
      }
      newsDetail(NewsDetail.fromJson(result));
      responseMessage(result['message']);
      return true;
    } catch (e) {
      responseMessage(e.toString());
      return false;
    }
  }

  Future<bool> getTradingSignals({String? timeFrame}) async {
    try {
      isLoading(true);
      http.Response response = await http.get(
        Uri.tryParse(
          "https://api-mt5.techcrm.net/v5-terminal-analis/analysis_main?timeframe=${timeFrame ?? "H1"}",
        )!,
        headers: {'Content-Type': 'application/json'},
      );
      var result = jsonDecode(response.body);
      isLoading(false);
      if (response.statusCode == 200) {
        tradingSignal(TradingSignalsModel.fromJson(result));
        return true;
      }
      responseMessage.value = result['result'];
      return false;
    } catch (e) {
      isLoading(false);
      responseMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> getMarketPrice() async {
    try {
      loadingPrice(true);
      http.Response response = await http.get(
        Uri.tryParse("https://api-mt5.techcrm.net/v5-terminal-analis/prices")!,
        headers: {'Content-Type': 'application/json'},
      );
      var result = jsonDecode(response.body);

      loadingPrice(false);
      if (response.statusCode == 200) {
        marketModel(MarketModel.fromJson(result));
        return true;
      }
      responseMessage.value = result['result'];
      return false;
    } catch (e) {
      loadingPrice(false);
      responseMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> getInviteLinks() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      isLoading.value = true;

      String? token = prefs.getString('accessToken');
      if (token == null) {
        isLoading.value = false;
        responseMessage.value = "Token akses hilang";
        return false;
      }

      final response = await http.get(
        Uri.parse("https://api-rrfx.techcrm.net/refferal/list"),
        headers: {
          'Authorization': 'Bearer $token',
          'Cookie': 'PHPSESSID=3ppho7ofputj10ah2lu2v6k8ud',
        },
      );

      final result = jsonDecode(response.body);
      isLoading.value = false;

      if (result['data'].toList().isEmpty) {
        responseMessage.value = result['message'];
        return false;
      }

      if (response.statusCode == 200 && result['status'] == true) {
        inviteLinkModel.value = InviteLinkModel.fromJson({
          "data": result["data"],
        });
        return true;
      }

      // handle kalau bukan sales
      if (result['status'] == true &&
          (result['data'] is List && result['data'].isEmpty)) {
        responseMessage.value = result['message'];
        inviteLinkModel.value = null;
        return false;
      }
      responseMessage.value = result['message'] ?? "Gagal memuat data";
      return false;
    } catch (e) {
      isLoading.value = false;
      responseMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> getRefferalLinks() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      isLoading.value = true;

      String? token = prefs.getString('accessToken');
      if (token == null) {
        isLoading.value = false;
        responseMessage.value = "Token akses hilang";
        return false;
      }

      final response = await http.get(
        Uri.parse("${GlobalVariable.mainURL}/refferal/list"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['status'] == true) {
        // Check if data is a List (empty array for non-sales)
        if (result['data'] is List) {
          responseMessage.value =
              result['message'] ?? "Tidak ada link referral";
          inviteLinkModel.value = null;
          isLoading.value = false;
          return false;
        }

        // Check if data is empty Map or null
        if (result['data'] == null ||
            (result['data'] is Map &&
                (result['data']['general'] == null ||
                    result['data']['general'].isEmpty) &&
                (result['data']['spesific'] == null ||
                    result['data']['spesific'].isEmpty))) {
          responseMessage.value =
              result['message'] ?? "Tidak ada link referral";
          inviteLinkModel.value = null;
          isLoading.value = false;
          return false;
        }

        inviteLinkModel.value = InviteLinkModel.fromJson({
          "data": result["data"],
        });

        responseMessage.value = result['message'] ?? "Berhasil memuat data";
        isLoading.value = false;
        return true;
      }

      responseMessage.value = result['message'] ?? "Gagal memuat data";
      isLoading.value = false;
      return false;
    } catch (e) {
      Get.log('❌ Error in getRefferalLinks: $e');
      isLoading.value = false;
      responseMessage.value = e.toString();
      return false;
    }
  }
}
