using System.Text.Json.Serialization;
using System.Collections.Generic;

namespace WakaWatch.Models.WakaTime
{
    public class GoalsResponse {
        [JsonPropertyName("data")]
        public IEnumerable<Goal> Goals { get; set; }
    }
}