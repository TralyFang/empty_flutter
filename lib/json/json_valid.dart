import 'dart:convert';

void main() {

  //

  String input = "{status: success, payload: {adgroup_id: null, af_ad_type: ClickToDownload, af_adset_id: 136702704144, retargeting_conversion_type: none, orig_cost: 0.0, af_prt: polemedia, network: Display, is_first_launch: true, af_click_lookback: 28d, af_cpi: null, iscache: true, external_account_id: 5702715499, click_time: 2023-04-19 22:09:00.993, match_type: srn, adset: null, af_channel: ACI_Display, af_viewthrough_lookback: 1d, campaign_id: 15299632533, lat: 0, install_time: 2023-04-19 22:13:47.314, af_c_id: 15299632533, media_source: googleadwords_int, agency: polemedia, ad_event_id:-4PH5_u2_gIVI, af_siteid: null, af_status: Non-organic, af_sub1: null, gclid: null, cost_cents_USD: 0, referrer_gclid: CjwKCAjwov6hYcQAvD_BwE, af_ad_id: , af_reengagement_window: 30d, af_sub5: null, click-timestamp: 1681942140993, af_adset: Ad group 1, af_sub4: null, af_sub3: null, af_sub2: null, adset_id: null, gbraid: null, campaign: polemedia_Oyetalk_PK_Android_20211118_LI- 2.0purchase, http_referrer: null, af_ad: , adgroup: null}}";

  // Remove the curly braces from the input string
  String jsonString = input.substring(1, input.length - 1);

  // Replace the colons with double quotes and colons
  jsonString = jsonString.replaceAll(": ", "\":\"");

  // Replace the commas with commas and double quotes
  jsonString = jsonString.replaceAll(", ", "\",\"");

  // Add opening and closing braces to the string to make it valid JSON
  jsonString = "{\"$jsonString\"}";

  // Parse the JSON string to a JSON object
  Map<String, dynamic> jsonMap = jsonDecode(jsonString);

  // Encode the JSON object to a JSON string
  String jsonEncodedString = jsonEncode(jsonMap);

  print(jsonEncodedString);
}

class TryCatchExample {
  Future<List<int>?> compressAndTryCatch(String path) async {
    List<int>? result;
    try {
      // result = await FlutterImageCompress.compressWithFile(
      //   path,
      //   format: CompressFormat.heic,
      // );
    } on UnsupportedError catch (e) {
      print(e.message);
      // result = await FlutterImageCompress.compressWithFile(
      //   path,
      //   format: CompressFormat.jpeg,
      // );
    } on Error catch (e) {
      print(e.toString());
      print(e.stackTrace);
    } on Exception catch (e) {
      print(e.toString());
    }
    return result;
  }
}