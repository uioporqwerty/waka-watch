using System.Text.Json.Serialization;
using System.Collections.Generic;
using System;

namespace WakaWatch.Models.WakaTime
{
    public class Goal {
        [JsonPropertyName("id")]
        public string Id { get; set; }

        [JsonPropertyName("title")]
        public string Title { get; set; }

        [JsonPropertyName("status_percent_calculated")]
        public double PercentCompleted { get; set; }

        [JsonPropertyName("is_inverse")]
        public bool IsInverse { get; set; }

        [JsonPropertyName("is_snoozed")]
        public bool IsSnoozed { get; set; }

        [JsonPropertyName("is_enabled")]
        public bool IsEnabled { get; set; }

        [JsonPropertyName("modified_at")]
        public DateTime? ModifiedAt { get; set; }

        [JsonPropertyName("chart_data")]
        public List<ChartData> ChartData { get; set; }
    }
}