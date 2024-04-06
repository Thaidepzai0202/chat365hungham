import 'package:app_chat365_pc/core/constants/api_path.dart';
import 'package:app_chat365_pc/utils/data/clients/api_client.dart';
import 'package:app_chat365_pc/utils/data/models/request_method.dart';
import 'package:app_chat365_pc/utils/data/models/request_response.dart';

class VoiceRepo {
  final ApiClient _apiClient = ApiClient();
  Future<RequestResponse> transVoiceToText(String link) async {
    return await _apiClient.fetch(
      ApiPath.transVoiceToText,
      data: {'audio_link': link},
      method: RequestMethod.post,
    );
  }

  Future<RequestResponse> transTextToVoice(String txt) async {
    return await _apiClient.fetch(
      ApiPath.transTextToVoice,
      data: {
        "text": txt,
        "voice_id": 2,
        "volume": 50,
      },
      method: RequestMethod.post,
    );
  }
}
