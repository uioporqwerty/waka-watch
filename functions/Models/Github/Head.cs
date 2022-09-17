using System.Text.Json.Serialization;

namespace WakaWatch.Models.Github
{
    public class Head
    {
        [JsonPropertyName("ref")]
        public string Ref { get; set; }
    }
}