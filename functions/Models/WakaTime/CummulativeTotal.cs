using System.Text.Json.Serialization;

namespace WakaWatch.Models.WakaTime
{
    public class CummulativeTotal {
        [JsonPropertyName("seconds")]
        public double Seconds { get; set; }
    }
}