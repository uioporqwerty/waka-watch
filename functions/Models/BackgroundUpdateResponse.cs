using System.Text.Json.Serialization;
using System.Collections.Generic;

namespace WakaWatch.Models
{
    public class BackgroundUpdateResponse {
        [JsonPropertyName("total_time_coded_in_seconds")]
        public double TotalTimeCodedInSeconds { get; set; }

        [JsonPropertyName("goals")]
        public IEnumerable<BackgroundUpdateGoalResponse> Goals { get; set; }
    }
}