using System.Text.Json.Serialization;

namespace WakaWatch.Models.Github
{
    public class PullRequest
    {
        [JsonPropertyName("merged")]
        public bool Merged { get; set; }

        [JsonPropertyName("head")]
        public Head Head { get; set; }
    }
}