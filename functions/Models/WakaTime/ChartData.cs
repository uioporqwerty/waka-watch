using System.Text.Json.Serialization;

namespace WakaWatch.Models.WakaTime
{
    public class ChartData { 
        [JsonPropertyName("range_status_reason")]
        public string RangeStatusReason { get; set; }

        [JsonPropertyName("range_status_reason_short")]
        public string ShortRangeStatusReason { get; set; }

        [JsonPropertyName("range_status")]
        public string RangeStatus { get; set; }

        [JsonPropertyName("goal_seconds")]
        public double GoalSeconds { get; set; }

        [JsonPropertyName("actual_seconds")]
        public double ActualSeconds { get; set; }
    }
}