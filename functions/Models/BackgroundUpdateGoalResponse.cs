using System.Text.Json.Serialization;
using System;

namespace WakaWatch.Models
{
    public class BackgroundUpdateGoalResponse {
        [JsonPropertyName("id")]
        public string Id { get; set; }

        [JsonPropertyName("title")]
        public string Title { get; set; }

        [JsonPropertyName("status_percent_calculated")]
        public double PercentCompleted { get; set; }

        [JsonPropertyName("range_status")]
        public string RangeStatus { get; set; }

        [JsonPropertyName("range_status_reason")]
        public string RangeStatusReason { get; set; }

        [JsonPropertyName("range_status_reason_short")]
        public string ShortRangeStatusReason { get; set; }

        [JsonPropertyName("modified_at")]
        public DateTime? ModifiedAt { get; set; }

        [JsonPropertyName("is_inverse")]
        public bool IsInverse { get; set; }

        [JsonPropertyName("goal_seconds")]
        public double GoalSeconds { get; set; }

        [JsonPropertyName("actual_seconds")]
        public double ActualSeconds { get; set; }
    }
}