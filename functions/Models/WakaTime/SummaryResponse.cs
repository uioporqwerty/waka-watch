using System.Text.Json.Serialization;

namespace WakaWatch.Models.WakaTime
{
    public class SummaryResponse {
        [JsonPropertyName("cummulative_total")]
        public CummulativeTotal CummulativeTotal { get; set; }
    }
}