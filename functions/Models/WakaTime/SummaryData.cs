#nullable enable

using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace WakaWatch.Models.WakaTime
{
    public class SummaryData
    {
        [JsonPropertyName("categories")]
        public List<CategoryData>? Categories { get; set; }
    }
}