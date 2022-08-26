using System.Text.Json.Serialization;

namespace WakaWatch.Models.WakaTime
{
    public class CategoryData
    {
        [JsonPropertyName("name")]
        public string Name { get; set; }

        [JsonPropertyName("total_seconds")]
        public double TotalSeconds { get; set; }
    }
}